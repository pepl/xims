
=head1 NAME

XIMS::Document -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Document;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Document;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::Entities;


sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'HTML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    body()

=head3 Parameter

    $body                  (optional) :  Body string to save
    $args{ dontbalance }   (optional) :  If set, there will be no attempt to
                                         convert the body to a well-balanced
                                         string, this may be neccessary if
                                         users don't want their whitespace
                                         info munged by tidy.

=head3 Returns

    $body    : Body string from object
    $boolean : True or False for storing back body to object

=head3 Description

 my $body = $object->body();
 my $boolean = $object->body( $body [, %args] );
 
Overrides XIMS::Object::body(). Tests $body for being well-balanced and if it
is not, tries to well-balance $body unless $args{dontbalance} is given.

=cut

sub body {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $body = shift;
    my %args = @_;

    my $retval;

    return $self->SUPER::body() unless $body;

    # we only want the default XML-entities to be present
    $body = XIMS::Entities::decode( $body );
    if ( $self->balanced_string( $body ) ) {
        $self->SUPER::body( $body );
        $retval = 1;
    }
    elsif ( not exists $args{dontbalance} ) {
        XIMS::Debug( 3, "not well balanced; trying to balance it" );
        $body = $self->balance_string( $body );
        if ( $self->balanced_string( $body ) ) {
            $self->SUPER::body( $body );
            $retval = 1;
        }
        else {
            XIMS::Debug( 3, "well balancing failed" );
        }
    }
    else {
        XIMS::Debug( 3, "not well balanced; not trying to due to args" );
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

