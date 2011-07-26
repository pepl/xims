
=head1 NAME

XIMS::CGI::JavaScript -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::JavaScript;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::JavaScript;

use strict;
use base qw( XIMS::CGI XIMS::CGI::Text );
#use CSS::Tiny;
#use Text::Iconv;
#use Encode;
#use Text::Template;
#use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
	
	my $self = shift;
	$self->SUPER::registerEvents(
                                'create',
                                'edit',
								'store',
								'publish',
                                'publish_prompt',
                                'unpublish',
								'obj_acllist',
                                'obj_acllight',
                                'obj_aclgrant',
                                'obj_aclrevoke',
								'pub_preview',
                                @_
                                );
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );
	# $ctxt->properties->application->style( "edit" );

    $self->resolve_content( $ctxt, [ qw( CSS_ID ) ] );

    return 0;
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );
	# $ctxt->properties->application->style( "create" );

    # look for inherited CSS assignments
    if ( not defined $ctxt->object->css_id() ) {
        my $css = $ctxt->object->css;
        $ctxt->object->css_id( $css->id ) if defined $css;
    }

    $self->resolve_content( $ctxt, [ qw( CSS_ID ) ] );

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
        $ctxt->object->attribute( minify => '0' );
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
        if ( defined $body and length $body ) {
            if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
                $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
            }
        }
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

=head2 private functions/methods

=over

=item _set_wysiwyg_editor()

=back

=cut

sub _set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor = $self->cookie($cookiename);
	# OVERRIDE for TESTING
	# $editor = 'codemirror';
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        # $editor = undef;
		$editor = 'codemirror';
    }
    elsif ($editor eq 'wepro') { 
        # we just dumped eWebEditPro, now change the remaining cookies
        # $editor = 'tinymce';
    	$editor = 'codemirror';
	}
	elsif ($editor eq 'tinymce') {
		# apply codemirror for syntax highlighting
		$editor = 'codemirror';
	}
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        # $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
		$editor = 'codemirror';
		if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
             # $editor = 'tinymce';
			 $editor = 'codemirror';
        }
        my $cookie = $self->cookie( -name    => $cookiename,
                                    -value   => $editor,
                                    -expires => "+2160h"); # 90 days
        $ctxt->properties->application->cookie( $cookie );
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
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

