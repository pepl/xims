
=head1 NAME

XIMS::DocBookXML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::DocBookXML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::DocBookXML;

use common::sense;
use parent qw( XIMS::Document );
use XIMS::DataFormat;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    my $docbookxml = XIMS::DocBookXML->new( [ %args ] )

=head3 Parameter

    %args        (optional) :  Takes the same arguments as its super
                               class XIMS::Document

=head3 Returns

    $docbookxml    : instance of XIMS::DocBookXML

=head3 Description

Fetches existing objects or creates a new instance of XIMS::DocBookXML
for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'DocBookXML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my $docbookxml = $docbookxml->validate( [ %args ] );

=head3 Parameter

    %args    (optional)
       recognized keys  (optional):
                        public : Used to set a custom PUBLIC identifier for
                                 a DocBook DTD. If not set, 
                                 "-//OASIS//DTD DocBook XML V4.3//EN"
                                 will be used.
                        system : Used to set a custom SYSTEM identifier for a
                                 DocBook DTD. If not set,
                                 "http://www.docbook.org/xml/4.3/docbookx.dtd"
                                 will be used.
                        string : An XML string to be validated. If not set
                                 $self->body() will be used for validation

=head3 Returns

    True or false

=head3 Description

Validates the XIMS::DocBookXML object against a DocBook DTD

=cut

sub validate {
    XIMS::Debug( 5, "called" );
    my $self        = shift;
    my %args        = @_;

    my $public = $args{public} || "-//OASIS//DTD DocBook XML V4.3//EN";
    my $system = $args{system} || "http://www.docbook.org/xml/4.3/docbookx.dtd";
    my $string = $args{string} || $self->body();

    my $dtd = XML::LibXML::Dtd->new( $public, $system );
    my $doc;
    eval {
        $doc = XML::LibXML->new->parse_string( $string );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "string is not well-formed" );
        return;
    }

    eval {
        $doc->validate( $dtd )
    };
    if ( $@ ) {
        XIMS::Debug( 3, "string is not valid: $@" );
        return;
    }
    else {
        return 1;
    }
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

