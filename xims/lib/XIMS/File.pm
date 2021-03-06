
=head1 NAME

XIMS::File

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::File;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::File;

use common::sense;
use parent qw( XIMS::Object );
use Time::Piece;
use POSIX qw(setlocale LC_TIME);


=head2 content_field()

  Force 'binfile'. The body of XIMS::File objects should never go into a clob
  or text column.

=cut

sub content_field { return 'binfile';}

=head2 mtime()

Returns $self->last_modification_timestamp in RFC 1123 format.

=cut

sub mtime {
    my $self    = shift;

    my $mtime = Time::Piece->strptime($self->last_modification_timestamp , "%Y-%m-%d %H:%M:%S");

    # TZ correction
    $mtime -= localtime->tzoffset;

    # Locale-fu :-/
    my $olc = setlocale( LC_TIME );
    setlocale( LC_TIME, 'C' );
    my $rv = $mtime->strftime("%a, %d %b %Y %H:%M:%S GMT");
    setlocale( LC_TIME, $olc );

    return $rv;
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

Copyright (c) 2002-2017 The XIMS Project.

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

