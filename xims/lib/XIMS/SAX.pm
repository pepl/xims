# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX;

use strict;
use XML::LibXML;
use XML::SAX::Machines qw( :all );
use XIMS;
use XIMS::SAX::Filter::Date;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
# move these to config?
our $DefaultSAXHandler ||= 'XML::LibXML::SAX::Builder';
our $DefaultSAXGenerator ||= 'XIMS::SAX::Generator::Content';

##
#
# SYNOPSIS
#    XIMS::SAX->new( %args );
#
# PARAMETERS
#    $args{Handler}    : (optional) A blessed reference to a SAX Handler class,
#                                    or a string containing the package name of one
#
#    $args{Generator}  : (optional) A blessed reference to a SAX Generator class,
#                                   or a string containing the package name of one
#
#    $args{FilterList} : (optional) A list (@array) of SAX Filter package names or
#                                    SAX::Machines descriptions.
#
# RETURNS
#    $self :  XIMS::SAX object
#
# DESCRIPTION
#    Constructor
#
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
        $args{Generator} = $XIMS::SAX::DefaultSAXGenerator->new();
    }

    $args{FilterList} ||= [];

    $self = bless \%args, $class;

    XIMS::Debug( 5, "done" );
    return $self;
}


##
#
# SYNOPSIS
#     $sax->parse( $ctxt [, $prependgeneratorfilters] );
#
# PARAMETERS
#     $ctxt:
#
# RETURNS
#     $parse_result :
#
# DESCRIPTION
#     none yet
#
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


##
#
# SYNOPSIS
#     $sax->set_handler( $handler );
#
# PARAMETERS
#     $handler: Name of handler class or reference to handler object
#
# RETURNS
#     nothing
#
# DESCRIPTION
#     sets the handler for the instance $sax
#
#     if $handler is not a reference, set_handler() treats the given
#     argument as a classname and tries to run its constructor
#
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


##
#
# SYNOPSIS
#     $sax->set_generator( $generator );
#
# PARAMETERS
#     $generator: Name of generator class or reference to generator object
#
# RETURNS
#     nothing
#
# DESCRIPTION
#     sets the generator for the instance $sax
#
#     if $generator is not a reference, set_generator() treats the
#     given argument as a classname and tries to run its constructor
#
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


##
#
# SYNOPSIS
#     $sax->set_filterlist( @filters );
#
# PARAMETERS
#     $ctxt:
#
# RETURNS
#     nothing
#
# DESCRIPTION
#     none yet
#
sub set_filterlist {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters = @_;
    $self->{FilterList} = \@filters;
}


# ####
# Legacy stuff
# ####

##
#
# SYNOPSIS
#     $driver->source( { Encoding => $myEncoding } );
#
# PARAMETERS
#     $options_hash: A hash of options to describe the source
#
# RETURNS
#     nothing
#
# DESCRIPTION
#     This lets one set the encoding wanted for the DOM. It takes only the
#     Encoding option and ignores the rest. Be aware that the setting of
#     the encoding will work ONLY with XML::LibXML::SAX::Builder.
#
sub source {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $opts = shift;
    $self->{Encoding} = $opts->{Encoding};
}

1;
