
=head1 NAME

XIMS::SAX::Generator -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::SAX::Generator;

use common::sense;
use XIMS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

#
# simple base class for XIMS Generator classes.  not much to see yet,
# really. mostly 'helper' functions.
#



=head2    $generator->prepare( $something );

=head3 Parameter

    $something

=head3 Returns

    $_[0] in scalar context, @_ otherwise

 DESCRIPION
    none yet

=cut

sub prepare {
    my $self = shift;
    return wantarray ? @_ : $_[0];
}



=head2 get_filters()

=head3 Parameter

    none

=head3 Returns

    "XIMS::SAX::Filter::Date"

=head3 Description

the date filter is always there!

=cut

sub get_filters {
    XIMS::Debug( 5, "called" );
    XIMS::Debug( 6, "will return 'XIMS::SAX::Filter::Date'" );
    return ( "XIMS::SAX::Filter::Date" );
}




=head2    $self->get_config();

=head3 Parameter

    none

=head3 Returns

    %opts : a plain HASH containing the PerlData parse options.

=head3 Description

used internally to retrieve the XML::Generator::PerlData options for this class.

=cut

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # The number of options here should become less and less as time goes on
    # and the API stablizes a bit.

    my %opts = (
                attrmap => {object      => ['id', 'document_id', 'parent_id', 'level'],
                            data_format => 'id',
                            user        => 'id',
                            session     => 'id',
                            children    => 'totalobjects',
                            object_type => 'id' },
                skipelements => ['username', 'salt', 'objtype', 'properties', 'password', 'Provider','User'],
               );
    return %opts;
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

