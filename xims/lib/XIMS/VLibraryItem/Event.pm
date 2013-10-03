
=head1 NAME

XIMS::VLibraryItem::Event -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id: Document.pm 1878 2008-01-07 09:30:45Z cdab $

=head1 SYNOPSIS

    use XIMS::VLibraryItem::Event;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::VLibraryItem::Event;

use common::sense;
use parent qw( XIMS::VLibraryItem );




=head2    my $vlibitem = XIMS::VLibraryItem::Event->new( [ %args ] )

=head3 Parameter

    %args                  (optional) :  Takes the same arguments as its super
                                         class XIMS::VLibrayItem

=head3 Returns

    $vlibitem    : instance of XIMS::VLibraryItem::Event

=head3 Description

Fetches existing objects or creates a new instance of
XIMS::VLibraryItem::Event for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'HTML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
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

