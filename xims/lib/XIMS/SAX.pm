
=head1 NAME

XIMS::SAX -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX;

use common::sense;
use XML::LibXML;
use XML::SAX::Machines qw( :all );
use XIMS;
use XIMS::SAX::Filter::Date;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
# move these to config?
our $DefaultSAXHandler ||= 'XML::LibXML::SAX::Builder';
our $DefaultSAXGenerator ||= 'XIMS::SAX::Generator::Content';



=head2    XIMS::SAX->new( %args );

=head3 Parameter

    $args{Handler}    : (optional) A blessed reference to a SAX Handler class,
                                    or a string containing the package name of one

    $args{Generator}  : (optional) A blessed reference to a SAX Generator class,
                                   or a string containing the package name of one

    $args{FilterList} : (optional) A list (@array) of SAX Filter package names or
                                    SAX::Machines descriptions.

=head3 Returns

    $self :  XIMS::SAX object

=head3 Description

Constructor

=cut

sub new {
    XIMS::Debug( 5, "called" );
    my $class = shift;
    my %args    = @_;

    my $self;
    if ( defined $args{Handler} ) {
        if ( ! ref( $args{Handler} ) ) {
            my $handler_class =  $args{Handler};
            eval "require $handler_class";
            $args{Handler} = $handler_class->new();
        }
    }
    else {
        eval "require $XIMS::SAX::DefaultSAXHandler";
        $args{Handler} = $XIMS::SAX::DefaultSAXHandler->new();
    }

    if ( defined $args{Generator} ) {
        if ( ! ref( $args{Generator} ) ) {
            my $driver_class =  $args{Generator};
            eval "use $driver_class";
            $args{Generator} = $driver_class->new();
        }
    }
    else {
        eval "use $XIMS::SAX::DefaultSAXGenerator";
        if ( not $@ ) {
            $args{Generator} = $XIMS::SAX::DefaultSAXGenerator->new();
        }
        else {
            die XIMS::Debug( 1, "Could not load $XIMS::SAX::DefaultSAXGenerator" );
        }
    }

    $args{FilterList} ||= [];

    $self = bless \%args, $class;

    XIMS::Debug( 5, "done" );
    return $self;
}




=head2     $sax->parse( $ctxt [, $prependgeneratorfilters] );

=head3 Parameter

     $ctxt:

=head3 Returns

     $parse_result :

=head3 Description

none yet

=cut

sub parse {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my $prependgeneratorfilters = shift;

    # filters passed to this object.
    my @filterlist    = @{$self->{FilterList}};

    # give the Generator a peek at what it's about to parse and alter
    # it, if needed.
    $ctxt = $self->{Generator}->prepare( $ctxt );

    # look for "appendexportfilters" in Exporter.pm to read about the
    # consequences and reasons of the $prependgeneratorfilters flag.
    if ( $prependgeneratorfilters ) {
        unshift( @filterlist, $self->{Generator}->get_filters );
    }
    else {
        push @filterlist, $self->{Generator}->get_filters;
    }

    XIMS::Debug( 6, "using filters: " . join(',', @filterlist));

    # build the filter machine, setting the last stage to the passed
    # Handler

    my $machine = Pipeline( $self->{Generator},
                            @filterlist,
                            $self->{Handler} );

    # get the result and return it.
    my $parse_result = $self->{Generator}->parse( $ctxt );
    return $parse_result;
    XIMS::Debug( 5, "done" );
}


# ###
# Accessors
# ###




=head2     $sax->set_handler( $handler );

=head3 Parameter

     $handler: Name of handler class or reference to handler object

=head3 Returns

     nothing

=head3 Description

sets the handler for the instance $sax

if $handler is not a reference, set_handler() treats the given
argument as a classname and tries to run its constructor

=cut

sub set_handler {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $handler = shift;
    if ( defined( $handler ) ) {
        if ( ! ref( $handler ) ) {
            my $handler_class =  $handler;
            eval "use $handler_class";
            $self->{Handler} = $handler_class->new();
        }
        else {
            $self->{Handler} = $handler;
        }
    }
}




=head2     $sax->set_generator( $generator );

=head3 Parameter

     $generator: Name of generator class or reference to generator object

=head3 Returns

     nothing

=head3 Description

sets the generator for the instance $sax

if $generator is not a reference, set_generator() treats the
given argument as a classname and tries to run its constructor

=cut

sub set_generator {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $generator = shift;
    if ( defined( $generator ) ) {
        if ( ! ref( $generator ) ) {
            my $generator_class =  $generator;
            eval "use $generator_class";
            $self->{Generator} = $generator_class->new();
        }
        else {
            $self->{Generator} = $generator;
        }
    }
}




=head2     $sax->set_filterlist( @filters );

=head3 Parameter

     $ctxt:

=head3 Returns

     nothing

=head3 Description

none yet

=cut

sub set_filterlist {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters = @_;
    $self->{FilterList} = \@filters;
}


# ####
# Legacy stuff
# ####



=head2     $driver->source( { Encoding => $myEncoding } );

=head3 Parameter

     $options_hash: A hash of options to describe the source

=head3 Returns

     nothing

=head3 Description

This lets one set the encoding wanted for the DOM. It takes only the
Encoding option and ignores the rest. Be aware that the setting of
the encoding will work ONLY with XML::LibXML::SAX::Builder.

=cut

sub source {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $opts = shift;
    $self->{Encoding} = $opts->{Encoding};
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

