
=head1 NAME

XIMS::SAX::Generator::User -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::User;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::User;

use common::sense;
use parent qw(XIMS::SAX::Generator::Users);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $doc_data = $self->SUPER::prepare( $ctxt );
    if ( $ctxt->userobjectlist() ) {
        $doc_data->{userobjectlist}->{objectlist} = { object => $ctxt->userobjectlist() };
    }

    # add the user's bookmarks.
    my @bookmarks = $ctxt->session->user->bookmarks();
    $doc_data->{context}->{session}->{user}->{bookmarks} = { bookmark => \@bookmarks };

 	$doc_data->{context}->{session}->{user}->{userprefs} = $ctxt->session->user->userprefs;

    my @object_types = $ctxt->data_provider->object_types();
    my @data_formats = $ctxt->data_provider->data_formats();
    $doc_data->{object_types} = {object_type => \@object_types};
    $doc_data->{data_formats} = {data_format => \@data_formats};

    return $doc_data;
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

