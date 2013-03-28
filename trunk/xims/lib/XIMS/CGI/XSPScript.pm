
=head1 NAME

xspscript::dummy -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use xspscript::dummy;

=head1 DESCRIPTION

It is based on XIMS::CGI::XML.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::XSPScript;

use common::sense;
use parent qw( XIMS::CGI::XML );
use Apache;
use AxKit;
use Apache::AxKit::ConfigReader;
use Apache::AxKit::Language::XSP;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          test_wellformedness
          process_xsp
          )
        );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    if ( $ctxt->object->attribute_by_key( 'processxsp' ) == 1
         and not defined $self->param('process_xsp')
         and not defined $self->param('do_not_process_xsp') ) {

        my $redirect_path = $self->redirect_uri( $ctxt, $ctxt->object->id() );
        if ( $redirect_path =~ /\?/ ) {
            $redirect_path .= ';';
        }
        else {
            $redirect_path .= '?';
        }

        $self->redirect( $redirect_path . "process_xsp=1" );
        return 1;
    }

    return $self->SUPER::event_default( $ctxt );
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $processxsp  = $self->param( 'processxsp' );
    if ( defined $processxsp ) {
        XIMS::Debug( 6, "processxsp: $processxsp" );
        if ( $processxsp eq 'true' ) {
            $ctxt->object->attribute( processxsp => '1' );
        }
        elsif ( $processxsp eq 'false' ) {
            $ctxt->object->attribute( processxsp => '0' );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

=head2 event_process_xsp()

=cut

sub event_process_xsp {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $object = $ctxt->object();
    my $r = Apache->request;

    # having to encode here sucks
    my $body =  XIMS::DBENCODING() ? XML::LibXML::encodeToUTF8( XIMS::DBENCODING(), $object->body() ) : $object->body();

    $r->pnotes( 'xml_string', $body );

    my $dom_tree;

    # reusing AxKit's Configreader
    $AxKit::Cfg = Apache::AxKit::ConfigReader->new($r);

    # using dummy-provider-class needed for key()-method
    my $xml = xspscript::dummy->new($object->location());

    # there's the magic
    Apache::AxKit::Language::XSP::handler(undef, $r, $xml);

    # The XSP handler store its result in pnotes
    my $dom_tree = $r->pnotes('dom_tree');

    $dom_tree->setEncoding(XIMS::DBENCODING()) if XIMS::DBENCODING();

    my $newbody = $dom_tree->toString();

    # :/
    $newbody =~ s/^<\?xml.*//;
    $object->body( $newbody );

    return 0;
}

package xspscript::dummy;

sub new {
    my $class = shift;
    my $key   = shift;
    my $self = bless { key => $key }, $class;

    return $self;
}

sub key { $_[0]->{key} }
sub mtime { time }
sub has_changed { 1 }

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

