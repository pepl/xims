# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::VLibraryItem::URLLink;

use strict;
use base qw( XIMS::CGI::VLibraryItem );
use XIMS::VLibMeta;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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
    }
    else {
        $self->SUPER::event_store( $ctxt );
        $meta = XIMS::VLibMeta->new( document_id => $object->document_id());
    }

    # store subjects and keywords
    my $vlsubject = $self->param('vlsubject');
    my $vlkeyword = $self->param('vlkeyword');
    $self->_create_mapping_from_name( $ctxt->object(), 'Subject', $vlsubject ) if $vlsubject;
    $self->_create_mapping_from_name( $ctxt->object(), 'Keyword', $vlkeyword ) if $vlkeyword;

    # Store metadata (publisher, chronicle dates, etc)
    map { $meta->data( $_=>$self->param($_) ) if defined $self->param($_) }
          qw(publisher subtitle legalnotice bibliosource mediatype coverage audience);

    my $date_from = $self->param('chronicle_from_date');
    if ($date_from) {
        if ( $self->_isvaliddate( $date_from ) ) {
            $meta->data( date_from_timestamp => $date_from );
        }
        else {
            $error_message = "$date_from is not a valid date or not in the correct format (YYYY-MM-DD)";
        }
    }
    my $date_to = $self->param('chronicle_to_date');
    if ($date_to) {
        if ( $self->_isvaliddate( $date_to ) ) {
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