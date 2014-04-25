

=head1 NAME

XIMS::Document2.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Document2;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Document2;

use common::sense;
use parent qw( XIMS::Document );
use HTML::HTML5::Parser;

=head2    balance_string()

=head3 Parameter

    $CDATAstring : input string
    %args        : hash
       recognized keys: keephtmlheader : per default, the html-header tidy
                                         generates is stripped of the return
                                         string and only the part between the
                                         "body" tag is returned in case of
                                         importing legacy html documents it
                                         may be useful to keep the meta
                                         information in the html header - the
                                         keephtmlheader flag is your friend
                                         for that.

=head3 Returns

    $wbCDATAstring : well balanced outputstring or undef in case of error

=head3 Description

my $wbCDATAstring = $object->balance_string( $CDATAstring, [$params] );

takes a string and tries tidy, or if that fails XML::LibXML to well-balance it

=cut

sub balance_string {
    XIMS::Debug( 5, "called" );
    my ($self, $CDATAstring, %args) = @_;

    return unless defined $CDATAstring;

    my $parser = HTML::HTML5::Parser->new;
    my $wbCDATAstring = $parser->parse_string( $CDATAstring )->toString();

    if ( not exists $args{keephtmlheader} ) {
        # strip everything before <BODY> and after </BODY>
        $wbCDATAstring =~ s/^.*<body[^>]*>\n?//si;
        $wbCDATAstring =~ s\</body[^>]*>.*$\\si;
    }

    return $wbCDATAstring || undef;
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


