# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::DataProvider;

use strict;
use XIMS;
#use Data::Dumper;
use XIMS::Names;

# following uses are for the classed we bless into
use XIMS::ObjectType;
use vars qw/$AUTOLOAD/;

# The idea here is to create a generic bridge between the data store and the
# top-level XIMS Object classes. We try to lighten the Object classes that rely
# the DP by deciding here how to organise the arguments passed in from those clases.
#
# Peer-level methods (those implemented by this class) can use this factory to prepare
# the %conditions and %properties of non-Object related methods, but its probably
# better if they just set those argument and call the Driver directly.
#

sub request_factory {
    my $self = shift;
    my $r_type = shift;
    my $method_type = shift;
    my %args = @_;
    my %properties;
    my %conditions;
    #my @property_names = ();
    my %request_params = ();

    my $lookup = lc( $r_type );

    # ubu: we can prolly delete the first branch in this fork soon.
    if ( defined $args{$lookup} ) {
        # if we have been passed an intance of one of the basic resource types
        # just extract the properties from it.
        %request_params = %{$args{$lookup}};
    }
    else {
        %request_params = %args;
    }

    if ( $method_type eq 'create' or $method_type eq 'update') {
        foreach my $k ( keys( %request_params )) {
            my $outname = XIMS::Names::get_URI( $r_type, $k );
            $properties{$outname} = $request_params{$k} if XIMS::Names::valid_property( $r_type, $outname );
            # ubu: refactor
            if ( ( $k eq 'id' and $method_type eq 'update') ||
                 ( ( $k eq 'grantee_id' or $k eq 'content_id') and $method_type eq 'update' and $r_type eq 'ObjectPriv' )
               ) {
                $conditions{$outname} = delete $properties{$outname};
            }
            elsif ($k eq 'document_id' and $method_type eq 'update') {
                $conditions{'document.id'} = $request_params{$k};
            }
        }

        # now, fill in the blanks
        foreach my $prop (@{XIMS::Names::property_list( $r_type )}) {
            next if defined( $properties{$prop} or $prop =~ /\.id$/);
            $properties{$prop} = undef;
        }

        if ( $method_type eq 'update' ) {
            #warn  "UPDATE properties: " . Dumper( \%properties ) . "\nconditions: ". Dumper( \%conditions );
        }
    }
    else {
        foreach my $k ( keys( %request_params )) {
            my $outname = XIMS::Names::get_URI( $r_type, $k );
            $conditions{$outname} = $request_params{$k} if XIMS::Names::valid_property( $r_type, $outname );
        }

        # additional properties from the Driver to cover data-centric conditions (relational
        # joins in the DBI Driver, for example).
        my $add_conds = $self->{Driver}->property_relationships( $r_type, $method_type );
        if (defined($add_conds)) {
            foreach my $k ( keys( %{$add_conds} )) {
                $conditions{$k} = $add_conds->{$k};
            }
        }

        # let classes ask for only the data they want for get() (for special cases only!!)
        if ( defined( $args{properties} and $method_type eq 'get') ) {
           my @prop_names = map{ XIMS::Names::get_URI( $r_type, $_) } @{$args{properties}};
           %properties = map { $_, 1 } @prop_names;
        }
    }

    unless ( scalar( keys ( %properties ) ) > 0 ) {
        my @prop_names = map{ XIMS::Names::get_URI( $r_type, $_) } @{XIMS::Names::property_list( $r_type )};
        %properties = map { $_, 1 } @prop_names;
    }

    #warn "request factory: " . Dumper( \%properties ) . Dumper( \%conditions ) . "\n";
    return ( \%properties, \%conditions );
}

sub new {
    XIMS::Debug( 5, "called" );
    my $class  = shift;
    my $drvnme = shift || 'DBI';
    my $self   = undef;

    my $drvcls = 'XIMS::DataProvider::' . $drvnme;
    my $driver = undef;

    eval "require $drvcls"; # first load the driver class module
    if ( $@ ) {
        XIMS::Debug( 2, "driver class not found! Reason: $@" );
    }
    else {
        my $args = shift || {};
        $args->{dbuser}       = XIMS::DBUSER()       unless defined $args->{dbuser};
        $args->{dbpasswd}     = XIMS::DBPWD()        unless defined $args->{dbpasswd};
        $args->{dbdsn}        = XIMS::DBDSN()        unless defined $args->{dbdsn};
        $args->{dbsessionopt} = XIMS::DBSESSIONOPT() unless defined $args->{dbsessionopt};
        $args->{dbdopt}       = XIMS::DBDOPT()       unless defined $args->{dbdopt};

        $driver = $drvcls->new( %{$args} );

        if ( $driver ) {
            $self = bless {} , $class;
            $self->{Driver} = $driver;
            XIMS::Debug( 4, "init complete" );
        }
        else {
            XIMS::Debug( 1, "driver class $drvcls did not initialize!" );
        }
    }
    XIMS::Debug( 5, "done" );
    return $self;
}

