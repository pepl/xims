# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::QueryBuilder::ReferenceLibrary;

use strict;
# use warnings;

our $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base 'XIMS::QueryBuilder';
use XIMS::User;

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
    my $reflib = $self->{extraargs}->{reflib};

    my @property_list = $reflib->reference_properties();

    my $propsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cireflib_references r, cireflib_ref_propertyvalues pv WHERE c.document_id = d.id AND r.document_id = d.id AND d.parent_id ='. $reflib->document_id() . ' AND pv.reference_id = r.id ';
    my $serialsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cireflib_references r, cireflib_serials sr WHERE c.document_id = d.id AND r.document_id = d.id AND d.parent_id ='. $reflib->document_id() . ' AND r.serial_id = sr.id ';

    my $bol;
    my $foundmacro = 0;

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle property-searches first
        my $is_field;
        foreach my $property ( @property_list ) {
            my $propertyname = $property->name();
            if ( $search->[$i] =~ s/^$propertyname://i ) {
                $bol = $self->search_boolean( $search, $i );
                $search->[$i] = $bol . $propsearchsubquery . " AND pv.property_id = " . $property->id() . " AND LOWER(pv.value) LIKE '%". lc($search->[$i]) . "%')";
                $is_field++;
            }
        }
        if ($search->[$i] =~ s/^serial://i ) {
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . $serialsearchsubquery . " AND LOWER(sr.title) LIKE '%". lc($search->[$i]) . "%')";
            $is_field++;
        }
        next if $is_field;

        if ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                $search->[$i] = $bol . "(am.author_id in (SELECT id FROM cilib_authors WHERE lower(lastname) LIKE '%". lc($search->[$i]) . "%'))";
            }
            elsif ( $search->[$i] eq "(" || $search->[$i] eq ")" ) {
               $search->[$i] = $bol . $search->[$i];
            }
        }
    }

    # hard work done, compose search-condition-string
    $self->{criteria} = '(' . join(' ', @{$search}) . ')';
    $self->{criteria} .= ' AND ci_content.published = 1' if $self->{filterpublished};
    
    return 1;
}

1;
