
=head1 NAME

XIMS::DataProvider -- the interface to the data store

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::DataProvider;

=head1 DESCRIPTION

The idea here is to create a generic bridge between the data store and the
top-level XIMS Object classes. We try to lighten the Object classes that rely
the DP by deciding here how to organise the arguments passed in from those
classes.

=head1 SUBROUTINES/METHODS

Peer-level methods (those implemented by this class) can use this factory to
prepare the %conditions and %properties of non-Object related methods, but it's
probably better if they just set those argument and call the Driver directly.


=cut

package XIMS::DataProvider;

use strict;

# use warnings;
use XIMS;
use XIMS::Names;
use XIMS::Iterator::Object;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our $AUTOLOAD;
our $cached_URIs;

BEGIN {
    $cached_URIs = {};
    foreach my $rtype ( XIMS::Names::resource_types() ) {
        foreach my $property (
            @{ XIMS::Names::property_interface_names($rtype) } )
        {
            $cached_URIs->{$rtype}->{$property}
                = XIMS::Names::get_URI( $rtype, $property );
        }
    }
}

=head2 request_factory()

=cut

sub request_factory {
    my $self        = shift;
    my $r_type      = shift;
    my $method_type = shift;
    my %args        = @_;
    my %properties;
    my %conditions;

    #my @property_names = ();
    my %request_params = ();

    my $lookup = lc($r_type);

    # ubu: we can prolly delete the first branch in this fork soon.
    if ( defined $args{$lookup} ) {

        # if we have been passed an intance of one of the basic resource types
        # just extract the properties from it.
        %request_params = %{ $args{$lookup} };
    }
    else {
        %request_params = %args;
    }

    if ( $method_type eq 'create' or $method_type eq 'update' ) {
        foreach my $k ( keys(%request_params) ) {
            my $outname = $cached_URIs->{$r_type}->{$k};
            $properties{$outname} = $request_params{$k}
                if ( defined $outname
                and XIMS::Names::valid_property( $r_type, $outname ) );

            # ubu: refactor
            if (( $k eq 'id' and $method_type eq 'update' )
                || (    ( $k eq 'grantee_id' or $k eq 'content_id' )
                    and $method_type eq 'update'
                    and $r_type eq 'ObjectPriv' )
                )
            {
                $conditions{$outname} = delete $properties{$outname};
            }
            elsif ( $k eq 'document_id'
                and $method_type eq 'update'
                and $r_type eq 'Object' )
            {
                $conditions{'document.id'} = $request_params{$k};
            }
        }

        # now, fill in the blanks
        foreach my $prop ( @{ XIMS::Names::property_list($r_type) } ) {
            next if defined( $properties{$prop} or $prop =~ /\.id$/ );
            $properties{$prop} = undef;
        }
    }
    else {
        my $properties = delete $args{properties};

        foreach my $k ( keys(%request_params) ) {
            my $outname = $cached_URIs->{$r_type}->{$k};
            $conditions{$outname} = $request_params{$k}
                if ( defined $outname
                and XIMS::Names::valid_property( $r_type, $outname ) );
        }

        # additional properties from the Driver to cover data-centric
        # conditions (relational joins in the DBI Driver, for example).
        my $add_conds = $self->{Driver}
            ->property_relationships( $r_type, $method_type );
        if ( defined($add_conds) ) {
            foreach my $k ( keys( %{$add_conds} ) ) {
                $conditions{$k} = $add_conds->{$k};
            }
        }

        # let classes ask for only the data they want for get() (for special
        # cases only!!)
        if ( defined( $properties and $method_type eq 'get' ) ) {
            my @prop_names
                = map { $cached_URIs->{$r_type}->{$_} } @{$properties};
            %properties = map { $_, 1 } @prop_names;
        }
    }

    unless ( scalar( keys(%properties) ) > 0 ) {
        my @prop_names = values %{ $cached_URIs->{$r_type} };
        %properties = map { $_, 1 } @prop_names;
    }

#warn "request factory: " . Dumper( \%properties ) . Dumper( \%conditions ) . "\n";
    return ( \%properties, \%conditions );
}

=head2 new()

=cut

