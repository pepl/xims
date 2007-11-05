
=head1 NAME

XIMS::SAX::Generator::VLibraryItem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::VLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::VLibraryItem;

use strict;
use base qw(XIMS::SAX::Generator::Content);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# code shared between XIMS::SAX::Generator::VLibraryItem
# and XIMS::SAX::Generator::Exporter::VLibraryItem
sub _insert_vle_common {
    my ( $self, $ctxt, $doc_data ) = splice( @_, 0, 3 );

    my @authors = $ctxt->object->vleauthors();
    $doc_data->{context}->{object}->{authorgroup} = { author => \@authors }
        if ( !( $authors[0] eq undef ) );

    my @keywords = $ctxt->object->vlekeywords();
    $doc_data->{context}->{object}->{keywordset} = { keyword => \@keywords }
        if ( !( $keywords[0] eq undef ) );

    my @subjects = $ctxt->object->vlesubjects();
    $doc_data->{context}->{object}->{subjectset} = { subject => \@subjects }
        if ( !( $subjects[0] eq undef ) );

    my @publications = $ctxt->object->vlepublications();
    $doc_data->{context}->{object}->{publicationset}
        = { publication => \@publications };

    my $meta = $ctxt->object->vlemeta();
    $doc_data->{context}->{object}->{meta} = $meta;

    return;
}



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

    my $doc_data = $self->SUPER::prepare($ctxt);

    # The body won't be parsed by XML::Filter::CharacterChunk with the
    # XML decl. Might be slightly hacky but its effective ;-)
    $doc_data->{context}->{object}->{body} =~ s/^<\?xml[^>]+>//;

    $self->_insert_vle_common( $ctxt, $doc_data );

    if ( $ctxt->properties->application->style() =~ /^edit|^create/ ) {

        my @vlsubjects = $ctxt->object->vlsubjects();
        $doc_data->{context}->{vlsubjects} = { subject => \@vlsubjects }
            if scalar @vlsubjects;

        my @vlkeywords = $ctxt->object->vlkeywords();
        $doc_data->{context}->{vlkeywords} = { keyword => \@vlkeywords }
            if scalar @vlkeywords;

        my @vlauthors = $ctxt->object->vlauthors();
        $doc_data->{context}->{vlauthors} = { author => \@vlauthors }
            if scalar @vlauthors;
    }

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

Copyright (c) 2002-2007 The XIMS Project.

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

