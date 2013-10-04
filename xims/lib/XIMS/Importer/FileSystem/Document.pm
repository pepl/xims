
=head1 NAME

XIMS::Importer::FileSystem::Document

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem::Document;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem::Document;

use common::sense;
use parent qw( XIMS::Importer::FileSystem::XMLChunk );
use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...
use XML::LibXML::Iterator;
use XIMS::Object;
use Encode;


=head2 handle_data()

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location, 1 );
    my $root = $self->get_rootelement( $location, nochunk => 1 );
    return unless $root;

    my %importmap = (
        keywords   => "//*[local-name() = 'subject']|/html/head/meta[\@name='keywords']/\@content",
        title      => "//*[local-name() = 'title']",
        body       => "*[local-name() = 'body']",
        abstract   => '//*[local-name() = "description"]/*[local-name() = "description"]|/html/head/meta[@name="description"]/@content'
                    );

    foreach my $field ( keys %importmap ) {
        my ($n) = $root->findnodes( $importmap{$field} );
        if ( defined $n ) {
            my $value = "";
            my @cnodes = $n->childNodes;
            if ( scalar @cnodes > 1 ) {
                map { $value .= $_->toString(0,1) } $n->childNodes;
            }
            else {
                $value = $n->textContent();
            }
            if ( length $value ) {
                # $doc->setEncoding() does not work depending on the libxml version :-/
                $value = XIMS::utf8_sanitize( $value );
                $object->$field( XIMS::Entities::decode( $value ) );
            }
        }
    }

    return $object;
}

=head2 get_rootelement()

=cut

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my %args = @_;

    my $strref = $self->get_strref( $location );

    # Most users will not have their legacy HTML documents encoded
    # in UTF-8. Therefore, we try to encode the documents to UTF-8 for them.
    my $data = XIMS::utf8_sanitize( $$strref );

    my $wbdata;
    my $object = XIMS::Object->new();
    my $doc;
    if ( not $doc = $object->balanced_string( $data, %args ) ) {
        $wbdata = $object->balance_string( $data, keephtmlheader => 1 );
        my $parser = XML::LibXML->new();
        eval {
            $doc = $parser->parse_string( $wbdata );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return;
        }
    }

    # lowercase element and attribute names
    my $iter = XML::LibXML::Iterator->new( $doc );
    $iter->iterate( sub {
                        shift;
                        $_[0]->nodeType == XML_ELEMENT_NODE &&
                            map {
                                    $_->nodeType != XML_NAMESPACE_DECL &&
                                    $_->setNodeName( lc $_->nodeName )
                                }
                            $_[0], $_[0]->attributes;
                        } );

    $doc->setEncoding( 'UTF-8' );
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

