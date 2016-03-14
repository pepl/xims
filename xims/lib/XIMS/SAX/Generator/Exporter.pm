
=head1 NAME

XIMS::SAX::Generator::Exporter

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::Exporter;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::Exporter;

use common::sense;
use parent qw( XIMS::SAX::Generator::Content );
use XML::Filter::CharacterChunk;




=head2    $generator->prepare( $ctxt );

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData

=head3 Description



=cut

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self         = shift;
    my $ctxt         = shift;
    my %object_types = ();
    my %data_formats = ();

    $self->{FilterList} =
        [ XML::Filter::CharacterChunk->new( TagName => [qw(body rights bibliosource)] ) ];

    my $doc_data = { context => {} };

    $doc_data->{context}->{object} = { $ctxt->object->data() };

    $self->_set_parents( $ctxt, $doc_data, \%object_types, \%data_formats );

    $object_types{ $ctxt->object->object_type_id() } = 1;
    $data_formats{ $ctxt->object->data_format_id() } = 1;

    if ( $ctxt->properties->content->childrenbybodyfilter ) {
        $doc_data->{context}->{object}->{children} = $ctxt->object->body();
        delete $doc_data->{context}->{object}->{body};
    }
    else {
        $self->_set_children( $ctxt, $doc_data, \%object_types,
            \%data_formats );
    }

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types,
        \%data_formats );

    return $doc_data;
}

# helper function to fetch the children.
sub _set_children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    my $object = $ctxt->object();

    my @keys = ( $object->id(), $ctxt->user->id() );
    push( @keys, @{ $ctxt->properties->content->getchildren->objecttypes } )
        if defined $ctxt->properties->content->getchildren->objecttypes;
    my $cachekey = join( '.', @keys );

    my $children;
    if ( defined $ctxt->object->data_provider->{ocache}->{kids}->{$cachekey} )
    {
        $children
            = $ctxt->object->data_provider->{ocache}->{kids}->{$cachekey};
    }
    else {
        my %childrenargs = ( published => 1, User => $ctxt->user )
            ;    # only get published children
        my @object_type_ids;
        if ( $ctxt->properties->content->getchildren->objecttypes
            and
            scalar @{ $ctxt->properties->content->getchildren->objecttypes }
            > 0 )
        {
            my $ot;
            foreach my $name (
                @{ $ctxt->properties->content->getchildren->objecttypes } )
            {
                $ot = XIMS::ObjectType->new( fullname => $name );
                push( @object_type_ids, $ot->id() ) if defined $ot;
            }
            $childrenargs{object_type_id} = \@object_type_ids;
        }

        my @children;
        if ($object->{ObjectType}->is_fs_container == 1) {
            # container.xml files should contain ALL children, not a selection of
            # granted objects depending on the last publisher. Sideeffects?
            # What about DocumentLinks?
            @children = $object->children(published => 1)
        }
        else {
            @children = $object->children_granted(%childrenargs);
        }
        $children = \@children;
        $ctxt->object->data_provider->{ocache}->{kids}->{$cachekey}
            = $children;
    }
    if ( scalar(@$children) > 0 ) {
        foreach my $child (@$children) {

            # remember the seen objecttypes
            $object_types->{ $child->object_type_id() } = 1;
            $data_formats->{ $child->data_format_id() } = 1;
        }
    }

    $doc_data->{context}->{object}->{children} = { object => $children };

    return;
}

sub _set_parents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    return if $ctxt->object->id() == 1;
    my $cachekey = $ctxt->object->parent_id();
    my $ancestors;
    if ( defined $ctxt->object->data_provider->{ocache}->{ancs}->{$cachekey} )
    {
        $ancestors
            = $ctxt->object->data_provider->{ocache}->{ancs}->{$cachekey};
    }
    else {
        $ancestors = $ctxt->object->ancestors();

        # remove /root
        shift @{$ancestors};
        $ctxt->object->data_provider->{ocache}->{ancs}->{$cachekey}
            = $ancestors;
    }

    if ( defined $ancestors && scalar( @{$ancestors} ) > 0 ) {
        foreach my $parent ( @{$ancestors} ) {
            $object_types->{ $parent->object_type_id } = 1;
            $data_formats->{ $parent->data_format_id } = 1;

        }
        $doc_data->{context}->{object}->{parents} = { object => $ancestors };
    }

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

