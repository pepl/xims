# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::QueryBuilder::SimpleDB;

use strict;
use base qw( XIMS::QueryBuilder );
use XIMS::User;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    $qb->_build();
#
# PARAMETER
#    none
#
# RETURNS
#    1 on success, undef on failure
#
# DESCRIPTION
#
# Helper method that fills up $self->{criteria}, $self->{properties}, and $self->{order} on success
#
#
sub _build {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $fieldstolookin = $self->{fieldstolookin};
    my $search = $self->{search};
    my $simpledb = $self->{extraargs}->{simpledb};
    $self->{criteria} = [];
    my @values;

    my @property_list = $simpledb->mapped_member_properties();

    my $propsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cisimpledb_members m, cisimpledb_mempropertyvalues pv WHERE c.document_id = d.id AND m.document_id = d.id AND d.parent_id = ? AND pv.member_id = m.id ';

    my $bol;
    my $foundmacro = 0;

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle property-searches first
        my $is_field;
        foreach my $property ( @property_list ) {
            my $propertyname = $property->name();
            if ( $search->[$i] =~ s/^$propertyname://i ) {
                $bol = $self->search_boolean( $search, $i );
                push( @values, $simpledb->document_id(), $property->id(),  "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . $propsearchsubquery . " AND pv.property_id = ? AND LOWER(pv.value) LIKE ?)";
                $is_field++;
            }
        }
        if ( $search->[$i] =~ s/^id://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . " d.id = ?";
            $is_field++;
        }
        next if $is_field;

        if ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                push( @values, "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . "pv.property_id IN (SELECT id FROM cisimpledb_member_properties WHERE mandatory = 1) AND lower(pv.value) LIKE lower(?)";
            }
            elsif ( $search->[$i] eq "(" || $search->[$i] eq ")" ) {
               $search->[$i] = $bol . $search->[$i];
            }
        }
    }

    # hard work done, compose search-condition-string
    $self->{criteria}->[0] = '(' . join(' ', @{$search}) . ')';
    $self->{criteria}->[0] .= ' AND ci_content.published = 1' if $self->{filterpublished};
    push( @{$self->{criteria}}, @values );
    
    return 1;
}

1;
