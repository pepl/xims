# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Names;

use strict;
use vars qw( @ResourceTypes %Properties $VERSION );

use XIMS::Config::Names;

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

%Properties = XIMS::Config::Names::Properties();
@ResourceTypes = XIMS::Config::Names::ResourceTypes();

sub get_URI {
    my ($r_type, $property_name) = @_;
    XIMS::Debug( 1, "Unknown resource type '$r_type'!" ) unless grep { $_ eq $r_type} @ResourceTypes;
    if ( $r_type eq 'Object' ) {
        my ( $p, $t ) = reverse ( split /\./, $property_name );
        if ( $t ) {
            return $property_name;
        }
        if ( grep { $_ =~ /^.+?\.$property_name$/ } @{$Properties{Content}} ) {
            return 'content' . '.' . $property_name;
        }
        else {
            return 'document' . '.' . $property_name;
        }
    }
    return $property_name =~ /\./go ? $property_name : lc( $r_type ) . '.' . $property_name;
}

sub property_list {
    my $r_type = shift;
    if ( $r_type ) {
        return $Properties{$r_type};
    }
    else {
        return %Properties;
    }
}

sub property_interface_names {
    my $r_type = shift;
    return [] unless $r_type;
    my @out_list = map{ (split /\./, $_)[1] } @{property_list( $r_type )};
    return \@out_list;
}

sub resource_types {
    return @ResourceTypes;
}

sub properties {
    return %Properties;
}

sub valid_property {
    my ( $r_type, $prop_name ) = @_;
    return 1 if grep { $_ eq $prop_name } @{$Properties{$r_type}};
    return undef;
}

1;
