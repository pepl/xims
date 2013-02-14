
=head1 NAME

XIMS::CGI::File -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::File;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::File;

use common::sense;
use parent qw( XIMS::CGI );

use XIMS::Importer::FileSystem;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Temp qw/ tempdir unlink0 /;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    return $_[0]->SUPER::registerEvents(
        qw(
           create
           edit
           store
           obj_acllist
           obj_acllight
           obj_aclgrant
           obj_aclrevoke
           publish
           publish_prompt
           unpublish
           view_data ) );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->skipSerialization(1);
    $self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            -type => $ctxt->object->data_format->mime_type()
        ),
        $ctxt->object->body()
    );
    return 0;
}

=head2 event_init()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_init(...)

=cut

sub event_init {
	my $self = shift;
	my $ctxt = shift;
	
	$ctxt->properties->application->keepsuffix( 1 );

	$self->SUPER::event_init($ctxt);
	return 0;
}
=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # get the parameters
    my $fh = $self->upload( 'file' );

    $ctxt->properties->application->keepsuffix( 1 );

    # set the location parameter, so init_store_object sets the right location
    if ( defined $ctxt->parent() ) {
        $self->param( name => $self->param( 'file' ) );
        #warn "Content-Type Upload: " . $self->uploadInfo($fh)->{'Content-Type'} if $self->param( 'unzip' );
        # check if we should expand a zip file
        if ( $self->param( 'unzip' )
                and length $fh
                and ($self->uploadInfo($fh)->{'Content-Type'} =~ /application\/(?:x-)?zip(?:-compressed)?/
                  # Firefox > 3.5.2 :-(
                  or $self->uploadInfo($fh)->{'Content-Type'} =~ /application\/oct(?:et)?-stream/ )) {

            my $overwrite = $self->param( 'overwrite' );
            $overwrite = 1 if $overwrite;

            my $importretval = $self->import_from_zip( $ctxt, $fh, $overwrite );
            if ( defined $importretval ) {
                # TODO: provide successful/failed message
                #       either by adding param to redirect_path
                #       or by adding an _update style
                my $count = $importretval->[0] . '%2F' . ($importretval->[0] + $importretval->[1]);
                $self->redirect( $self->redirect_uri( $ctxt, $ctxt->parent->id() ) .  "?message=" . $count . "%20objects%20imported." );
                return 1;
            }
            else {
                return $self->sendError( $ctxt, __"Unpacking file failed" );
            }
        }
    }

    return 0 unless $self->init_store_object( $ctxt );

    # if the mimetype provided by the UA is unknown,
    # fall back to 'application/octet-stream'
    if ( length $fh ) {
        my $type = $self->uploadInfo($fh)->{'Content-Type'};
        my $df;
        if ( $df = XIMS::DataFormat->new( mime_type => $type ) ) {
            XIMS::Debug( 6, "xims mime type: ". $df->mime_type() );
            XIMS::Debug( 6, "UA   mime type: ". $type );
        }
        else {
            $df = XIMS::DataFormat->new( mime_type => 'application/octet-stream' );
            XIMS::Debug( 6, "xims mime type: forced to 'application/octet-stream'" );
            XIMS::Debug( 6, "UA   mime type: ". $type );

        }
        $ctxt->object->data_format_id( $df->id() );

        XIMS::Debug(5, "reading from filehandle");
        my ($buffer, $body);
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }

        $ctxt->object->body( $body );
    }

    return 0 unless $self->SUPER::event_store( $ctxt );

}

=head2 event_view_data()

=cut

sub event_view_data {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # this is a special default. this has to be done, because on default the
    # file will be displayed as the content type it actualy is. the view event
    # is a browse interface for the files metadata.

    return $self->SUPER::event_default($ctxt);
}

=head2 import_from_zip()

=cut

sub import_from_zip {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt, $fh, $overwrite ) = @_;

    my $successful = 0;
    my $failed = 0;

    return 1 unless (defined $ctxt and defined $ctxt->parent() and defined $fh);

    # Archive::Zip does not support reading from a stream
    # therefore we write to a temp file first
    my $buffer;
    my ($tmpfh, $tmpfilename) = Archive::Zip::tempFile();
    while ( read($fh, $buffer, 1024) ) {
        print $tmpfh $buffer;
    }

    my $zip = Archive::Zip->new();
    if ( $zip->readFromFileHandle( $tmpfh ) != AZ_OK ) {
        XIMS::Debug(2, "Could not read zipfile");
        # TODO: throw exception here
        return;
    }
    if ( not unlink0($tmpfh, $tmpfilename) ) {
        XIMS::Debug( 3, "Could not unlink temporary file." . $!);
    }

    # Temp directory where the archive will be unpacked to
    # for the FS importer to be picked up
    my $tempdir = tempdir( CLEANUP => 1 );

    my $importer = XIMS::Importer::FileSystem->new(
                    User => $ctxt->session->user(),
                    Parent => $ctxt->parent(),
                    Chroot => $tempdir, );

    if ( not defined $importer ) {
        XIMS::Debug( 2, "Could not instantiate importer");
        return;
    }

    foreach my $member ( $zip->members() ) {
        my $fileName = $member->fileName();
        my $status = $member->extractToFileNamed( "$tempdir/$fileName" );
        my $handled_root;
        #ignore macosx-folder (created when zipping with mac)
        if ( $status == AZ_OK and not lc($fileName) =~ m/^__macosx\//) {
            # Depending on the ZIP file the initial member may be a document
            # in the root folder - Make sure the root folder will be imported first
            if ( $fileName =~ /\// and not $handled_root ) {
                my @parts = split('/',$fileName);
                if ( $importer->import( "$tempdir/$parts[0]", $overwrite ) ) {
                    XIMS::Debug( 6, "'$tempdir/$parts[0]' imported successfully." );
                    $successful++;
                }
                else {
                    XIMS::Debug( 3, "Import of '$tempdir/$parts[0]' failed." );
                    $failed++;
                }
                $handled_root = 1;
            }
            if ( $importer->import( "$tempdir/$fileName", $overwrite ) ) {
                XIMS::Debug( 6, "'$tempdir/$fileName' imported successfully." );
                $successful++;
            }
            else {
                XIMS::Debug( 3, "Import of '$tempdir/$fileName' failed." );
                $failed++;
            }

        }
        else {
            XIMS::Debug( 3, "Could not extract $fileName");
        }
    }

    if ( defined $successful or defined $failed ) {
        return [ $successful, $failed ];
    }
    return;
}


=head2 body_ref_objects();

=head3 Description

   Overwrites the respective method in XIMS::CGI. It just return the empty
   list and never attempts to parse a XIMS:File's body. (Which should be
   treated as binary, be it in text format or whatever-have-you)

=cut

sub body_ref_objects {return ();}

1;


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

