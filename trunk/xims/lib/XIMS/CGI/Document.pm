
=head1 NAME

XIMS::CGI::Document -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Document;

=head1 DESCRIPTION

It is based on XIMS::CGI.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Document;

use strict;
use base qw( XIMS::CGI XIMS::CGI::Mailable);
use Text::Iconv;
use Encode;
use Text::Template;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

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
                                'test_wellformedness',
                                'pub_preview',
                                'bxeconfig',
                                'prepare_mail', 
                                'send_as_mail',
                                @_
                                );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );

    # look for inherited CSS assignments
    if ( not defined $ctxt->object->css_id() ) {
        my $css = $ctxt->object->css;
        $ctxt->object->css_id( $css->id ) if defined $css;
    }

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

    my $trytobalance  = $self->param( 'trytobalance' );

    my $body = $self->param( 'body' );
    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

        my $object = $ctxt->object();

        # The HTMLArea WYSIWG-editor in combination with MSIE translates relative paths in 'href' and 'src' attributes
        # to their '/goxims/content'-absolute path counterparts. Since we do not want '/goxims/content' references. which will
        # very likely break after the content has been published, we have to mangle with the 'href' and 'src' attributes.
        my $absolute_path_nosite = defined $object->id() ? $object->location_path_relative() : ($ctxt->parent->location_path_relative() . '/' . $object->location());
        #$body = $self->_absrel_urlmangle( $ctxt, $body, '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE(), $absolute_path_nosite );
        $body = $self->_absrel_urlmangle( $ctxt, $body, '/' . XIMS::GOXIMS() , XIMS::CONTENTINTERFACE(), $absolute_path_nosite );

        # kill xml:lang attributes until we make correct use of them
        $body =~ s/ xml:lang="[^"]+"//g; #"

        # Depending on the DBD::Pg and DBD::Oracle versions, $oldbody will have the utf8 flag set.
        # To not double-utf8-encode the result of store_diff_to_second_last by passing in a non-utf8
        # flagged, but utf8 encoded string together with a utf8-encoded and -flagged string, we
        # check here, if the two strings have the flag set and set it in case.
        my $oldbody = $object->body();
        my $newbody = $body;
        if ( Encode::is_utf8($oldbody) and not XIMS::DBENCODING() and not Encode::is_utf8($newbody) ) {
            $newbody = Encode::decode_utf8($newbody);
        }

        if ( $trytobalance eq 'true' and $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
            if ( $object->store_diff_to_second_last( $oldbody, $newbody ) ) {
                XIMS::Debug( 4, "diff stored" );
            }
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
            if ( $object->store_diff_to_second_last( $oldbody, $newbody ) ) {
                XIMS::Debug( 4, "diff stored" );
            }
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            # Set a verbose error message to help users find the error
            $body = XIMS::Entities::decode( $body );
            my $verbose_msg = $object->balanced_string( $body, verbose_msg => 1);

            # Add the original faulty string together with line numbers
            my ($faulty_ln) = ( $verbose_msg =~ /Entity: line (\d+)/);
            my $ln = 1;
            $verbose_msg .= '=' x 72 . "\n";
            $body = _getln($ln++, $faulty_ln) . '| ' . $body;
            $body =~ s#\n#"\n" . _getln($ln++, $faulty_ln) . '| '#eg;
            $verbose_msg .= $body . "\n";
            $verbose_msg .= '=' x 72 . "\n";

            $self->sendError( $ctxt, __"Document body could not be converted to a well balanced string.", $verbose_msg );
            return 0;
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

=head2 event_exit()

=cut

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_exit( $ctxt );
}

#
# the following events extend the edit mode. in browse mode this
# information should be displayed by default.
#
# may be inserted into event_default ...

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return 0 if $self->SUPER::event_default( $ctxt );

    # pepl: why do we need two ways to load links and annotations? if
    # annotations would have the privs/grants of the owner document
    # copied "by definition", this would not be neccessary

    # pepl/ phish: this is strictly related to the general privilege
    # system we have to discuss more intense.

    # the following still has to be implemented with the new system

    $ctxt->properties->content->getchildren->objecttypes( [ qw( Text URLLink SymbolicLink ) ] );

    # temporarily deactivated until privilege inheritation of annotations is dicussed and clear
    #$self->resolve_annotations( $ctxt );

    return 0;
}

