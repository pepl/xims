
=head1 NAME

XIMS::Exporter::JavaScript -- Export XIMS::JavaScript objects.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Exporter::JavaScript;

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter::JavaScript;

use common::sense;
use parent qw( XIMS::Exporter::Text );
use JavaScript::Minifier::XS qw(minify);


=head2 create()

=head3 Parameter

    %param : implemented, but unused.

=head3 Returns

    $retval : undef on error

=head3 Description

Writes the object to the filesystem. When the minify atribute is set, pass
JavaScript::Minifier::XS::minify() as filter.

=cut

sub create {
    my ( $self, %param ) = @_;

    if ( $self->{Object}->attribute_by_key('minify') == 1 ) {
        $param{filter} = \&minify;
    }

    return $self->SUPER::create(%param);
}

1;

__END__

=pod

All other methods are derived from XIMS::Exporter::Text.

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

