

=head1 NAME

XIMS::Exporter::Markdown.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Exporter::Markdown;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::Markdown;

use common::sense;
use XIMS::Exporter;
use parent -norequire, qw( XIMS::Exporter::Document );
use Text::Markdown 'markdown';

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 create()

=head3 Parameter

=head3 Returns

    $retval : undef on error

=head3 Description

Converts Markdown to XHTML and calls its ancestor.

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    my $origbody = $self->{Object}->body();
    $self->{Object}->body(markdown($origbody));

    # generate DOM
    my $raw_dom = $self->generate_dom();

    unless ( $raw_dom ) {
        XIMS::Debug( 3, "no dom created" );
        return;
    }

    # THEN we have to do the transformation of the DOM, as the output should
    # contain using XSL.
    my $transd_dom = $self->transform_dom( $raw_dom );

    unless ( defined $transd_dom ) {
        XIMS::Debug( 3, "transformation failed" );
        return;
    }

    XIMS::Debug( 4, "transformation succeeded" );
    my $document_path = $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    my $document_fh = IO::File->new( $document_path, 'w' );

    if ( defined $document_fh ) {
        # Exporter stylesheets generate UTF-8 encoded documents. Make sure
        # that they get written out as such
        binmode( $document_fh, ':encoding(UTF-8)' );

        print $document_fh $transd_dom->toString(1);
        # $transd_dom->toFH($document_fh,1);
        $document_fh->close;
        XIMS::Debug( 4, "document written to $document_path" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return;
    }

    # change back iot. prevent saving the HTML into the body
    $self->{Object}->body($origbody);

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' ) unless $self->isa('XIMS::Exporter::AutoIndexer');

    return 1;
    

}


1;


__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Write me.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2017 The XIMS Project.

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

