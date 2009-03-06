
=head1 NAME

XIMS::CGI::VLibraryItem::Document

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibraryItem::Document;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

# $Id $
package XIMS::CGI::VLibraryItem::Document;

use strict;
use base qw( XIMS::CGI::VLibraryItem );
use XIMS::VLibMeta;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create($ctxt);

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->escapebody(1);

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit($ctxt);
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor($ctxt);
    $ctxt->properties->application->style( "edit" . $ed );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $error_message = '';

    # Title, subject, keywords and abstract are mandatory
    return 0
      unless $self->init_store_object($ctxt)
      and defined $ctxt->object();

    my $trytobalance = $self->param('trytobalance');

    my $body = $self->param('body');

    my $object = $ctxt->object();

    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body =
              Text::Iconv->new( "UTF-8", XIMS::DBENCODING() )->convert($body);
        }

        # The HTMLArea WYSIWG-editor in combination with MSIE translates
        # relative paths in 'href' and 'src' attributes to their
        # '/goxims/content'-absolute path counterparts. Since we do not
        # want '/goxims/content' references. which will very likely
        # breaks after the content has been published, we have to mangle
        # with the 'href' and 'src' attributes.
        my $absolute_path =
          defined $object->id()
          ? $object->location_path()
          : ( $ctxt->parent->location_path() . '/' . $object->location() );
        $body =
          $self->_absrel_urlmangle( $ctxt, $body,
            '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE(),
            $absolute_path );

        my $oldbody = $object->body();
        if ( $trytobalance eq 'true' and $object->body($body) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
            if ( $object->store_diff_to_second_last( $oldbody, $body ) ) {
                XIMS::Debug( 4, "diff stored" );
            }
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
            if ( $object->store_diff_to_second_last( $oldbody, $body ) ) {
                XIMS::Debug( 4, "diff stored" );
            }
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            $self->sendError( $ctxt, "Document body could not be converted to"
                                   . "a well balanced string. Please consult "
                                   . "the User's Reference for information on "
                                   . "well-balanced document bodies." );
            return 0;
        }
    }

    $self->SUPER::event_store($ctxt);

    my $meta;

    if ( defined $object->document_id() ) {
        $meta = XIMS::VLibMeta->new( document_id => $object->document_id() );
    }
    else {
        $object = $ctxt->object();
    }

    $meta = XIMS::VLibMeta->new() unless defined $meta;

    # store publications, subjects, keywords, and authors
    foreach my $property (qw(subject keyword author publication)) {
        if ( $self->param("vl$property") ) {
            $self->_create_mapping_from_name( $ctxt->object(),
                                              ucfirst($property), 
                                              $self->param("vl$property") );
        }
    }

    # Store metadata (publisher, chronicle dates, etc)
    map { $meta->data( $_ => $self->param($_) ) if defined $self->param($_) }
      qw(publisher subtitle legalnotice bibliosource mediatype coverage audience);

    # For these, check date-format first
    foreach (qw(chronicle_from_date chronicle_to_date dc_date)) {
        if ( defined $self->param($_) ) {
            if ( $self->_isvaliddate( $self->param($_) ) ) {
                $meta->data( $_ => $self->param($_) );
            }
            else {
                $error_message =
                  $self->param($_)
                  . "is not a valid date or not in the correct format (YYYY-MM-DD)";
            }
        }
    }

    $object->vlemeta($meta);

    my $rdpath = $self->redirect_path($ctxt);

    if ( $self->param('proceed_to_edit') == 1 ) {
        $rdpath .=
          ( $self->redirect_path($ctxt) =~ /\?/ ) ? ';edit=1' : '?edit=1';
    }

    if ($error_message) {
        $self->sendError( $ctxt, $error_message );
        return 0;
    }
    else {
        $self->redirect($rdpath);
        return 1;
    }
}

=head2 private functions/methods

=over

=item _set_wysiwyg_editor()

=item _absrel_urlmangle()

=back

=cut

sub _set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor     = $self->cookie($cookiename);
    my $plain      = $self->param('plain');
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ( not( length $editor ) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
        if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
            $editor = 'htmlarea';
        }
        my $cookie = $self->cookie(
            -name    => $cookiename,
            -value   => $editor,
            -expires => "+2160h"
        );    # 90 days
        $ctxt->properties->application->cookie($cookie);
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
}

sub _absrel_urlmangle {
    my $self          = shift;
    my $ctxt          = shift;
    my $body          = shift;
    my $goximscontent = shift;
    my $absolute_path = shift;

    my $doclevels = split( '/', $absolute_path ) - 1;
    my $docrepstring = '../' x ( $doclevels - 1 );
    while ( $body =~ /(src|href)=("|')$goximscontent([^("|')]+)/g ) {
        my $dir = $3;
        $dir =~ s#[^/]+$##;

        #warn "gotabs, dir: $absolute_path, $dir";
        if ( $absolute_path =~ $dir ) {
            my $levels = split( '/', $dir ) - 1;
            my $repstring = '../' x ( $doclevels - $levels - 1 );
            $body =~ s/(src|href)=("|')$goximscontent$dir/$1=$2$repstring/;
        }
        else {
            $body =~ s#(src|href)=("|')$goximscontent/#$1=$2$docrepstring#;
        }
    }

    return $body;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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