sub new {
    my $class  = shift;
    my $drvnme = shift || 'DBI';
    my $self   = undef;

    my $drvcls = 'XIMS::DataProvider::' . $drvnme;
    my $driver = undef;

    ## no critic (ProhibitStringyEval)
    eval "require $drvcls";    # first load the driver class module
    if ($@) {
        die("driver class not found! Reason: $@\n");
    }
    else {
        my $args = shift || {};
        $args->{dbuser} = XIMS::Config::DBUser()
            unless defined $args->{dbuser};
        $args->{dbpasswd} = XIMS::Config::DBPassword()
            unless defined $args->{dbpasswd};
        $args->{dbdsn} = XIMS::Config::DBdsn() unless defined $args->{dbdsn};
        $args->{dbsessionopt} = XIMS::Config::DBSessionOpt()
            unless defined $args->{dbsessionopt};
        $args->{dbdopt} = XIMS::Config::DBDOpt()
            unless defined $args->{dbdopt};

        $driver = $drvcls->new( %{$args} );

        if ($driver) {
            $self = bless {}, $class;
            $self->{Driver} = $driver;
        }
        else {
            die("driver class $drvcls did not initialize!");
        }
    }
    ## use critic
    return $self;
}

=head2 AUTOLOAD()

=cut

sub AUTOLOAD {
    my $self = shift;
    my ( undef, $called_sub ) = ( $AUTOLOAD =~ /(.*)::(.*)/ );
    return if $called_sub eq 'DESTROY';

    my $method;
    my $data;
    if ( $called_sub =~ /(get|create|delete|update)(.+?)$/ ) {
        my $action = $1;
        my $r_type = $2;

# ubu: debugging here, don't delete.
# my ($package, $filename, $line) = caller;
#warn "DP AUTOLOAD called.\naction: $action\nresource type: $r_type\narguments: " .
#      Dumper( \@_ ) . "\ncalled by: $package line $line\n";

        # allow Drivers to override $dp->getFoo() methods
        if ( $method = $self->{Driver}->can($called_sub) ) {
            $data = $method->( $self->{Driver}, @_ );
        }
        elsif ( grep { $_ eq $r_type } XIMS::Names::resource_types() ) {
            my %args = @_;
            my %param;

            # pass on limit, offset, and order parameters that may have been
            # given
            $param{limit}  = delete $args{limit};
            $param{offset} = delete $args{offset};
            my $order = delete $args{order};
            $param{order} = $order if ( defined $order and length $order );

            my ( $properties, $conditions )
                = $self->request_factory( $r_type, $action, %args );
            $data = $self->{Driver}->$action(
                properties => $properties,
                conditions => $conditions,
                %param
            );
        }
    }

    # short circuit for free access to low-level Driver methods.
    elsif ( $method = $self->{Driver}->can($called_sub) ) {

        #warn "Calling Driver method $called_sub directly, passing @_ \n";
        $data = $method->( $self->{Driver}, @_ );
    }

    # finally, if no class can take the method, die appropriately
    else {
        my ( $package, $filename, $line ) = caller();
        die
            "Method $called_sub called by $package line $line not implemented by data provider. \n";
    }

    # fix-up the return values based on the calling method's expectation;
    if ( ref($data) eq 'ARRAY' ) {
        return wantarray() ? @{$data} : $data->[0];
    }
    else {
        return $data;
    }
}

=pod

we need special cases here because content objects span mutiple tables

=cut

=head2 createObject()

=cut

sub createObject {
    my $self           = shift;
    my %doc_properties = ();
    my $body_data;
    my $update_body_method;

    my ( $properties, $conditions )
        = $self->request_factory( 'Object', 'create', @_ );

    my @doc_keys
        = grep { ( split /\./, $_ )[0] eq 'document' } keys %{$properties};
    @doc_properties{@doc_keys} = delete @{$properties}{@doc_keys};

    $doc_properties{'document.id'} = 1;
    delete $doc_properties{
        'document.location_path'};    # gets set by the corresponding trigger

    # The update triggers on body will set the real content_length on update
    # If body is empty, content_length will be set to zero and not to undef
    # Therefore, we set it to zero here for object creation
    $properties->{'content.content_length'} ||= 0;

    my $doc_id = $self->{Driver}
        ->create( properties => \%doc_properties, conditions => {} );
    $properties->{'content.document_id'} = $doc_id;

    # nuttiness for Oracle's sorry @ss
    if ( defined( $properties->{'content.body'} ) ) {
        $update_body_method = 'update_content_body';
        $body_data          = delete $properties->{'content.body'};
    }
    elsif ( defined( $properties->{'content.binfile'} ) ) {
        $update_body_method = 'update_content_binfile';
        $body_data          = delete $properties->{'content.binfile'};
    }

    my $object_id = $self->{Driver}
        ->create( properties => $properties, conditions => {} );

    if (    defined $body_data
        and length($body_data) > 0
        and defined($object_id) )
    {
        $self->{Driver}->$update_body_method( $object_id, $body_data );
    }

    #warn "returning object_id: $object_id \n";
    return ( $object_id, $doc_id );
}

=head2 getObject()

=cut

