# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::MimeType;

use strict;
use XIMS::AbstractClass;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

use Data::Dumper;

sub resource_type {
    return 'MimeType';
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
        if ( defined( $args{mime_type} ) ) {
            my $real_mt = $self->data_provider->getMimeType( %args );
            if ( defined( $real_mt )) {
               $self->data( %{$real_mt} );
            }
            else {
                return undef;
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

sub create {
    my $self = shift;
    my $id = $self->data_provider->createMimeType( $self->data());
    $self->data_format_id( $id );
    return $id;
}

sub delete {
    my $self = shift;
    my $retval = $self->data_provider->deleteMimeType( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } $self->fields();
        return 1;
    }
    else {
       return undef;
    }
}

sub update {
    my $self = shift;
    return $self->data_provider->updateMimeType( $self->data() );
}

1;
