# Copyright (c) 2002-2006 The XIMS Project.
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

    my $sql = 'SELECT s.name, s.id, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = ? GROUP BY s.name, s.id';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );

    return $sidata;
}

sub vlsubjectinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlsubjectinfo() if $user->admin();

    my ($userprivsql, @userprivids) = $self->_userpriv_where_clause( $user );

    my $sql = 'SELECT s.name, s.id, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY s.name, s.id';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id(), @userprivids ] );

    return $sidata;
}

sub vlkeywordinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT s.name, s.id, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_keywordmap m, cilib_keywords s, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.keyword_id = s.ID AND d.id = c.document_id AND d.parent_id = ? GROUP BY s.name, s.id';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );

    return $sidata;
}

sub vlkeywordinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlkeywordinfo() if $user->admin();

    my ($userprivsql, @userprivids) = $self->_userpriv_where_clause( $user );

    my $sql = 'SELECT s.name, s.id, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_keywordmap m, cilib_keywords s, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.keyword_id = s.ID AND d.id = c.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY s.name, s.id';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id(), @userprivids ] );

    return $sidata;
}

sub vlauthorinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(c.id) AS object_count FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = ? GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );

    return $sidata;
}

sub vlauthorinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlauthorinfo() if $user->admin();

    my ($userprivsql, @userprivids) = $self->_userpriv_where_clause( $user );

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(DISTINCT c.id) AS object_count FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id(), @userprivids ] );

    return $sidata;
}

sub vlpublicationinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, count(c.id) AS object_count FROM cilib_publicationmap m, cilib_publications p, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.publication_id = p.ID AND d.id = c.document_id AND d.parent_id = ? GROUP BY p.id, p.name, p.volume, p.isbn, p.issn';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );

    return $sidata;
}

sub vlpublicationinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlpublicationinfo() if $user->admin();

    my ($userprivsql, @userprivids) = $self->_userpriv_where_clause( $user );

    my $sql = 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, count(DISTINCT c.id) AS object_count FROM cilib_publicationmap m, cilib_publications p, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.publication_id = p.ID AND d.id = c.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY p.id, p.name, p.volume, p.isbn, p.issn';
    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id(), @userprivids ] );

    return $sidata;
}

sub vlitems_bysubject {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'subject', @_ );
}

sub vlitems_bykeyword {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'keyword', @_ );
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

sub vlitems_bysubject_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'subject', filter_granted => 1, @_ );
}

sub vlitems_bykeyword_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'keyword', filter_granted => 1, @_ );
}


sub vlitems_byauthor_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'author', filter_granted => 1, @_ );
}

sub vlitems_bypublication_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'publication', filter_granted => 1, @_ );
}


# for chronicle
sub vlitems_bydate {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date_from = shift;
    my $date_to = shift;
    my $key = 'document_id';
    my %args = @_;
    my $filter_granted = delete $args{filter_granted};
    
    # if date_from or date_to is not provided as parameter the timespan is from 0000-01-01 to 2100-01-01
    # should be from the first available chronicle_item date to the last one, later to come
    if (!$date_from) {$date_from='0000-01-01'}
    if (!$date_to) {$date_to='2100-01-01'}
    

    # think of fetching the whole object data here for performance
    my $sql = 'SELECT d.id AS id FROM cilib_meta m, ci_documents d, ci_content c WHERE d.ID = m.document_id AND d.ID = c.document_id AND d.parent_id = ? AND ';
    $sql .= '( ( m.date_from_timestamp >= \''.$date_from.'\' AND m.date_to_timestamp <= \''.$date_to.'\' ) OR ';
    $sql .= '( m.date_from_timestamp <= \''.$date_from.'\' AND m.date_to_timestamp >= \''.$date_from.'\' ) OR ';
    $sql .= '( m.date_from_timestamp <= \''.$date_to.'\' AND m.date_to_timestamp >= \''.$date_to.'\' ) ) order by m.date_from_timestamp asc';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ]);

    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    if ( $filter_granted and not $self->User->admin() ) {
        my @candidate_data = $self->data_provider->getObject( document_id => \@ids,
                                                              properties => [ 'document_id', 'id' ] );
        my @candidate_ids = map{ $_->{'content.id'} } @candidate_data;
        @ids = $self->__filter_granted_ids( candidate_ids => \@candidate_ids );
        return () unless scalar( @ids ) > 0;
        $key = 'id';
    }

    # should be grepped from event/resource type specific list in XIMS::Names
    my @default_properties = grep { $_ ne 'body' and $_ ne 'binfile' }  @{XIMS::Names::property_interface_names( 'Object' )};

    my @data = $self->data_provider->getObject( $key => \@ids, properties => \@default_properties );
    my @objects = map { XIMS::VLibraryItem->new->data( %{$_} ) } @data;

    return @objects;
}


sub _vlobjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = shift;

    my $sql = 'select DISTINCT m.'.$type.'_id AS ID from cilib_'.$type.'map m, ci_documents d where d.id = m.document_id and d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );
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
    my $key = 'document_id';
    my $filter_granted = delete $args{filter_granted};

    my $propertyid = delete $args{$property."_id"};
    return undef unless $propertyid;

    # think of fetching the whole object data here for performance
    my $sql = 'SELECT d.id AS id FROM cilib_'.$property.'map m, cilib_'.$property.'s p, ci_documents d, ci_content c WHERE d.ID = m.document_id AND d.ID = c.document_id AND m.'.$property.'_id = p.ID AND p.id = ? AND d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $propertyid, $self->document_id() ], %args );

    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    if ( $filter_granted and not $self->User->admin() ) {
        my @candidate_data = $self->data_provider->getObject( document_id => \@ids,
                                                              properties => [ 'document_id', 'id' ] );
        my @candidate_ids = map{ $_->{'content.id'} } @candidate_data;
        @ids = $self->__filter_granted_ids( candidate_ids => \@candidate_ids );
        return () unless scalar( @ids ) > 0;
        $key = 'id';
    }

    # should be grepped from event/resource type specific list in XIMS::Names
    my @default_properties = grep { $_ ne 'body' and $_ ne 'binfile' }  @{XIMS::Names::property_interface_names( 'Object' )};

    my @data = $self->data_provider->getObject( $key => \@ids, properties => \@default_properties );
    my @objects = map { XIMS::VLibraryItem->new->data( %{$_} ) } @data;

    return @objects;
}

sub _userpriv_where_clause {
    my $self = shift;
    my $user = shift;
    my @role_ids = ( $user->role_ids(), $user->id() );

    return (" AND c.id = o.content_id AND o.grantee_id IN (" . join(',', map { '?' } @role_ids) . ") AND o.privilege_mask > 0", @role_ids);
}

1;
