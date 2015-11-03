
=head1 NAME

XIMS::CGI::VLibraryItem::Document

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibraryItem::NewsItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibraryItem::NewsItem;

use common::sense;
use parent qw( XIMS::CGI::VLibraryItem::Document XIMS::CGI::NewsItem2 );
use XIMS::VLibMeta;
use Locale::TextDomain ('info.xims');

sub event_default {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    # replace image id with image path
    $self->resolve_content( $ctxt, [qw( IMAGE_ID )] );

    return $self->SUPER::event_default($ctxt);
}

=head2 event_edit()

=cut

sub event_edit {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [qw( IMAGE_ID )] );

    return $self->SUPER::event_edit($ctxt);
}

=head2 event_store()

=cut

sub event_store {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    my $img_fh = $self->upload('imagefile');
    if ( length $img_fh ) {
        my $target_location = $self->param('imagefolder');
        my $img_target = XIMS::Object->new( path => $target_location );

        if ( defined $img_target ) {
            XIMS::Debug( 4, "Creating Image object for new NewsItem" );
            my $img_obj = XIMS::Image->new( User => $ctxt->session->user() );
            $img_obj->parent_id( $img_target->document_id() );

            # $location will be part of the URI, converting to iso-8859-1 is a
            # first step before clean_location() to ensure browser
            # compatibility
            my $converter = Text::Iconv->new( "UTF-8", "ISO-8859-1" );

            # will be undef if string can not be converted to iso-8859-1
            $img_obj->location(
                $converter->convert( $self->param('imagefile') ) );

            my $type = $self->uploadInfo($img_fh)->{'Content-Type'};
            my $df;
            if ( $df = XIMS::DataFormat->new( mime_type => $type ) ) {
                XIMS::Debug( 6, "xims mime type: " . $df->mime_type() );
                XIMS::Debug( 6, "UA   mime type: " . $type );
            }
            else {
                $df =
                  XIMS::DataFormat->new(
                    mime_type => 'application/octet-stream' );
                XIMS::Debug( 6,
                    "xims mime type: forced to 'application/octet-stream'" );
                XIMS::Debug( 6, "UA   mime type: " . $type );

            }
            $img_obj->data_format_id( $df->id() );

            my $image_title = $self->param('imagetitle');
            if (    defined $image_title
                and length $image_title
                and $image_title !~ /^\s+$/ )
            {
                $img_obj->title($image_title);
            }

            my $image_description = $self->param('imagedescription');

            # check if a valid image_description is given
            if (
                defined $image_description
                and
                ( length $image_description and $image_description !~ /^\s+$/
                    or not length $image_description )
              )
            {
                XIMS::Debug( 6,
                    "image_description, len: " . length($image_description) );
                $img_obj->abstract($image_description);
            }

            my $image_rights = $self->param('imagerights');
            if (
                defined $image_rights
                and
                ( length $image_rights and $image_rights !~ /^\s+$/
                    or not length $image_rights )
              )
            {
                XIMS::Debug( 6, "image_rights, len: " . length($image_rights) );
                $img_obj->rights($image_rights);
            }

            XIMS::Debug( 4, "reading from filehandle" );
            my ( $buffer, $body );
            while ( read( $img_fh, $buffer, 1024 ) ) {
                $body .= $buffer;
            }

            $img_obj->body($body);
            my $img_created = $ctxt->object->add_image($img_obj);
            XIMS::Debug( 3, "Image object import failed" ) unless $img_created;

        }
        else {
            XIMS::Debug( 3,
"Image upload folder undefined or does not exist, the new Image object was not created"
            );
        }
    }

    my $rc = $self->SUPER::event_store($ctxt);
    if ( not $rc ) {
        return 0;
    }
    else {
        return 1;
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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

