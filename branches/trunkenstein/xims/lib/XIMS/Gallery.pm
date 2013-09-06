
=head1 NAME

XIMS::Gallery -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id: Gallery.pm 2216 2009-06-17 12:16:25Z haensel $

=head1 SYNOPSIS

    use XIMS::Gallery;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Gallery;

use common::sense;
use parent qw( XIMS::Folder );
#use XIMS::Portlet;
#use XIMS::URLLink;
use XIMS::DataFormat;
use XIMS::Importer::Object;
use XIMS::Importer::Object::URLLink;

use XML::LibXML;

our ($VERSION) = ( q$Revision: 2216 $ =~ /\s+(\d+)\s*$/ );



=head2    XIMS::Gallery->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $dept: XIMS::Gallery instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'Gallery' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

sub _getbodyfragment {
    my $self = shift;

    my $parser = XML::LibXML->new();
    my $fragment;
    eval {
        $fragment = $parser->parse_balanced_chunk( $self->body );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "problem with the gallery body ($@)"  );
        return;
    }

    return $fragment;
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

Copyright (c) 2002-2011 The XIMS Project.

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

