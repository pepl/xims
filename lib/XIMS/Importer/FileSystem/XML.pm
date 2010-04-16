
=head1 NAME

XIMS::Importer::FileSystem::XML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem::XML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem::XML;

use strict;
use base qw(XIMS::Importer::FileSystem XIMS::Importer::Object::XML);
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 handle_data()

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my $dontbody = shift;

    my $object = $self->SUPER::handle_data( $location );

    unless ( $dontbody ) {
        my $parser = XML::LibXML->new();
        my $doc;
        my $strref = $self->get_strref( $location );
        eval {
            $doc = $parser->parse_string( $$strref );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $location" );
            return;
        }
        $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
        $object->body( $doc->toString() );
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
    return $self->SUPER::get_rootelement( $strref, @_ );
}


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

Copyright (c) 2002-2009 The XIMS Project.

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

