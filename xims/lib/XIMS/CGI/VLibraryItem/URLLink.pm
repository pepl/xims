
=head1 NAME

XIMS::CGI::VLibraryItem::URLLink

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibraryItem::URLLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibraryItem::URLLink;

use common::sense;
use parent qw( XIMS::CGI::VLibraryItem );
use XIMS::VLibMeta;
use Locale::TextDomain ('info.xims');


=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
      my ( $self, $ctxt) = @_;

    # this handles absolute URLs only for now
      $self->redirect( $ctxt->object->location() );

      return 0;
  }

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $error_message = '';

    # URLLink-Location must be unchanged
    $ctxt->properties->application->preservelocation( 1 );    

    # Title, subject, keywords and abstract are mandatory
    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    # check URL
    if ( not( $object->check( scalar $self->param('name') ) ) ) {
        $self->sendError( $ctxt, __"The specified URL returns an Error. Please check the location." );
        return 0;
    }

    my $meta;
    if (! $object->document_id() ) {
        $self->SUPER::event_store( $ctxt );    
        $object = $ctxt->object();
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
            $error_message = "$date_from " . __"is not a valid date or not in the correct format (YYYY-MM-DD)";
        }
    }
    my $date_to = $self->param('chronicle_to_date');
    if ($date_to) {
        if ( $self->_isvaliddate( $date_to ) ) {
            $meta->data( date_to_timestamp => $date_to );
        }
        else {
            $error_message = "$date_to " . __"is not a valid date or not in the correct format (YYYY-MM-DD)";
        }
    }
    $object->vlemeta( $meta );
    $object->check();
    if ( $error_message ) {
        $self->sendError( $ctxt, $error_message );
        return 0;
    }
    elsif ( $self->param('close_thickbox') ) {
        XIMS::Debug( 4, "closing thickbox" );
        return $self->close_thickbox(1);
    }
    else {
        XIMS::Debug( 4, "redirecting" );
        $self->redirect( $self->redirect_uri( $ctxt ) );
        return 1;
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

