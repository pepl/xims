
=head1 NAME

XIMS::RefLibAuthorMap -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::RefLibAuthorMap;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::RefLibAuthorMap;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

__PACKAGE__->mk_accessors( @Fields );



=head2    my $authormap = XIMS::RefLibAuthorMap->new( [ %args ] );

=head3 Parameter

    $args{ id }                  :  id of an existing mapping.
    $args{ reference_id }        :  reference_id of a RefLibReference. To be
                                    used together with $args{author_id} and
                                    $args{role} to look up an existing mapping.
    $args{ author_id }           :  id of a VLibAuthor. To be used together
                                    with $args{reference_id} and $args{role} to
                                    look up an existing mapping.
    $args{ role }                :  Role (integer) of the author in the mapping.
                                    To be used together with $args{reference_id}
                                    and $args{author_id} to look up an existing
                                    mapping.

=head3 Returns

    $authormap    : Instance of XIMS::RefLibAuthorMap

=head3 Description

Fetches existing mappings or creates a new instance of XIMS::RefLibAuthorMap for
ReferenceLibrary <-> VLibAuthor mapping. Args are optional.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{reference_id}) and defined( $args{author_id} ) and defined( $args{role} ) ) ) {
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

sub delete {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # Store values
    my $position = $self->position();
    my $reference_id = $self->reference_id();
    my $role = $self->role();

    # Delete the mapping
    my $retval = $self->SUPER::delete( @_ );

    # Close position gap
    my $data = $self->data_provider->dbh->do_update( sql => [ qq{UPDATE cireflib_authormap
                                                  SET
                                                    position = position - 1
                                                  WHERE
                                                    position > ?
                                                    AND reference_id = ?
                                                    AND role = ?
                                                    }
                                                , $position
                                                , $reference_id
                                                , $role
                                           ]);
    unless ( defined $data ) {
        XIMS::Debug( 3, "Could not close position gap");
    }

    return $retval;
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

