
=head1 NAME

XIMS::SAX::Filter::DataCollector

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::DataCollector;

=head1 DESCRIPTION

This is a basic SAX Filter that provides some functions that should
make it easier to write extensions that collect data from various
positions (such as search or portlets)

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::DataCollector;

use common::sense;
use parent qw( XML::Filter::GenericChunk );
use XML::Generator::PerlData;
use XML::LibXML;




=head2    XIMS::SAX::Filter::DataCollector->new();

=head3 Parameter

    ?

=head3 Returns

    $self : XIMS::SAX::Filter::DataCollector instance

=head3 Description

Constructor

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{Columns}      ||= [];
    $self->{PreserveData} ||= 0;

    return $self;
}



=head2    $filter->preserve_data($boolean);

=head3 Parameter

    $boolean

=head3 Returns

    $self->{PreserveData}

=head3 Description

sometimes it is nessecary to keep the collected data in the SAX
chain. this function sets (or reads) a flag, that toggels the
filters behaviour. If preserve_data is TRUE (1), the data will be
still available as the character data it was originally collected.

=cut

sub preserve_data {
    my $self = shift;
    $self->{PreserveData} = shift if scalar @_;
    $self->{PreserveData} ||= 0;

    return $self->{PreserveData};
}



=head2    $filter->get_data_fragment()

=head3 Parameter

    none

=head3 Returns

    $self->{Fragment}

=head3 Description

get_data_fragment() overloads the version provided by
XML::SAX::Filter::GenericChunk. Since XML::SAX::Filter::GenericChunk
will forget about the fragment once it's parsed, we have to cache
the fragment for multiple usage.

=cut

sub get_data_fragment {
    my $self = shift;
    unless ( defined $self->{Fragment} ) {
        my $fragment;
        eval { $fragment = $self->SUPER::get_data_fragment(); };
        if ($@) {
            XIMS::Debug( 6, "data is not a fragment" . $@ );
            return;
        }
        $self->{Fragment} = $fragment;
    }
    return $self->{Fragment};
}



=head2    $filter->get_content()

=head3 Parameter

    none

=head3 Returns

    $self->{Content}

=head3 Description

Accessor for the "content" node.

=cut

sub get_content {
    my $self = shift;
    unless ( defined $self->{Content} ) {
        if ( $self->get_data_fragment ) {
            my ($content)
                = grep { $_->nodeName eq "content" }
                $self->get_data_fragment->childNodes;
            $self->{Content} = $content;
        }
    }
    return $self->{Content};
}



=head2    $filter->push_listobject( $object | @object );

=head3 Parameter

    $object, @object

=head3 Returns

    nothing

=head3 Description

this function will push a certain object or object list to the list
of objects that will be processed.

=cut

sub push_listobject {
    my $self = shift;

    $self->{ObjectList} = [] unless defined $self->{ObjectList};
    push @{ $self->{ObjectList} }, @_;

    return;
}



=head2    $filter->end_element()

=head3 Parameter

    $data

=head3 Returns

    nothing

=head3 Description

none yet

=cut

sub end_element {
    my $self = shift;
    my $data = shift;

    if ( $self->is_tag() ) {
        XIMS::Debug( 4, "is inside tag!" );
        if ( $self->preserve_data ) {
            XIMS::Debug( 6, "send data" );
            $self->{Handler}->characters( { Data => $self->get_data() } );
            $self->SUPER::end_element($data);
            $self->start_element($data);
        }
        XIMS::Debug( 6, "found data: " . $self->get_data() );
        XIMS::Debug( 6, "handle columns" );
        $self->_handle_columns();

        XIMS::Debug( 6, "handle data" );
        $self->handle_data();

        XIMS::Debug( 6, "end element" );
    }

    $self->SUPER::end_element($data);

    return;
}



=head2    $filter->characters( $data );

=head3 Parameter

    $data :

=head3 Returns

    nothing

=head3 Description

none yet

=cut

sub characters {
    my $self = shift;
    my $data = shift;

    if ( $self->is_tag() && defined $data->{Data} ) {
        $self->add_data( $data->{Data} );
    }
    else {
        $self->SUPER::characters($data);
    }

    return;
}



=head2    $filter->handle_data()

=head3 Parameter

    none

=head3 Returns

    nothing

=head3 Description

has to be overloaded (build the object list!)

=cut

sub handle_data {
    my $self = shift;

    if ( defined $self->{ObjectList} ) {
        my $generator
            = XML::Generator::PerlData->new( Handler => $self->{Handler} );

        my %keys = ();
        map { $keys{$_} = lc($_) } keys %{ $self->{ObjectList}->[0] };

        # to be conform with the schema
        $generator->keymap( \%keys );
        $generator->attrmap(
            { object => [ 'id', 'document_id', 'parent_id', 'level' ] } );
        $generator->parse_chunk( { object => $self->{ObjectList} } );
    }

    return;
}



=head2    $self->_handle_columns()

=head3 Parameter

    none

=head3 Returns

    nothing

=head3 Description

This helper function will initialize the column list provided to the
DataProvider. If there [...???]

=cut

sub _handle_columns {
    my $self = shift;

    unless ( scalar @{ $self->{Columns} } ) {
        my $fragment = $self->get_data_fragment();
        return unless defined $fragment;
        $self->{Fragment} = $fragment;

        # filter the columns
        my ($cols)
            = grep { $_->nodeName() eq "content" } $fragment->childNodes();
        if ( not defined $cols ) {
            XIMS::Debug( 6, "content not defined" );
            my $filter
                = grep { $_->nodeName() eq "filter" } $fragment->childNodes();
            unless ( defined $filter ) {
                my @cols = grep { $_->nodeName() eq "column" }
                    $fragment->childNodes();
                $self->{Columns} = [ map { $_->getAttribute("name") }
                        grep { $_->nodeType == XML_ELEMENT_NODE } @cols ];
            }
        }
        else {
            my @cols = $cols->getChildrenByTagName("column");
            $self->{Columns} = [ map { $_->getAttribute("name") }
                    grep { $_->nodeType == XML_ELEMENT_NODE } @cols ];
            XIMS::Debug( 6, join( ",", @{ $self->{Columns} } ) );
        }
    }

    return;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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

