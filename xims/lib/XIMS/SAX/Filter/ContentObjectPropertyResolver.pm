
=head1 NAME

XIMS::SAX::Filter::ContentObjectPropertyResolver -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::ContentObjectPropertyResolver;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::ContentObjectPropertyResolver;

use common::sense;
use parent qw( XML::SAX::Base );
use XIMS::Object;




=head2    XIMS::SAX::Filter::ContentObjectPropertyResolver->new( %args );

=head3 Parameter

    $args{ResolveContent}              : Reference to an array of content object
                                         properties
    $args{User}                        : Instance of XIMS::User
    $args{Properties}     (optional)   : Reference to an array of properties
                                         which should be added

=head3 Returns

    $filter : XIMS::SAX::Filter::ContentObjectPropertyResolver instance

=head3 Description

This SAX Filter adds the property values for the properties specified in
$args{Properties} for the content object property specified in
$args{ResolveContent}.

=cut

sub new {
    my $class = shift;
    return $class->SUPER::new(@_);
}

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName}
        and grep {/^$element->{LocalName}$/i} @{ $self->{ResolveContent} } )
    {
        $self->{got_to_resolve} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}

sub end_element {
    my ( $self, $element ) = @_;

    if (    defined $self->{got_to_resolve}
        and defined $self->{document_id}
        and $self->{document_id} =~ /^[0-9]+$/ )
    {
        my $id;

        # other filters may have fiddled with $element->{LocalName}, so
        # we need to check again and use a fallback otherwise
        if (defined $element->{LocalName}
            and (  $element->{LocalName} eq 'document_id'
                or $element->{LocalName} eq 'department_id'
                or $element->{LocalName} eq 'parent_id'
                or $element->{LocalName} eq 'symname_to_doc_id' )
          )
        {
            $id = 'document_id';
        }
        else {
            $id = 'id';
        }
        my $object;
        my $path;
        my $cachekey = "_copr_cached" . $id . $self->{document_id};
        if ( defined $self->{$cachekey} ) {
            $object = $self->{$cachekey};
        }
        else {
            $self->{Properties} ||= [];

            # add a list of base properties
            push(
                @{ $self->{Properties} },
                qw( id document_id parent_id object_type_id
                    data_format_id symname_to_doc_id location
                    location_path title)
            ) unless exists $self->{PushedDefaultProperties};
            $self->{PushedDefaultProperties}++;

            $object = XIMS::Object->new(
                User       => $self->{User},
                $id        => $self->{document_id},
                properties => $self->{Properties}
            );

            if ( defined $object->{location_path}
                and not exists $self->{NonExport} )
            {
                if ( XIMS::RESOLVERELTOSITEROOTS() ) {

                    # snip off the site portion of the path ('/site/somepath')
                    $object->{location_path} =~ s/^\/[^\/]+//;
                }
                else {
                    $object->{location_path} = XIMS::PUBROOT_URL() . $path;
                }
            }

            $self->{$cachekey} = $object;
        }

        foreach my $property ( @{ $self->{Properties} } ) {
            $self->SUPER::start_element(
                {   Name         => $property,
                    LocalName    => $property,
                    Prefix       => "",
                    NamespaceURI => undef,
                    Attributes   => {}
                }
            );
            $self->SUPER::characters( { Data => $object->{$property} } );
            $self->SUPER::end_element();
        }

        $self->{document_id} = undef;
    }

    $self->{got_to_resolve} = undef;
    $self->SUPER::end_element(@_);

    return;
}

sub characters {
    my ( $self, $string ) = @_;

    if (    defined $string->{Data}
        and defined $self->{got_to_resolve}
        and $self->{got_to_resolve} == 1 )
    {
        $self->{document_id} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
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

