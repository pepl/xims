
=head1 NAME

XIMS::SAX::Filter::ContentIDPathResolver -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::ContentIDPathResolver;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::ContentIDPathResolver;



=head2 Please put me somewhere else
 This SAX Filter expands an id or document_id to its
corresponding location_path string.  Note: This version does not touch
the element name and therefore we got path-string in *_id elements!
=cut


use strict;
use base qw( XML::SAX::Base );
use XIMS::Object;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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

        # replace the document_id contained in the current element with the
        # corresponding path
        my $id;
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
        my $path;
        my $export = exists $self->{NonExport} ? '0' : '1';
        my $cachekey = "_cached" . $export . $id . $self->{document_id};
        if ( defined $self->{Provider}->{$cachekey} ) {
            $path = $self->{Provider}->{$cachekey};
        }
        else {
            if ( exists $self->{NonExport} ) {

                # Used for resolving document_ids in the management
                # interface, like DepartmentRoot event edit for example
                $path = $self->{Provider}
                    ->location_path( $id => $self->{document_id} );
            }
            else {

                # Used to resolve the document_ids during exports
                $path = $self->{Provider}
                    ->location_path( $id => $self->{document_id} );
                if ( defined $path ) {
                    if ( XIMS::RESOLVERELTOSITEROOTS() ) {

                    # snip off the site portion of the path ('/site/somepath')
                        $path =~ s/^\/[^\/]+//;
                        if ( defined $self->{PrependSiteRootURL} ) {
                            $path = $self->{PrependSiteRootURL} . $path;
                        }
                    }
                    else {
                        $path = XIMS::PUBROOT_URL() . $path;
                    }
                }
            }
            $self->{Provider}->{$cachekey} = $path;
        }
        $self->SUPER::characters( { Data => $path } );
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

