

=head1 NAME

XIMS::Markdown.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Markdown;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Markdown;

use common::sense;
use parent qw( XIMS::Text );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );


=head2 new()

=head3 Parameter
    $args{ User }                  (optional) :  XIMS::User instance
    $args{ path }                  (optional) :  Location path to a XIMS Object, For example: '/xims'
    $args{ $object_property_name } (optional) :  Object property like 'id', 'document_id', or 'title'.
                                                 To fetch existing objects either 'path', 'id' or 'document_id' has to be specified.
                                                 Multiple object properties can be specified in the %args hash.
                                                 For example: XIMS::Markdown->new( id => $id )

=head3 Returns
    $markdown: Instance of XIMS::Markdown

=head3 Description
    Fetches existing objects or creates a new instance of XIMS::Markdown for object creation.

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


