
=head1 NAME

XIMS::SQLReport

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SQLReport;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SQLReport;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::DataFormat;




=head2    XIMS::SQLReport->new( %args )

=head3 Parameter

    $args{ User }                   :  XIMS::User instance
    $args{ path }                   :  Location path to a XIMS Object, For
                                       example: '/xims'
    $args{ $object_property_name }  :  Object property like 'id',
                                       'document_id', or 'title'.
                                       To fetch existing objects either 'path',
                                       'id' or 'document_id' has to be
                                       specified. Multiple object properties can
                                       be specified in the %args hash. For
                                       example: XIMS::SQLReport->new( id => $id )

=head3 Returns

    $sqlreport: Instance of XIMS::SQLReport

=head3 Description

Fetches existing objects or creates a new instance of XIMS::SQLReport for
object creation. Args are optional.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
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

