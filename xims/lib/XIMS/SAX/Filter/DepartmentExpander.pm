
=head1 NAME

XIMS::SAX::Filter::DepartmentExpander

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::DepartmentExpander;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::DepartmentExpander;

# departments usually contain more information than dumb
# folders. Since this information is stored within the department's
# body, it has to be expanded before it can be published.

use common::sense;
use parent qw( XML::SAX::Base );
use XIMS::Portlet;
use XML::LibXML;
use XML::Generator::PerlData;


=head2 new()

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return $self;
}

=head2 end_element()

=cut

sub end_element {
    my $self = shift;
    my $data = shift;
    $self->SUPER::end_element($data);
    if ( defined $data->{LocalName} and $data->{LocalName} eq "context" ) {
        my $ol = { LocalName => "objectlist" };
        $ol->{NamespaceURI} = $data->{NamespaceURI};
        $ol->{Prefix}       = $data->{Prefix};
        if ( defined $data->{Prefix} && length $data->{Prefix} ) {
            $ol->{Name} = $data->{Prefix} . ":" . $ol->{LocalName};
        }
        else {
            $ol->{Name} = $ol->{LocalName};
        }
        $self->SUPER::start_element($ol);
        $self->handle_data;
        $self->SUPER::end_element($ol);
    }
    return;
}


=head2    $filter->handle_data()

=head3 Parameter

    none

=head3 Returns

    nothing

=head3 Description


This is the heart of the filter. it writes a list of objects to
the SAX Pipeline

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my %keys     = ();
    my $fragment = $self->{Object}->body();
    my $parser   = XML::LibXML->new;
    my $frag;
    eval { $frag = $parser->parse_balanced_chunk($fragment); };
    unless ( defined $frag ) {
        XIMS::Debug( 3, "no valid body fragment found" );
        return;
    }
    my $generator
        = XML::Generator::PerlData->new( Handler => $self->{Handler} );
    my @portlets = grep {
                $_->nodeType == XML_ELEMENT_NODE
            and $_->nodeName eq "portlet"
    } $frag->childNodes;

    foreach my $p (@portlets) {
        my $oid = $p->string_value();
        next unless ( defined $oid and $oid > 0 );
        my $object = XIMS::Portlet->new(
            id             => $oid,
            User           => $self->{User},
            marked_deleted => 0
        );

        if ( not defined $object ) {
            XIMS::Debug( 4, "portlet id could not be resolved, deleting" );

            # We workaround the portlet_ids not being in a relational
            # structure here
            #
            # Instead of being stored in the body, the portlet
            # assignments should probably be stored in a table like
            # ci_object_relations ( id (pk), from (fk ci_documents.id),
            # to (fk ci_documents.id) )
            #
            # Objects "related" to non-containers (like Documents for
            # example) could still be stored as children of the
            # respective object.  From this, that table could also be
            # called 'ci_deptroot_portlets'...
            #
            $frag->removeChild($p);
            my $newbody = $frag->toString();
            $newbody ||= ' ';    # needs length > 0 (maybe change that in DP?)
            $self->{Object}->body($newbody);
            $self->{Object}->update( User => $self->{User}, no_modder => 1 );
            next;
        }

        if ( $self->{Export} ) {
            next unless $object->published();
        }

        # expand the object's path
        my $path;
        if ( XIMS::RESOLVERELTOSITEROOTS() eq '1' ) {
            $path = $object->location_path_relative();
        }
        else {
            my $siteroot = $object->siteroot();
            my $siteroot_url;
            $siteroot_url = $object->siteroot->url() if $siteroot;
            if ( $siteroot_url =~ m#/# ) {
                $path .= $siteroot_url . $object->location_path_relative();
            }
            else {
                $path .= XIMS::PUBROOT_URL() . $object->location_path();
            }
        }

        $object = { $object->data() };
        $object->{location_path} = $path;
        $generator->parse_chunk( { object => $object } );
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

