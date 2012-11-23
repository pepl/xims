
=head1 NAME

XIMS::Importer::FileSystem::Binary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem::Binary;

=head1 DESCRIPTION

This module implements the importer's methods related to the handling of
binary files.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem::Binary;

use strict;
use parent qw( XIMS::Importer::FileSystem );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 handle_data()

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data($location);

    my $data = $self->get_binref($location);
    $object->body($$data);
    undef $data;

    return $object;
}

=head2 get_binref()

=cut

sub get_binref {
    my $self = shift;
    my $file = shift;
    open( my $FILE, '<', $file ) || die "could not open $file: $!";

    # switch off perls auto encoding
    binmode($FILE);
    my $contents;
    while ( read( $FILE, my $buff, 16 * 2**10 ) ) {
        $contents .= $buff;
    }
    close $FILE;
    return \$contents;
}

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

