
=head1 NAME

XIMS::SAX::Filter::AnnotationCollector

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::AnnotationCollector;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::AnnotationCollector;

use common::sense;
use parent qw( XML::SAX::Base );
use XML::Generator::PerlData;


sub end_element {
    my $self = shift;
    my $elem = shift;

    if ( $elem->{LocalName} eq "children" ) {
        my $object  = $self->{Object};
        my @objects = $object->descendants_granted(
            User => $object->User,
            object_type_id =>
                [ XIMS::ObjectType->new( name => 'Annotation' )->id() ]
        );

        if ( @objects and scalar @objects ) {
            XIMS::Debug( 6, "found " . scalar(@objects) );
            my $generator = XML::Generator::PerlData->new(
                Handler => $self->{Handler} );
            $generator->attrmap(
                { object => [ 'id', 'document_id', 'parent_id', 'level' ] } );
            $generator->parse_chunk( { object => [@objects] } );
        }
        else {
            XIMS::Debug( 4, "no annotations found" );
        }
    }

    $self->SUPER::end_element($elem);

    return;
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

