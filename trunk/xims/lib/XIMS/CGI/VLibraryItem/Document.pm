# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package XIMS::CGI::VLibraryItem::Document;

use strict;
use base qw( XIMS::CGI::VLibraryItem );
use XIMS::VLibMeta;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub event_create {
    XIMS::Debug( 5, "called" );
      my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
      $self->SUPER::event_create( $ctxt );
      return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
      my $ed = $self->_set_wysiwyg_editor( $ctxt );
      $ctxt->properties->application->style( "create" . $ed );

      return 0;
  }

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

      return 0;
  }


sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $error_message = '';
    
    # Title, subject, keywords and abstract are mandatory
    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $trytobalance  = $self->param( 'trytobalance' );

    my $body = $self->param( 'body' );

    my $object = $ctxt->object();

    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

        # The HTMLArea WYSIWG-editor in combination with MSIE translates relative paths in 'href' and 'src' attributes
        # to their '/goxims/content'-absolute path counterparts. Since we do not want '/goxims/content' references. which will
        # very likely breaks after the content has been published, we have to mangle with the 'href' and 'src' attributes.
        my $absolute_path = defined $object->id() ? $object->location_path() : ($ctxt->parent->location_path() . '/' . $object->location());
        $body = $self->_absrel_urlmangle( $ctxt, $body, '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE(), $absolute_path );

        my $oldbody = $object->body();
        if ( $trytobalance eq 'true' and $object->body( $body ) ) {
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
            $self->sendError( $ctxt, "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );
            return 0;
        }
    }
    my $meta;
    if (! $object->document_id() ) {
        #Object must be created because a document_id() is needed to store subject, keyword and meta information
        #my $importer = XIMS::Importer::Object->new( User => $ctxt->session->user(), Parent => $ctxt->parent() );
        #if ( $importer->import( $object ) ) {
        my $content_id = $object->create();
        $meta = XIMS::VLibMeta->new();
    }
    else {
        $self->SUPER::event_store( $ctxt );
        $meta = XIMS::VLibMeta->new( document_id => $object->document_id());
    }
    XIMS::Debug(6, "Jokar: Subjects - ".$self->param('subject'));
    $object->vlesubjects( subjects_from_param( $self->param('subject') ) );
    XIMS::Debug(6, "Jokar: Keywords - ".$self->param('keywords'));
    $object->vlekeywords( keywords_from_param( $self->param('keywords') ) );
    
    # Store metadata (publisher, chronicle dates, etc)
    map { $meta->data( $_=>$self->param($_) ) if defined $self->param($_) }
          qw(publisher subtitle legalnotice bibliosource mediatype coverage audience);
 
    my $date_from = $self->param('chronicle_from_date');
    if ($date_from) {
        if ( isvaliddate( $date_from ) ) {
            $meta->data( date_from_timestamp => $date_from );
        }
        else {
            $error_message = "$date_from is not a valid date or not in the correct format (YYYY-MM-DD)";
        }
    }
    my $date_to = $self->param('chronicle_to_date');
    if ($date_to) {
        if ( isvaliddate( $date_to ) ) {
            $meta->data( date_to_timestamp => $date_to );
        }
        else {
            $error_message = "$date_to is not a valid date or not in the correct format (YYYY-MM-DD)";
        }
    }
    $object->vlemeta( $meta );

    if ( $error_message ) {
        $self->sendError( $ctxt, $error_message );
        return 0;
    }
    else {
        $self->redirect( $self->redirect_path( $ctxt ) );
        return 1;
    }
}

sub keywords_from_param {
    XIMS::Debug( 5, "called" );

    my $keywords = shift;
    my @keyword_list = split /,/, $keywords;
    my @vl_keywords;

    return () unless $keywords;

    foreach my $keyword ( @keyword_list ) {
        next until $keyword;
        my $vlibkeyword = XIMS::VLibKeyword->new( name => $keyword );
        if ( not ( defined $vlibkeyword and $vlibkeyword->id ) ) {
            $vlibkeyword = XIMS::VLibKeyword->new();
            $vlibkeyword->name( $keyword );
            if ( not $vlibkeyword->create() ) {
                XIMS::Debug( 3, "could not create VLibKeyword $keyword" );
                next;
            } else  {
                XIMS::Debug( 6, "created keyword $keyword" );
            }
        }
        push(@vl_keywords, $vlibkeyword);
    }
    
    return @vl_keywords;
}

sub subjects_from_param {
    XIMS::Debug( 5, "called" );

    my $subjects = shift;
    my @subject_list = split /,/, $subjects;
    my @vl_subjects;

    return () unless $subjects;

    foreach my $subject ( @subject_list ) {
        next until $subject;
        my $vlibsubject = XIMS::VLibSubject->new( name => $subject );
        if ( not (defined $vlibsubject and $vlibsubject->id) ) {
            $vlibsubject = XIMS::VLibSubject->new();
            $vlibsubject->name( $subject );
            if ( not $vlibsubject->create() ) {
                XIMS::Debug( 3, "could not create VLibSubject $subject" );
                next;
            }
        }
        push(@vl_subjects, $vlibsubject);
    }

    return @vl_subjects;
}

sub isvaliddate {
  my $input = shift;
  if ($input =~ m!^((?:17|18|19|20)\d\d)[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$!) {
    # At this point, $1 holds the year, $2 the month and $3 the day of the date entered
    if ($3 == 31 and ($2 == 4 or $2 == 6 or $2 == 9 or $2 == 11)) {
      return 0; # 31st of a month with 30 days
    } elsif ($3 >= 30 and $2 == 2) {
      return 0; # February 30th or 31st
    } elsif (($2 == 2) and ($3 == 29) and not ((($1 % 4) == 0) and ( (($1 % 100) != 0 ) or ( ($1 % 400) == 0 )))) {
      return 0; # February 29th outside a leap year
    } else {
      return 1; # Valid date
    }
  } else {
    return 0; # Not a date
  }
}

sub _set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor = $self->cookie($cookiename);
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
        if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
            $editor = 'htmlarea';
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
    my $goximscontent = shift;
    my $absolute_path = shift;

    my $doclevels = split('/', $absolute_path) - 1;
    my $docrepstring = '../'x($doclevels-1);
    while ( $body =~ /(src|href)=("|')$goximscontent([^("|')]+)/g ) {
        my $dir = $3;
        $dir =~ s#[^/]+$##;
    #warn "gotabs, dir: $absolute_path, $dir";
        if ( $absolute_path =~ $dir ) {
            my $levels = split('/', $dir) - 1;
            my $repstring = '../'x($doclevels-$levels-1);
            $body =~ s/(src|href)=("|')$goximscontent$dir/$1=$2$repstring/;
        }
    else {
            $body =~ s#(src|href)=("|')$goximscontent/#$1=$2$docrepstring#;
        }
}

return $body;
}

1;