sub AUTOLOAD {
    my $self = shift;
    my (undef, $called_sub) = ($AUTOLOAD =~ /(.*)::(.*)/);
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
       if ( $method = $self->{Driver}->can( $called_sub ) ) {
           $data = $method->( $self->{Driver}, @_ );
       }
       elsif ( grep { $_ eq $r_type } XIMS::Names::resource_types() ) {
           my ( $properties, $conditions ) = $self->request_factory($r_type, $action, @_);
           $data = $self->{Driver}->$action( properties => $properties, conditions => $conditions );
       }
    }
    # short circuit for free access to low-level Driver methods.
    elsif ( $method = $self->{Driver}->can( $called_sub ) ) {
       #warn "Calling Driver method $called_sub directly, passing @_ \n";
       $data = $method->( $self->{Driver}, @_ );
    }
    # finally, if no class can take the method, die appropriately
    else {
        my ($package, $filename, $line) = caller();
        die "Method $called_sub called by $package line $line not implemented by data provider. \n";
    }

    # fix-up the return values based on the calling method's expectation;
    if ( ref( $data ) eq 'ARRAY' ) {
        return wantarray() ? @{$data} : $data->[0];
    }
    else {
        return $data;
   }
}

# we need special cases here because content objects span mutiple tables
sub createObject {
    my $self = shift;
    my %doc_properties = ();
    my $body_data;
    my $update_body_method;

    my ( $properties, $conditions ) = $self->request_factory( 'Object', 'create', @_ );

    my @doc_keys = grep { (split /\./, $_)[0] eq 'document' } keys %{$properties};
    @doc_properties{@doc_keys} = delete @{$properties}{@doc_keys};

    $doc_properties{'document.id'} = 1;
    my $doc_id = $self->{Driver}->create( properties => \%doc_properties, conditions => {} );
    $properties->{'content.document_id'} = $doc_id;

    # nuttiness for Oracle's sorry @ss
    if ( defined( $properties->{'content.body'} ) ) {
        $update_body_method = 'update_content_body';
        $body_data = delete $properties->{'content.body'};
    }
    elsif ( defined( $properties->{'content.binfile'} ) ) {
        $update_body_method = 'update_content_binfile';
        $body_data = delete $properties->{'content.binfile'};
    }

    my $object_id = $self->{Driver}->create( properties => $properties, conditions => {} );

    if ( length( $body_data ) > 0 and defined( $object_id ) ) {
        $self->{Driver}->$update_body_method( $object_id, $body_data );
    }

    #warn "returning object_id: $object_id \n";
    return ( $object_id, $doc_id );
}

sub getObject {
    my $self = shift;
    my %args = @_;

    my $span_tables = 1;
    my ( $properties, $conditions ) = $self->request_factory( 'Object', 'get', %args );

    if ( defined( $args{properties} ) ) {
        #warn "explicit properties " . Dumper( $args{properties}  );
        my $doc_prop_count = grep{ (split /\./, $_)[0] eq 'document' } keys %{$properties};
        my $content_prop_count = grep{ (split /\./, $_)[0] eq 'content' } keys %{$properties};
        $span_tables-- unless $doc_prop_count > 0 and $content_prop_count > 0;
    }

    # remove the 'join' if we are only selecting data from one table or the other.
    if ( $span_tables == 0 and ref( $conditions->{'document.id'} ) ) {
        delete $conditions->{'document.id'};
    }

    my $data = $self->{Driver}->get( properties => $properties, conditions => $conditions );

    foreach my $obj ( @{$data} ) {
        if ( defined( $obj->{'content.binfile'} ) ) {
            $obj->{'content.body'} = delete $obj->{'content.binfile'}
        }
    }

    if ( ref( $data ) eq 'ARRAY' ) {
        return wantarray() ? @{$data} : $data->[0];
    }
    else {
        return $data;
    }
}


