
=head1 NAME

XIMS::SimpleDBItem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SimpleDBItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SimpleDBItem;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::SimpleDBMember;
use XIMS::SimpleDBMemberProperty;
use XIMS::SimpleDBMemberPropertyValue;




=head2    my $item = XIMS::SimpleDBItem->new( [ %args ] )

=head3 Parameter

    %args                  (optional) :  Takes the same arguments as its super
                                         class XIMS::Object

=head3 Returns

    $item    : instance of XIMS::SimpleDBMemberItem

=head3 Description

Fetches existing objects or creates a new instance of XIMS::SimpleDBMemberItem
for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}




=head2    my $id = $item->create( [ %args ] );

=head3 Parameter

    $args{ User }    (optional) :  XIMS::User instance. If $args{User} is not
                                   given, the user has to be set at object
                                   instantiation.
                     (Example XIMS::Object->new( User => $user, %args ) )

=head3 Returns

    $id    : Content id of newly created object

=head3 Description

Returns the content id of the newly created object, undef on failure.
$args{User}, or, if that is not given, $object->User() will be used to set last
modifier, creator, and owner metadata. Sets the values of the mapped
SimpleDBMemberProperties where part_of_title is set to 1 as object title.

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $id;
    if ( $id = $self->SUPER::create( @_ ) ) {
        $self->update( no_modder => 1 );
        return $id;
    }
}




=head2    my @rowcount = $item->update( [ %args ] );

=head3 Parameter

    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is
                                       not given, the user has to be set at
                                       object instantiation.
                                       (Example XIMS::Object->new( User => $user ) )
    $args{ no_modder }   (optional) :  If set, last modifier and last
                                       modification timestamp properties will
                                       not be set.

=head3 Returns

    @rowcount : Array with one or two entries. Two if both 'Content' and
    'Document' have been updated, one if only 'Document' resource type has
    been updated. Each entry is true if update was successful, false otherwise.

=head3 Description

Updates object in database and sets last modifier properties unless
$args{no_modder} has been set.
Sets the values of the mapped SimpleDBMemberProperties where part_of_title is
set to 1 as object title.

=cut

sub update {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $member = $self->member();
    if ( defined $member ) {
        my @title_props = $self->property_list( part_of_title => 1 );
        my @property_ids = map { $_->id() } @title_props;
        my @unsorted_data = $self->data_provider->getSimpleDBMemberPropertyValue( member_id => $member->id(), property_id => \@property_ids, properties => [ qw( value property_id ) ] );

        # Prepare to sort property values by property position
        my %data = map { $_->{'simpledbmemberpropertyvalue.property_id'} => $_->{'simpledbmemberpropertyvalue.value'} } @unsorted_data;
        my @sorted_values;
        foreach my $prop ( sort { $a->position() <=> $b->position() } @title_props ) {
            push (@sorted_values, $data{$prop->id()});
        }
        if ( @sorted_values ) {
            $self->title( join(', ', @sorted_values) );
        }
        else {
            XIMS::Debug( 3, "No property set to be part of title! Setting a dummy title!" );
            $self->title( "dummytitle" );
        }
    }

    return $self->SUPER::update( @_ );
}



=head2    my @property_list = $item->property_list( [ %args ] );

=head3 Parameter

    $args{part_of_title}    (optional)    : Filter properties by part_of_title
                                            property
    $args{mandatory}        (optional)    : Filter properties by mandatory
                                            property
    $args{gopublic}         (optional)    : Filter properties by gopublic property

=head3 Returns

    @property_list  : Array of mapped member properties
                      (XIMS::SimpleDBMemberProperty instances)

=head3 Description

Fetch mapped properties assigned to the SimpleDB where $item is part of

=cut

sub property_list {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $simpledb = $self->parent();
    bless $simpledb, 'XIMS::SimpleDB'; # parent isa XIMS::Object
    return $simpledb->mapped_member_properties( @_ );
}



=head2    my @property_values = $item->property_values();

=head3 Parameter

    none

=head3 Returns

    @property_values    : Array of XIMS::SimpleDBMemberPropertyValue instances

=head3 Description

Fetch property values for the current $item

=cut

sub property_values {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $member = $self->member();
    my $member_id;
    return () unless ( defined $member and $member_id = $member->id );

    $args{member_id} = $member_id;
    $args{properties} = [ qw( property_id value ) ];

    my @data = $self->data_provider->getSimpleDBMemberPropertyValue( %args );
    my @out = map { XIMS::SimpleDBMemberPropertyValue->new->data( %{$_} ) } @data;
    return @out;
}

=head2 content_field()

=cut

sub content_field {
    return 'binfile';
}



=head2    my $member = $item->member( [ $member ] );

=head3 Parameter

    $member                 (optional) :

=head3 Returns

    $member    : instance of XIMS::SimpleDBMember

=head3 Description

Helper method to fetch the XIMS::SimpleDBMember entry for the current object

=cut

sub member {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $member = shift;

    if ( defined $member and $member->isa( 'XIMS::SimpleDBMember' ) ) {
        $self->{member} = $member;
        return $member;
    }
    else {
        return $self->{member} if defined $self->{member};
        $member = XIMS::SimpleDBMember->new( document_id => $self->document_id() );
        if ( defined $member ) {
            $self->{member} = $member;
            return $member;
        }
        else {
            return;
        }
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

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

