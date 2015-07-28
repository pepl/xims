
=head1 NAME

XIMS::CGI::CSS

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::CSS;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::CSS;

use common::sense;
use parent qw( XIMS::CGI XIMS::CGI::Text );
use CSS::Tiny;
use Encode;
use Text::Template;
use Locale::TextDomain ('info.xims');


=head2 registerEvents()

=cut

sub registerEvents {
	
    $_[0]->SUPER::registerEvents( qw( parse_css ) );
	my $self = shift;
	$self->SUPER::registerEvents(
                                'create',
                                'edit',
								'store:POST',
								'publish:POST',
                                'publish_prompt',
                                'unpublish:POST',
								'obj_acllist',
                                'obj_acllight',
                                'obj_aclgrant:POST',
                                'obj_aclrevoke:POST',
								'pub_preview',
                                @_
                                );
}

=head2 event_parse_css()

=cut

sub event_parse_css {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $body = $ctxt->object->body();
    my $css = CSS::Tiny->read_string( $body );
    if ( $CSS::Tiny::errstr ) {
        $ctxt->session->error_msg( __"Parse failure" );
        $ctxt->session->verbose_msg( $CSS::Tiny::errstr );
    }
    else {
        $ctxt->session->message( __"Parse ok. Parsed CSS:" );
        $ctxt->session->verbose_msg( $css->write_string() );
    }

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "message_window_plain" );

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );

    return 0;
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    # This is actually used in the derived XIMS::CGI::JavaScript and
    # XIMS::CGI::CSS classes.
    if ( $self->param('minify') eq 'true' ) {
        $ctxt->object->attribute( minify => '1' );
    }
    else {
        $ctxt->object->attribute( minify => undef );
    }

    my $body;
    my $fh = $self->upload( 'file' );
    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    else {
        $body = $self->param( 'body' );
    }

    if ( defined $body and length $body ) {
        my $object = $ctxt->object();
        $object->body( XIMS::xml_escape( $body ) );
    }
	
	# taken from XML.pm
	# $body = $self->param( 'body' );
	# my $object = $ctxt->object();
	
    return $self->SUPER::event_store( $ctxt );
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

Copyright (c) 2002-2015 The XIMS Project.

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

