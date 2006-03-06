# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id $
package XIMS::CGI::VLibraryItem::URLLink;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::CGI::VLibraryItem;
use XIMS::VLibMeta;

use Data::Dumper;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI::VLibraryItem );


sub event_default {
    XIMS::Debug( 5, "called" );
      my ( $self, $ctxt) = @_;

    # this handles absolute URLs only for now
      $self->redirect( $ctxt->object->location() );

      return 0;
  }

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $error_message = '';
    # URLLink-Location must be unchanged
    $ctxt->properties->application->preservelocation( 1 );    
    
    # Title, subject, keywords and abstract are mandatory
    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

#    $self->SUPER::event_store( $ctxt );
    my $object = $ctxt->object();

    my $meta;
    if (! $object->document_id() ) {
        #Object must be created because a document_id() is needed to store subject, keyword and meta information
        my $content_id = $object->create();
        $meta = XIMS::VLibMeta->new();
        XIMS::Debug(6, "jokar: Meta new URL: " . Dumper($meta));
    }
    else {
        $self->SUPER::event_store( $ctxt );
        $meta = XIMS::VLibMeta->new( document_id => $object->document_id());
        XIMS::Debug(6, "jokar: Meta old URL: " . Dumper($meta));
    }
    $object->vlesubjects( subjects_from_param( $self->param('subject') ) );
    $object->vlekeywords( keywords_from_param( $self->param('keywords') ) );
    
    # Store metadata (publisher, chronicle dates)

    $meta->data( publisher => $self->param('publisher') );
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
    XIMS::Debug(6, "jokar: Meta save URL: " . Dumper($meta));    if ( $error_message ) {
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
1;