sub updateObject {
    my $self = shift;
    my %doc_properties = ();
    my %doc_conditions = ();
    my $body_data;
    my $update_body_method;

    my @ret;
    my ( $properties, $conditions ) = $self->request_factory( 'Object', 'update', @_ );

    my @doc_prop_keys = grep { (split /\./, $_)[0] eq 'document' } keys %{$properties};
    @doc_properties{@doc_prop_keys} = delete @{$properties}{@doc_prop_keys};

    my @doc_cond_keys = grep { (split /\./, $_)[0] eq 'document' } keys %{$conditions};
    @doc_conditions{@doc_cond_keys} = delete @{$conditions}{@doc_cond_keys};

    $doc_conditions{'document.id'} ||= $properties->{'content.document_id'} if $properties->{'content.document_id'};

    # update document table if wanted
    if ( scalar keys %doc_properties ) {
        push @ret, $self->{Driver}->update( properties => \%doc_properties, conditions => \%doc_conditions );
    }

    # return if we do not want to update the content table
    if ( not scalar keys %{$properties} ) {
        return @ret;
    }

    if ( defined( $properties->{'content.body'} ) ) {
        $update_body_method = 'update_content_body';
        $body_data = delete $properties->{'content.body'};
    }
    elsif ( defined( $properties->{'content.binfile'} ) ) {
        $update_body_method = 'update_content_binfile';
        $body_data = delete $properties->{'content.binfile'};
    }

    push @ret, $self->{Driver}->update( properties => $properties, conditions => $conditions );

    if ( length( $body_data ) > 0 and defined( $conditions->{'content.id'} ) ) {
        $self->{Driver}->$update_body_method( $conditions->{'content.id'}, $body_data );
    }

    return @ret;
}

sub deleteObject {
    my $self = shift;
    my %args = @_;

    $self->{Driver}->delete( properties => { 'document.id' => 1 },
                             conditions => { 'document.id' => $args{document_id} }
                           );

    $self->{Driver}->delete( properties => { 'content.id' => 1 },
                             conditions => { 'content.id' => $args{id} }
                           );
    return 1;
}

sub location_path {
    my $self = shift;
    my $obj;

    if ( scalar( @_ ) == 1 and ref( $_[0] ) ) {
        $obj = shift;
    }
    else {
        $obj = XIMS::Object->new( @_ );
    }

    # special case for the system root
    return '/root' if $obj->id() == 1;

    my @ancestors = $self->recurse_ancestor( $obj );

    #remove the system root from the list of ancestors
    shift @ancestors;

    my $path;
    if ( scalar( @ancestors ) > 0 ) {
        $path .= '/';
        $path .= join '/', map { $_->location() } @ancestors;
    }

    $path .= '/' . $obj->location();
    #warn "path returning $path \n";
    return $path;
}

sub location_path_relative {
    my $self = shift;
    my $relative_path = $self->location_path( @_ );
    # snip off the site portion of the path ('/site/somepath')
    $relative_path =~ s/^\/[^\/]+//;
    return $relative_path;
}

sub recurse_ancestor {
    my $self = shift;
    my $object = shift;
    my @ancestors = @_;
    #warn "testing id " . $object->id() . " (title: ". $object->title() . ") against " . $object->parent_id() . "\n";
    if ( $object->id() != $object->parent_id() ) {
        my $parent = XIMS::Object->new( id => $object->parent_id(), User => $object->User() );
        push @ancestors, $parent;
        $self->recurse_ancestor( $parent, @ancestors );
    }
    else {
        return reverse @ancestors;
    }
}

# abstract methods for easy access to all resources. Use get<ResouceType> instead for
# selection of specific objects, users, object_types, etc.

# list all object types, data_formats, etc.
sub object_types {
    my $self = shift;
    my @data = $self->getObjectType();
    my @out = map { XIMS::ObjectType->new->data( %{$_} ) } @data;
    return @out;
}

sub data_formats {
    my $self = shift;
    my @data = $self->getDataFormat();
    my @out = map { XIMS::DataFormat->new->data( %{$_} ) } @data;
    return @out;
}

##
# user-related
##

# list all users
sub users {
    my $self = shift;
    my @data = $self->getUser();
    my @out = map { XIMS::User->new->data( %{$_} ) } @data;
    return @out;
}

# list all admins
sub admins {
    my $self = shift;
    my @data = $self->getUser( admin => 1 );
    my @out = map { XIMS::User->new->data( %{$_} ) } @data;
    return @out;
}

##
# object-related
##

# list all objects
sub objects {
    my $self = shift;
    my @data = $self->getObject();
    my @out = map { XIMS::Object->new->data( %{$_} ) } @data;
    return @out;
}

# the global dump site
sub trashcan {
    my $self = shift;
    my @data = $self->getObject( marked_deleted => 1 );
    my @out = map { XIMS::Object->new->data( %{$_} ) } @data;
    return @out;
}

1;
