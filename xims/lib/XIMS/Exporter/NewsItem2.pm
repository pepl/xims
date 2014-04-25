
=head1 XIMS::Exporter::NewsItem2

lowlevel class for newsitem objs.

=cut

package XIMS::Exporter::NewsItem2;

use common::sense;
use parent qw( XIMS::Exporter::Document2 );

use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::ContentObjectPropertyResolver;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self   = shift;
    my @retval = ();

    push @retval, XIMS::SAX::Filter::ContentIDPathResolver->new(
        Provider       => $self->{Provider},
        ResolveContent => [
            qw(
                department_id
                symname_to_doc_id
                )
        ]
        ),
        XIMS::SAX::Filter::ContentObjectPropertyResolver->new(
        User           => $self->{User},
        ResolveContent => [qw( image_id )],
        Properties     => [qw( abstract data_format_name )]
        );

    push @retval, XIMS::SAX::Filter::Attributes->new();

    $self->{Options}->{appendexportfilters} = 1;

    return @retval;
}

1;