sub getObject {
    my $self = shift;
    my %args = @_;

    my $span_tables = 1;
    my ( $properties, $conditions )
        = $self->request_factory( 'Object', 'get', %args );

    if ( wantarray() and defined( $args{properties} ) ) {

        #warn "explicit properties " . Dumper( $args{properties}  );
        my $doc_prop_count = grep { ( split /\./, $_ )[0] eq 'document' }
            keys %{$properties};
        my $content_prop_count
            = grep { ( split /\./, $_ )[0] eq 'content' } keys %{$properties};
        $span_tables-- unless $doc_prop_count > 0 and $content_prop_count > 0;
    }
    else {
        $properties = { 'content.id' => 1, 'document.id' => 1 };
    }

    my $doc_cond_count;
    for ( keys %{$conditions} ) {
        $doc_cond_count++ if ( split /\./, $_ )[0] eq 'document';
    }

    # look for custom conditions where a join with the document table would be
    # needed if $conditions->{'document.id'} is the only document condition
    # and holds a scalar reference this is recognized as a default condition
    # and no custom document conditions will be detected
    if ($doc_cond_count > 0
        and not( $doc_cond_count == 1
            and ref( $conditions->{'document.id'} ) eq 'SCALAR' )
        )
    {
        $span_tables++;
        $properties->{'document.id'} = 1
            ;  # make sure DP::DBI::table_columns_get does the right thing :-|
    }

    # if we do not have custom document conditions or document properties,
    # joining the content and document tables is not needed and we can remove
    # the default $conditions->{'document.id'} condition
    if ( $span_tables == 0 ) {
        delete $conditions->{'document.id'};
    }

    my $data = $self->{Driver}
        ->get( properties => $properties, conditions => $conditions );
    if ( wantarray() ) {
        foreach my $obj ( @{$data} ) {
            if ( defined( $obj->{'content.binfile'} ) ) {
                $obj->{'content.body'} = delete $obj->{'content.binfile'};
            }
        }
        return @{$data};
    }
    else {
        my @ids = map { $_->{'document.id'} } @{$data};
        return XIMS::Iterator::Object->new( \@ids );
    }
}

=head2 updateObject()

=cut

sub updateObject {
    my $self           = shift;
    my %doc_properties = ();
    my %doc_conditions = ();
    my $body_data;
    my $update_body_method;

    my @ret;
    my ( $properties, $conditions )
        = $self->request_factory( 'Object', 'update', @_ );

    delete $properties->{
        'document.location_path'};    # gets set by the corresponding trigger
    delete $properties->{
        'content.content_length'};    # gets set by the corresponding trigger

    my @doc_prop_keys
        = grep { ( split /\./, $_ )[0] eq 'document' } keys %{$properties};
    @doc_properties{@doc_prop_keys} = delete @{$properties}{@doc_prop_keys};

    my @doc_cond_keys
        = grep { ( split /\./, $_ )[0] eq 'document' } keys %{$conditions};
    @doc_conditions{@doc_cond_keys} = delete @{$conditions}{@doc_cond_keys};

    if ( $properties->{'content.document_id'} ) {
        $doc_conditions{'document.id'}
            ||= $properties->{'content.document_id'};
        delete $properties->{'content.document_id'};
    }

    # update document table if wanted
    if ( scalar keys %doc_properties ) {
        push @ret, $self->{Driver}->update(
            properties => \%doc_properties,
            conditions => \%doc_conditions
        );
    }

    # return if we do not want to update the content table
    if ( not scalar keys %{$properties} ) {
        return @ret;
    }

    if ( defined( $properties->{'content.body'} ) ) {
        $update_body_method = 'update_content_body';
        $body_data          = delete $properties->{'content.body'};
    }
    elsif ( defined( $properties->{'content.binfile'} ) ) {
        $update_body_method = 'update_content_binfile';
        $body_data          = delete $properties->{'content.binfile'};
    }

    push @ret, $self->{Driver}
        ->update( properties => $properties, conditions => $conditions );

    if (    $body_data
        and length($body_data) > 0
        and defined( $conditions->{'content.id'} ) )
    {
        $self->{Driver}
            ->$update_body_method( $conditions->{'content.id'}, $body_data );
    }

    return @ret;
}

=head2 deleteObject()

=cut

sub deleteObject {
    my $self = shift;
    my %args = @_;

    $self->{Driver}->delete(
        properties => { 'document.id' => 1 },
        conditions => { 'document.id' => $args{document_id} }
    );

    $self->{Driver}->delete(
        properties => { 'content.id' => 1 },
        conditions => { 'content.id' => $args{id} }
    );
    return 1;
}

=head2 getUser()

=cut

