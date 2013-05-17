

=head1 NAME

XIMS::Exporter::Document2.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Exporter::Document2;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::Document2;

use common::sense;
use XIMS::Exporter;
use parent qw( XIMS::Exporter::Document );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

#
# override here (create, remove, sax filters, ...)
#

1;


__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Write me.

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

