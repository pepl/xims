
=head1 NAME

XIMS::Exporter::Text -- Export XIMS::Text objects.

=head1 VERSION

$Id$

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::Text;

use common::sense;
use XIMS::Exporter;
use parent -norequire, qw( XIMS::Exporter::Binary );
#use Data::Dumper;

=head2 create()

=head3 Parameter

    $param{filter} : coderef to a filter.

=head3 Returns

    $retval : undef on error

=head3 Description

Writes the object to the filesystem. When given a reference to a filter
function (string in -- string out), the function will be applied on writing.

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;
    my $document_path = $self->{Exportfile}
      || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    # default do-nothing-but-passthru filter
    my $filter = $param{filter} ? $param{filter} : sub { return @_ };

    # create the item on disk
    my $document_fh = IO::File->new( $document_path, 'w' );
    if ( defined $document_fh ) {
        binmode( $document_fh, ':raw' );

        # Despite binmode :raw, the virtual utf-8 IO layer will be used
        # Encode::_utf8_off will not directly work on $self->{Object}->body but only on copies
        # To save copying or adding more logic, we just disable the IO layer magic by using bytes here...
        use bytes;
        print $document_fh $filter->(
            XIMS::xml_unescape( $self->{Object}->body() ) );
        $document_fh->close;
        no bytes;

        XIMS::Debug( 4, "document written" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state('1');

    return 1;
}

1;

__END__

=pod

All other methods are derived from XIMS::Exporter::Binary.

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

