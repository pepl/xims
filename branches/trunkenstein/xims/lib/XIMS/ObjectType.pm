
=head1 NAME

XIMS::ObjectType

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::ObjectType;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::ObjectType;

use common::sense;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );

our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    return 'ObjectType';
}

__PACKAGE__->mk_accessors( @Fields );



=head2    new()

=head3 Parameter

    %args: If $args{id} or $args{name} or $args{fullname} is given, a lookup of
           an already existing object will be tried. Otherwise, an object
           blessed into the caller's object class with the specific resource
           type properties given in %args will be returned.

=head3 Returns

    $object: XIMS::ObjectType instance

=head3 Description

XIMS::ObjectType->new( %args );

Constructor for XIMS object types which may be looked up
by 'id', 'name', or 'fullname'. If 'name' is given as look up key and two object types
with the same 'name' but a different 'fullname' exist, undef is returned. You will have
to use 'fullname' in such cases.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{name} ) or defined( $args{fullname} ) ) {
            $args{name} = ( split /::/, $args{fullname} )[-1] if defined( $args{fullname} );
            my @real_ot = $self->data_provider->getObjectType( %args );
            if ( scalar @real_ot == 1 ) {
                $self->data( %{$real_ot[0]} );
            }
            elsif ( defined( $args{fullname} ) ) {
                my @ids = map { $_->{'objecttype.id'} } @real_ot;
                my @ots = $self->data_provider->object_types( id => \@ids );
                foreach my $ot ( @ots ) {
                    return $ot if $ot->fullname() eq $args{fullname};
                }
            }
            elsif ( scalar @real_ot > 1 and exists $args{name} ) {
                XIMS::Debug( 2, "ambigous object type lookup. try looking up using 'fullname'" );
                return;
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



=head2    fullname()

=head3 Parameter

    none

=head3 Returns

    $fullname : '::'-separated fullname of the objectype including
                the names of its ancestors

=head3 Description

my $fullname = $objecttype->fullname();

Returns the fullname of the object type, separated by '::' including
the names of the object type's ancestors.

=cut

sub fullname {
    my $self = shift;

    my @ancestors = @{$self->ancestors()};
    if ( scalar @ancestors ) {
        @ancestors = map { $_->name } @ancestors;
        return join('::', @ancestors) . '::' . $self->name();
    }
    else {
        return $self->name();
    }
}




=head2    ancestors()

=head3 Parameter

    none

=head3 Returns

    $ancestors : Reference to Array of XIMS::ObjectTypes

=head3 Description

my $ancestors = $objecttype->ancestors();

Returns ancestor object types.

=cut

sub ancestors {
    my $self = shift;
    my $objecttype = (shift || $self);
    my @ancestors = @_;
    if ( $objecttype->parent_id() and $objecttype->id() != $objecttype->parent_id() ) {
        my $parent = XIMS::ObjectType->new( id => $objecttype->parent_id() );
        push @ancestors, $parent;
        $self->ancestors( $parent, @ancestors );
    }
    else {
        return [reverse @ancestors];
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

Copyright (c) 2002-2015 The XIMS Project.

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