=head2 event_pub_preview()

=cut

sub event_pub_preview {
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # Emulate request.uri CGI param, set by Apache::AxKit::Plugin::AddXSLParams::Request
    $self->param( 'request.uri', $ctxt->object->location_path_relative() );

    $ctxt->properties->application->style("pub_preview");

    # hmmm, we are guessing there... :-|
    #print $self->header('-charset' => 'ISO-8859-1' );

    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# Local Helper functions

=head2 getPubPreviewDOM()

=cut

sub getPubPreviewDOM {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    require XIMS::Exporter;
    my $handler = XIMS::Exporter::Document->new(
                                       Provider   => $ctxt->data_provider,
                                       Basedir    => XIMS::PUBROOT(),
                                       Stylesheet => XIMS::XIMSROOT().'/stylesheets/exporter/export_document.xsl',
                                       User       => $ctxt->session->user,
                                       Object     => $ctxt->object,
                                       Options => { PrependSiteRootURL => $ctxt->object->siteroot->title() },
                                       );
    my $raw_dom = $handler->generate_dom();
    my $transd_dom = $handler->transform_dom( $raw_dom );
    return unless defined $transd_dom;

    # This may fail
    # For this to work with simple.examplesite.tld for example, 'simple.examplesite.tld' has to
    # be entered in the server's /etc/hosts file :-( There should be a better way for
    # creating a fully working example site!?
    eval {
        $transd_dom->process_xinclude( 1 );
    };
    XIMS::Debug( 3, "Process xinclude failed: $@" ) if $@;


    return $transd_dom;
}

=head2 selectPubPreviewStylesheet()

=cut

sub selectPubPreviewStylesheet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $stylepath;
    my $filename = 'document_publishing_preview.xsl';
    my $style = XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/public/' . $ctxt->session->uilanguage() . '/' . $filename;

    my $stylesheet = $ctxt->object->stylesheet();
    if ( defined $stylesheet and $stylesheet->published() ) {
        if ( $stylesheet->object_type->name() eq 'XSLStylesheet' ) {
            XIMS::Debug( 4, "using assigned pub-preview-stylesheet" );
            $style = XIMS::PUBROOT() . $stylesheet->location_path();
        }
        else {
            XIMS::Debug( 4, "using pub-preview-stylesheet from assigned directory" );
            my $dir = XIMS::PUBROOT() . $stylesheet->location_path();
            my $filepath = $dir . '/' . $filename;
            my $filepathuilang = $dir . '/' . $ctxt->session->uilanguage() . '/' . $filename;
            if ( -f $filepathuilang and -r $filepathuilang ) {
                $style = $filepathuilang;
            }
            elsif ( -f $filepath and -r $filepath ) {
                $style = $filepath;
            }
        }
    }
    else {
        XIMS::Debug( 4, "using default pub-preview stylesheet" );
    }

    return $style;
}

=head2 selectStylesheet()

=cut

sub selectStylesheet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    if ( $ctxt->properties->application->style eq 'pub_preview' ) {
        return $self->selectPubPreviewStylesheet( $ctxt );
    }
    else {
        return $self->SUPER::selectStylesheet( $ctxt );
    }
}

=head2 getDOM()

=cut

sub getDOM {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    if ( $ctxt->properties->application->style eq 'pub_preview' ) {
        return $self->getPubPreviewDOM( $ctxt );
    }
    else {
        return $self->SUPER::getDOM( $ctxt );
    }
}

=head2 resolve_annotations()

=cut

