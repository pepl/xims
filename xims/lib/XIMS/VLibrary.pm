# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibrary;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::Folder;
use XIMS::DataFormat;
use XIMS::VLibraryItem;
use XIMS::VLibKeyword;
use XIMS::VLibSubject;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Folder');

##
#
# SYNOPSIS
#    XIMS::VLibrary->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $dept: XIMS::VLibrary instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'VLibrary' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

sub vlkeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects( 'Keyword' );
}

sub vlsubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects( 'Subject' );
}

sub vlpublications {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects( 'Publication' );
}

sub vlsubjectinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT s.name, s.id, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = ' . $self->document_id() . ' GROUP BY s.name, s.id';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => $sql );

    return $sidata;
}

sub vlauthorinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(c.id) AS object_count FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = ' . $self->document_id() . ' GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => $sql );

    return $sidata;
}

sub vlpublicationinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, count(c.id) AS object_count FROM cilib_publicationmap m, cilib_publications p, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.publication_id = p.ID AND d.id = c.document_id AND d.parent_id = ' . $self->document_id() . ' GROUP BY p.id, p.name, p.volume, p.isbn, p.issn';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => $sql );

    return $sidata;
}

sub vlitems_bysubject {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'subject', @_ );
}

sub vlitems_byauthor {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'author', @_ );

}

sub vlitems_bypublication {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'publication', @_ );
}

sub _vlobjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = shift;

    my $sql = 'select m.'.$type.'_id AS ID from cilib_'.$type.'map m, ci_documents d where d.id = m.document_id and d.parent_id = ' . $self->document_id();
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => $sql );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method = "getVLib$type";
    my @data = $self->data_provider->$method( id => \@ids );
    my $class = "XIMS::VLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}

sub _vlitems_byproperty {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $property = shift;
    my %args = @_;

    my $propertyid = delete $args{$property."_id"};
    return undef unless $propertyid;

    # think of fetching the whole object data here for performance
    my $sql = 'SELECT d.id AS id FROM cilib_'.$property.'map m, cilib_'.$property.'s p, ci_documents d WHERE d.ID = m.document_id AND m.'.$property.'_id = p.ID AND p.id = ? AND d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $propertyid, $self->document_id() ], %args );

    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    # should be grepped from event/resource type specific list in XIMS::Names
    my @default_properties = grep { $_ ne 'body' and $_ ne 'binfile' }  @{XIMS::Names::property_interface_names( 'Object' )};

    my @data = $self->data_provider->getObject( document_id => \@ids, properties => \@default_properties );
    my @objects = map { XIMS::VLibraryItem->new->data( %{$_} ) } @data;

    return @objects;
}

1;
