
=head1 NAME

XIMS::Exporter::VLibraryItem::Document

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Exporter::VLibraryItem::Document;

=head1 DESCRIPTION

Exporter subclass for VLibraryItem::Documents.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::VLibraryItem::Document;

use common::sense;
use XIMS::Exporter;
use parent qw( XIMS::Exporter::Document );
use XIMS::ObjectType;
use XIMS::ObjectPriv;
use XIMS::SAX::Generator::Exporter::VLibraryItem;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 create()

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    return unless $self->SUPER::create(%param);

    # Grant to the public user
    $self->{Object}->grant_user_privileges(
        grantee        => XIMS::PUBLICUSERID(),
        privilege_mask => (XIMS::Privileges::VIEW),
        grantor        => $self->{User}->id()
    );

    # publish the children to the same directory as the object itself
    my @children = $self->{Object}->children_granted( User => $self->{User} );
    if ( @children and scalar @children ) {
        my $helper = XIMS::Exporter::Helper->new();
        my $location;
        foreach my $kind (@children) {

            # but don't automatically publish DocumentLinks
            next if $kind->object_type->name eq 'URLLink';

            my $reaper = $helper->exporterclass(
                Provider       => $self->{Provider},
                User           => $self->{User},
                Object         => $kind,
                exportfilename => $self->{Basedir} . '/' . $kind->location()
            );
            if ( $reaper and $reaper->create() ) {
                XIMS::Debug( 4, "published " . $kind->location() );
            }
            else {
                XIMS::Debug( 2, "could not publish " . $kind->location() );
            }
        }
    }

    return 1;
}

=head2 remove()

=cut

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    # remove grant to the public user
    my $privs_object = XIMS::ObjectPriv->new(
        grantee_id => XIMS::PUBLICUSERID(),
        content_id => $self->{Object}->id()
    );
    
    $privs_object->delete() if $privs_object;

    # unpublish published children
    my @children = $self->{Object}->children_granted(
        User      => $self->{User},
        published => 1
    );

    if ( @children and scalar @children ) {
        my $helper = XIMS::Exporter::Helper->new();
        my $location;
        foreach my $kind (@children) {
            my $reaper = $helper->exporterclass(
                Provider       => $self->{Provider},
                User           => $self->{User},
                Object         => $kind,
                exportfilename => $self->{Basedir} . '/' . $kind->location()
            );
            if ( $reaper and $reaper->remove() ) {
                XIMS::Debug( 4, "unpublished " . $kind->location() );
            }
            else {
                XIMS::Debug( 2, "could not unpublish " . $kind->location() );
            }
        }
    }

    return $self->SUPER::remove(%param);
}

=head2 set_sax_generator()

=cut

sub set_sax_generator {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return XIMS::SAX::Generator::Exporter::VLibraryItem->new();
}

=head2 update_related()

=cut

sub update_related { return; }

=head2 update_parent()

=cut

sub update_parent { return; }

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

