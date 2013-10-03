
=head1 NAME

XIMS::AbstractClass -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::AbstractClass;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::AbstractClass;

use common::sense;
use XIMS;


=head2 data()

=cut

sub data {
    my $self = shift;
    my %args = @_;

    # if we were passed data, load the object from it.
    if ( scalar( keys( %args ) ) > 0 ) {
        # make sure those two ids come first, since things like body() depend on them
        $self->{data_format_id} = delete $args{data_format_id} if $args{data_format_id};
        $self->{object_type_id} = delete $args{object_type_id} if $args{object_type_id};
        foreach my $field ( keys ( %args ) ) {
            my ( $field_method, $r_type ) = reverse ( split /\./, $field );
            $field_method = 'document_id' if $field_method eq 'id' and $r_type and $r_type eq 'document';
            $field_method = 'body' if $field_method eq 'binfile';
            # location_path is not really writable, to make data() still work, check for it here
            if ( (defined $r_type and defined $field_method) and ($r_type eq 'document' and $field_method eq 'location_path') ) {
                $self->{location_path} = $args{$field};
            }
            else {
                $self->$field_method( $args{$field} ) if $self->can( $field_method );
            }
        }
        # this allows the friendly $user = XIMS::User->new->data( %hash ) idiom to work
        # for automated creation.
        return $self;
    }

    # otherwise, spin the public fields out to a hash and return it
    my %data = ();

    my $body_hack = 0;
    if ( $self->isa('XIMS::Object') and $self->content_field eq 'binfile') {
        $body_hack++;
    }

    foreach ( $self->fields() ) {
        if ( $_ eq 'body' and $body_hack > 0 ) {
            $data{binfile} = $self->$_;
        }
        else {
            $data{$_} = $self->$_;
        }
    }
    return %data;
}

=head2 data_provider()

=cut

sub data_provider { XIMS::DATAPROVIDER() }



=head2    XIMS::Foo->new( %args );

=head3 Parameter

    %args: If $args{id} or $args{name} is given, a lookup of an already
           existing object will be tried. Otherwise, an object blessed
           into the caller's object class with the specific resource
           type properties given in %args will be returned.

=head3 Returns

    $object: XIMS::Foo instance

=head3 Description

Generic constructor for XIMS resource types which may be looked up
by 'id' or 'name'. This method is designed to be inherited by the
resource type subclasses.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{name} ) ) {
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get'.$rt;
            my $data = $self->data_provider->$method( %args );
            if ( defined( $data )) {
               $self->data( %{$data} );
            }
            else {
                return;
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}



=head2    $object->create();

=head3 Parameter

    none

=head3 Returns

    $id: id of an newly created object.

=head3 Description

Generic method for creating objects using XIMS::DataProvider. This
method is designed to be inherited by the resource type subclasses.

=cut

sub create {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'create'.$rt;
    my $id = $self->data_provider->$method( $self->data());
    $self->id( $id );
    return $id;
}



=head2    $object->delete();

=head3 Parameter

    none

=head3 Returns

    1 on success, undef on failure

=head3 Description

Generic method for deleting objects using XIMS::DataProvider. This
method is designed to be inherited by the resource type subclasses.

=cut

sub delete {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'delete'.$rt;
    my $retval = $self->data_provider->$method( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } $self->fields();
        return 1;
    }
    else {
       return;
    }
}



=head2    $object->update();

=head3 Parameter

    none

=head3 Returns

    count of updated rows

=head3 Description

Generic method for updating objects using XIMS::DataProvider. This
method is designed to be inherited by the resource type subclasses.

=cut

sub update {
    my $self = shift;
    my $rt = ref($self);
    $rt =~ s/.*://;
    my $method = 'update'.$rt;
    return $self->data_provider->$method( $self->data() );
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