sub getUser {
    my $self = shift;
    my %args = @_;
    my %param;

    my ( $properties, $conditions )
        = $self->request_factory( 'User', 'get', %args );

    if ( my $username = delete $conditions->{'user.name'} ) {
        $conditions->{"adhoc"}
            = { "lower(ci_users_roles.name)" => lc $username };
    }

    my $data = $self->{Driver}
        ->get( properties => $properties, conditions => $conditions );

    if ( ref($data) eq 'ARRAY' ) {
        return wantarray() ? @{$data} : $data->[0];
    }
    else {
        return $data;
    }
}

=head2 driver()

=cut

sub driver { $_[0]->{Driver} }

# XXX to be replaced by hierarchical query...

=head2 recurse_ancestor()

=cut

sub recurse_ancestor {
    my $self               = shift;
    my $object             = shift;
    my $filter_objectroots = shift;
    my @ancestors          = @_;

#warn "testing id " . $object->document_id() . " (title: ". $object->title() . ") against " . $object->parent_id() . "\n";

    # root has no ancestors
    return () if ( defined $object->id() and $object->id() == 1 );

    require XIMS::Object;
    my $parent = XIMS::Object->new(
        document_id => $object->parent_id(),
        User        => $object->User()
    );
    if ( defined $filter_objectroots ) {
        my @object_types = $self->object_types();
        my @or_ots = grep { $_->is_objectroot == 1 } @object_types;
        if ( grep { $parent->object_type_id() == $_->id } @or_ots ) {
            push( @ancestors, $parent );
        }
    }
    else {
        push( @ancestors, $parent );
    }

    if ( $parent->document_id() != 1 ) {
        $self->recurse_ancestor( $parent, $filter_objectroots, @ancestors );
    }
    else {
        return reverse @ancestors;
    }
}

=pod

abstract methods for easy access to all resources. Use get<ResouceType>
instead for selection of specific objects, users, object_types, etc.

list all object types, data_formats, etc.

=cut

=head2 object_types()

=cut

## no critic (ProhibitNoStrict)

sub object_types {
    my $self = shift;
    my %args = @_;
    my $cache;
    $cache = 1 unless scalar keys %args > 0;
    no strict 'refs';
    if ( defined $cache and defined *{"XIMS::OBJECT_TYPES"}{CODE} ) {
        return values %{ XIMS::OBJECT_TYPES() };
    }
    my @data = $self->getObjectType(%args);
    require XIMS::ObjectType;
    my @out = map { XIMS::ObjectType->new->data( %{$_} ) } @data;
    return @out;
}

=head2 data_formats()

=cut

sub data_formats {
    my $self = shift;
    my %args = @_;
    my $cache;
    $cache = 1 unless scalar keys %args > 0;
    no strict 'refs';
    if ( defined $cache and defined *{"XIMS::DATA_FORMATS"}{CODE} ) {
        return values %{ XIMS::DATA_FORMATS() };
    }
    my @data = $self->getDataFormat(%args);
    require XIMS::DataFormat;
    my @out = map { XIMS::DataFormat->new->data( %{$_} ) } @data;
    return @out;
}

=head2 languages()

=cut

sub languages {
    my $self = shift;
    my %args = @_;
    my $cache;
    $cache = 1 unless scalar keys %args > 0;
    no strict 'refs';
    if ( defined $cache and defined *{"XIMS::LANGUAGES"}{CODE} ) {
        return values %{ XIMS::LANGUAGES() };
    }
    my @data = $self->getLanguage(%args);
    require XIMS::Language;
    my @out = map { XIMS::Language->new->data( %{$_} ) } @data;
    return @out;
}


## use critic

=pod

user-related

=cut

=head2 users()

list all users

=cut

sub users {
    my $self = shift;
    my @data = $self->getUser();
    require XIMS::User;
    my @out = map { XIMS::User->new->data( %{$_} ) } @data;
    return @out;
}

=head2 admins()

list all admins

=cut

sub admins {
    my $self = shift;
    my @data = $self->getUser( admin => 1 );
    my @out  = map { XIMS::User->new->data( %{$_} ) } @data;
    return @out;
}

=pod

 object-related

=cut

=head2 objects()

 list all objects

=cut

sub objects {
    my $self = shift;
    if ( wantarray() ) {
        my @data = $self->getObject(@_);
        require XIMS::Object;
        my @out = map { XIMS::Object->new->data( %{$_} ) } @data;
        return @out;
    }
    else {
        return $self->getObject(@_);
    }
}

=head2 trashcan()

the global dump site

=cut

sub trashcan {
    my $self = shift;
    my %args = @_;
    $args{marked_deleted} = 1;
    if ( wantarray() ) {
        my @data = $self->getObject(@_);
        require XIMS::Object;
        my @out = map { XIMS::Object->new->data( %{$_} ) } @data;
        return @out;
    }
    else {
        return $self->getObject(@_);
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

