
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

package XIMS::CGI::VLibraryItem::Document;

use common::sense;
use parent qw( XIMS::CGI::VLibraryItem );
use XIMS::VLibMeta;
use Locale::TextDomain ('info.xims');

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
    my $ed = $self->set_wysiwyg_editor($ctxt);
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

    my $trytobalance;
    unless ($ctxt->object->attribute_by_key('geekmode') or $self->param('geekmode')) {
        $trytobalance = $self->param( 'trytobalance' );
    }

    my $body = $self->param('body');

    my $object = $ctxt->object();

    if ( defined $body and length $body ) {

        # fix /goxims/content/-links in href- and src attributes
        my $absolute_path_nosite = 
          defined $object->id() 
          ? $object->location_path_relative() 
          : ($ctxt->parent->location_path_relative() . '/' . $object->location() );
        $body =
          $self->_absrel_urlmangle( $ctxt, $body,
            '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE(),
            $absolute_path_nosite );

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
            $self->sendError( $ctxt, __"Document body could not be converted to a well balanced string." );
            return 0;
        }

        $object->attribute( geekmode => $self->param('geekmode') ? 1 : 0 );
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
                  . __"is not a valid date or not in the correct format (YYYY-MM-DD)";
            }
        }
    }

    $object->vlemeta($meta);

    my $rdpath = $self->redirect_uri($ctxt);

    if ( $self->param('proceed_to_edit') == 1 ) {
        $rdpath .=
          ( $self->redirect_uri($ctxt) =~ /\?/ ) ? ';edit=1' : '?edit=1';
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

=item _absrel_urlmangle()

=back

=cut

# TODO: try to use XIMS::CGI::Document's version of this
sub _absrel_urlmangle {
    my $self = shift;
    my $ctxt = shift;
    my $body = shift;
    my $goximscontent = shift;
    my $absolute_path_nosite = shift;

    my @size = split('/', $absolute_path_nosite);
    my $doclevels = scalar(@size) - 1;
    my $docrepstring = '../'x($doclevels-1);
    while ( $body =~ /(src|href)=("|')$goximscontent(\/[^\/]+)(\/[^("|')]+)/g ) {
        my $site = $3;
        my $dir = $4;
        $dir =~ s#[^/]+$##;
        #warn "gotabs, site: $site, dir: $absolute_path_nosite, $dir";
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

    return $body;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

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

