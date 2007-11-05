
=head1 NAME

XIMS::Exporter::Text -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::Exporter::Text;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::Text;

use strict;
use XIMS::Exporter;
use base qw( XIMS::Exporter::Binary );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub create {
    XIMS::Debug( 5, "called" );

    my ( $self, %param ) = @_;
    my $document_path =  $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    # create the item on disk
    my $document_fh = IO::File->new( $document_path, 'w' );
    if ( defined $document_fh ) {
        print $document_fh XIMS::xml_unescape( $self->{Object}->body() );
        $document_fh->close;
        XIMS::Debug( 4, "document written" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );

    return 1;
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

