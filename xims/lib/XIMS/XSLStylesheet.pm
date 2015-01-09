
=head1 NAME

XIMS::XSLStylesheet

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::XSLStylesheet;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::XSLStylesheet;

use common::sense;
use parent qw( XIMS::XML );
use XIMS::DataFormat;




#=head2    my $xslstylesheet = XIMS::XSLStylesheet->new( %args )
=head2    XIMS::XSLStylesheet->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from XIMS::Object::new()

=head3 Returns

    $xslstylesheet: instance of XIMS::XSLStylesheet

=head3 Description

Fetches existing objects or creates a new instance of XIMS::XSLStylesheet
for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XSLT' )->id() unless defined $args{data_format_id};
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

