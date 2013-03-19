
=head1 NAME

XIMS::Importer::Object::XMLChunk -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::Object::XMLChunk;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::Object::XMLChunk;

use common::sense;
use parent qw( XIMS::Importer::Object );
use XIMS::Object;
use XML::LibXML;

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
        $wbdata = $object->balance_string( $$strref );
        my $parser = XML::LibXML->new();
        my $encoding ||= ( XIMS::DBENCODING() || 'UTF-8' );
        eval {
            $doc = $parser->parse_xml_chunk( $wbdata, $encoding );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return;
        }
    }

    return $doc;
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

