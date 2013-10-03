
=head1 NAME

XIMS::SAX::Generator::ReferenceLibraryItem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::ReferenceLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::ReferenceLibraryItem;

use common::sense;
use parent qw(XIMS::SAX::Generator::Content);




=head2    $generator->prepare( $ctxt );

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData

=head3 Description



=cut

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $doc_data = $self->SUPER::prepare( $ctxt );

    my $reference_library = $ctxt->object->parent();
    bless $reference_library, 'XIMS::ReferenceLibrary'; # parent isa XIMS::Object
    my @reference_types = $reference_library->reference_types();
    $doc_data->{reference_types} = { reference_type => \@reference_types };

    my @property_list = $ctxt->object->property_list();
    $doc_data->{reference_properties} = { reference_property => \@property_list };

    my @authors = $ctxt->object->vleauthors();
    $doc_data->{context}->{object}->{authorgroup} = { author => \@authors };

    my @editors = $ctxt->object->vleeditors();
    $doc_data->{context}->{object}->{editorgroup} = { author => \@editors };

    my $serial = $ctxt->object->vleserial();
    $doc_data->{context}->{object}->{serial} = $serial if defined $serial;

    my @property_values = $ctxt->object->property_values();
    $doc_data->{context}->{object}->{reference_values} = { reference_value => \@property_values };

    $doc_data->{context}->{object}->{reference_type_id} = $ctxt->object->reference->reference_type_id();

    my @vlauthors = $reference_library->vlauthors();
    $doc_data->{context}->{vlauthors} = { author => \@vlauthors } if scalar @vlauthors;

    my @vlserials = $reference_library->vlserials();
    $doc_data->{context}->{vlserials} = { serial => \@vlserials } if scalar @vlserials;


    return $doc_data;
}

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my %opts = $self->SUPER::get_config();
    $opts{attrmap}->{reference_type} = 'id';
    $opts{attrmap}->{reference_property} = 'id';
    $opts{attrmap}->{reference_value} = 'id';
    $opts{attrmap}->{serial} = 'id';

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

