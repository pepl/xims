# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibAuthor;

use strict;
use XIMS::AbstractClass;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;

##
#
# SYNOPSIS
#    my $author = XIMS::VLibAuthor->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing author.
#    $args{ lastname }            (optional) :  lastname of a VLibAuthor. To be used together with $args{middlename}, $args{firstname}, or, in combination with $args{object_type} in case of corpauthors to look up an existing author.
#    $args{ middlename }          (optional) :  middlename of a VLibAuthor. To be used together with $args{lastname} and $args{firstname} to look up an existing author.
#    $args{ firstname }           (optional) :  firstname of a VLibAuthor. To be used together with $args{lastname} and $args{middlename} to look up an existing author.
#    $args{ object_type }         (optional) :  object_type of a VLibAuthor. To be used together with $args{lastname} to look up an existing author.
#
# RETURNS
#    $author    : Instance of XIMS::VLibAuthor
#
# DESCRIPTION
#    Fetches existing authors or creates a new instance of XIMS::VLibAuthor.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{lastname}) and defined( $args{middlename} ) and defined( $args{firstname} ) ) or ( defined( $args{lastname}) and defined( $args{object_type} ) ) ) {
            # For the DB "'' IS NULL"
            $args{middlename} = undef if (exists $args{middlename} and $args{middlename} eq '');
            $args{firstname} = undef if (exists $args{firstname} and $args{firstname} eq '');
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get'.$rt;
            my $data = $self->data_provider->$method( %args );
            if ( defined( $data )) {
               $self->data( %{$data} );
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

1;