sub resolve_annotations {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    require XIMS::SAX::Filter::AnnotationCollector;
    push ( @{$ctxt->sax_filter()},
           XIMS::SAX::Filter::AnnotationCollector->new( Object => $ctxt->object() )
         );
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
    my $editor = $self->cookie($cookiename);
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ($editor eq 'wepro') { 
        # we just dumped eWebEditPro, now change the remaining cookies
        $editor = 'tinymce';
    }
	elsif ($editor eq 'codemirror') { 
        # if codemirror is set, use default/undefined editor instead (codemirror is included in tinymce)
        $editor = undef;
    }
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
        if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
             $editor = 'tinymce';
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

sub _absrel_urlmangle {
    my $self = shift;
    my $ctxt = shift;
    my $body = shift;
    my $goxims = shift;
    my $content = shift;
    #my $goximscontent = shift;
    my $goximscontent = $goxims.$content;
    my $absolute_path_nosite = shift;

    my @size = split('/', $absolute_path_nosite);
    my $doclevels = scalar(@size) - 1;
    my $docrepstring = '../'x($doclevels-1);
    while ( $body =~ /(src|href)=("|')$goximscontent(\/[^\/]+)(\/[^("|')]+)/g ) {
        my $site = $3;
        my $dir = $4;
        $dir =~ s#[^/]+$##;
        if ( $absolute_path_nosite =~ $dir ) {
            my @size = split('/', $dir);
            my $levels = scalar(@size) - 1;
            my $repstring = '../'x($doclevels-$levels-1);
            $body =~ s/(src|href)=("|')$goximscontent$site$dir/$1=$2$repstring/;
        }
        else {
            $body =~ s#(src|href)=("|')$goximscontent$site/#$1=$2$docrepstring#;
        }
    }
    
    # Firefox ignores tinyMCE's baseurl when pasting a relative link in the editor and adds leading "content/site/"
    $content =~ s/^\///;# remove leading slash
    while ( $body =~ /(src|href)=("|')$content(\/[^\/]+)(\/[^("|')]+)/g ) {
        my $site = $3;
        my $dir = $4;
        $dir =~ s#[^/]+$##;
        if ( $absolute_path_nosite =~ $dir ) {
            my @size = split('/', $dir);
            my $levels = scalar(@size) - 1;
            my $repstring = '../'x($doclevels-$levels-1);
            $body =~ s/(src|href)=("|')$content$site$dir/$1=$2$repstring/;
        }
        else {
            $body =~ s#(src|href)=("|')$content$site/#$1=$2$docrepstring#;
        }
    }

    # XXX fixup hack: remove exeeding '../'
    my $level = $doclevels - 1;
    $body =~ s/(src|href)=("|') # src or href attribute with = and starting quote
               (\.\.\/){$level} # these already step up to the root
               (?:\.\.\/)+      # thence these are too much
              /$1 . '=' . $2
               . $3 x $level
              /egx;

    return $body;
}

=head2 save_PUT_data()

=cut

sub save_PUT_data {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # Read PUT-request
    my $content_length = $ctxt->apache->header_in('Content-length');
    my $content;
    $ctxt->apache->read($content, $content_length);

    if ( XIMS::DBENCODING() ) {
        $content = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($content);
    }

    $ctxt->object->body( $content );

    # Store in database
    if ( $ctxt->object->update() ) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 event_bxeconfig()

=cut

sub event_bxeconfig {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $otname = lc $object->object_type->name();

    my $templatepath = XIMS::XIMSROOT() . '/templates/bxe/';
    my $templatefile = 'config-' . $otname . '.tmpl';
    if ( not -f $templatepath . $templatefile ) {
        $templatefile = $templatepath . 'config-generic.tmpl';
    }

    my $template = Text::Template->new(TYPE => 'FILE',  SOURCE => $templatefile );
    if ( not $template ) {
        XIMS::Debug( 2, "could not get template" );
        $self->sendError( $ctxt, __"Could not get template" );
        return 0;
    }

    my %vars = ( validationfile  => XIMS::XIMSROOT_URL() . '/schemata/' . $otname . '.xml',
                 css             => XIMS::XIMSROOT_URL() . '/stylesheets/' . $otname . '.css',
                 exitdestination => '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE() . '?id=' . $object->id() . ';edit=1',
                 xmlfile         => '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE() . '?id=' . $object->id() . ';plain=1' );
    my $text = $template->fill_in( HASH => \%vars );

    print $self->header( -Content_type => 'text/xml; charset=UTF-8' );
    print $text;

    $self->skipSerialization(1);
    return 0;
}

sub _getln {
    my $ln = shift;
    my $faulty = shift;

    if ( $faulty == $ln ) {
        return sprintf('==> %4d', $ln );
    }
    else {
        return sprintf(' %7d', $ln );
    }
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

