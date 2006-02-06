# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::DataFormat;

use strict;
use XIMS::AbstractClass;
use XIMS::MimeType;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

#use Data::Dumper;

sub resource_type {
    return 'DataFormat';
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;


sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{mime_type} ) or defined( $args{name} ) or defined( $args{suffix} ) ) {
            my $real_dt = $self->data_provider->getDataFormat( %args );
            if ( defined( $real_dt )) {
               $self->data( %{$real_dt} );
            }
            else {
                # lookup based on alias, is this really needed?
                if ( defined( $args{mime_type} ) ) {
                    my $alias = XIMS::MimeType->new( mime_type => $args{mime_type} );
                    return undef unless defined( $alias );
                    $real_dt = $self->data_provider->getDataFormat( id => $alias->data_format_id() );
                    return undef unless defined( $real_dt );
                    $self->data( %{$real_dt} );
                }
                else {
                    return undef;
                }
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

1;
