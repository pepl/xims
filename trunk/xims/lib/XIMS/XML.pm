
=head1 NAME

XIMS::XML

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::XML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::XML;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::Entities;




=head2    my $xml = XIMS::XML->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from XIMS::Object::new()

=head3 Returns

    $xml: instance of XIMS::XML

=head3 Description

Fetches existing objects or creates a new instance of XIMS::XML for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my $body = $xml->body();
    my $boolean = $xml->body( $body [, %args] );

=head3 Parameter

    $body                  (optional) :  Body string to save

=head3 Returns

    $body    : Body string from object
    $boolean : True or False for storing back body to object

=head3 Description

Overrides XIMS::Object::body(). Only sets $body if it is a well-formed XML string.

=cut

sub body {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $body = shift;
    my $retval;

    return $self->SUPER::body() unless $body;

    # we only want the default XML-entities to be present
    $body = XIMS::Entities::decode( $body );

    if ( $self->balanced_string( $body, nochunk => 1 ) ) {
        $self->SUPER::body( $body );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "body is not well formed" );
    }

    return $retval;
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

