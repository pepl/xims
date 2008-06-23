
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

use strict;
use base qw( XIMS::CGI );

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
           obj_aclgrant
           obj_aclrevoke
           publish
           publish_prompt
           unpublish
           view_data
          )
        );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    print $self->header( -type => $ctxt->object->data_format->mime_type() );
    print $ctxt->object->body();
    $self->skipSerialization(1);

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

Copyright (c) 2002-2007 The XIMS Project.

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

