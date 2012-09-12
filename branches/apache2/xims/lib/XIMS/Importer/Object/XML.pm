
=head1 NAME

XIMS::Importer::Object::XML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::Object::XML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::Object::XML;

use strict;
use base qw( XIMS::Importer::Object );
use XIMS::Object;
use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 get_rootelement()

=cut

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $strref = shift;
    my %args = @_;

    my $wbdata;
    my $object = XIMS::Object->new();
    my $doc;
    if ( not $doc = $object->balanced_string( $$strref, %args ) ) {
        $wbdata = $object->balance_string( $$strref, keephtmlheader => 1 );
        my $parser = XML::LibXML->new();
        my $doc;
        eval {
            $doc = $parser->parse_string( $wbdata );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return;
        }
    }

    $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
    return $doc->documentElement();
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

