# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibrary;

use strict;
use base qw( XIMS::Folder );
use XIMS::DataFormat;
use XIMS::VLibraryItem;
use XIMS::VLibKeyword;
use XIMS::VLibSubject;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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

sub vlauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects( 'Author' );
}

sub vlsubjectinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT s.name, s.id, s.description, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = s.document_id AND d.parent_id = ? GROUP BY s.name, s.id, s.description';
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

    my $sql = 'SELECT s.name, s.id, s.description, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = s.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY s.name, s.id, s.description';
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

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(c.id) AS object_count FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = a.document_id AND d.parent_id = ? GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type';
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

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(DISTINCT c.id) AS object_count FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c, ci_object_privs_granted o WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = a.document_id AND d.parent_id = ? ' . $userprivsql . ' GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type';
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

sub vlitems_bydate_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->vlitems_bydate( @_, filter_granted => 1 );
}

# for chronicle
sub vlitems_bydate {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $date_from = delete $args{from};
    my $date_to = delete $args{to};
    my $filter_granted = delete $args{filter_granted};

    # TODO: parse and validate date here

    my @items;
    my %privmask;

    my $properties = 'd.id AS id, c.document_id, c.abstract, c.title, c.last_modification_timestamp, m.date_from_timestamp, m.date_to_timestamp';
    my $tables = 'cilib_meta m, ci_documents d, ci_content c';
    my $conditions = 'd.ID = m.document_id AND d.ID = c.document_id AND d.parent_id = ? AND m.date_from_timestamp IS NOT NULL';
    my @values = ( $self->document_id() );

    if ( defined $date_from and length $date_from ) {
        $conditions .= " AND m.date_from_timestamp >= ?";
        push @values, $date_from;
    }
    if ( defined $date_to and length $date_to ) {
        $conditions .= " AND m.date_to_timestamp <= ?";
        push @values, $date_to;
    }

    my $order =  'm.date_from_timestamp asc';

    if ( $filter_granted and not $self->User->admin() ) {
        my @userids = ( $self->User->id(), $self->User->role_ids());
        $tables .= ', ci_object_privs_granted p';
        $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
        push @values, @userids;
    }

    my $sql = "SELECT $properties FROM $tables WHERE $conditions";
    my $data = $self->data_provider->driver->dbh->fetch_select(
                                                             sql => [ $sql, @values ],
#                                                             limit => $ctxt->properties->content->getchildren->limit(),
#                                                             offset => $ctxt->properties->content->getchildren->offset(),
                                                             order => $order
                                                             );
    return unless defined $data;

    my @itemids;
    foreach my $kiddo ( @{$data} ) {
        # move meta info to meta key
        $kiddo->{meta}->{date_from_timestamp} = delete $kiddo->{date_from_timestamp};
        $kiddo->{meta}->{date_to_timestamp} = delete $kiddo->{date_to_timestamp};

        push( @items, (bless $kiddo, 'XIMS::VLibraryItem') );
        push( @itemids, $kiddo->{id} );
        $privmask{$kiddo->{id}} = 0xffffffff if $self->User->admin();
    }

    if ( $filter_granted and not $self->User->admin() ) {
        my @uid_list = ($self->User->id(), $self->User->role_ids());
        my @priv_data = $self->data_provider->getObjectPriv( content_id => \@itemids,
                                                         grantee_id => \@uid_list,
                                                         properties => [ 'privilege_mask', 'content_id' ] );
        my %seen = ();
        foreach my $priv ( @priv_data ) {
            next if exists $seen{$priv->{'objectpriv.content_id'}};
            if ( $priv->{'objectpriv.privilege_mask'} eq '0' ) {
                $privmask{$priv->{'objectpriv.content_id'}} = 0;
                $seen{$priv->{'objectpriv.content_id'}}++;
            }
            else {
                $privmask{$priv->{'objectpriv.content_id'}} |= int($priv->{'objectpriv.privilege_mask'});
            }
        }
    }

    if ( scalar( @items ) > 0 ) {
        foreach my $item ( @items ) {
            # Test for explicit lockout (privmask == 0)
            if ( not $privmask{$item->{id}} ) {
                $item = undef; # cheaper than splicing
                next;
            }
            $item->{user_privileges} = XIMS::Helpers::privmask_to_hash( $privmask{$item->{id}} );
        }
    }

    #use Data::Dumper;
    #warn Dumper \@items;

    return @items;
}


sub _vlobjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = shift;
    my $sql;

    if ($type eq 'Author') {
        # currently unmapped authors needed as well...
        $sql = 'SELECT DISTINCT id FROM cilib_'.$type.'s where document_id = ?';
    }
    else {
        $sql = 'select DISTINCT m.'.$type.'_id AS ID from cilib_'.$type.'map m, ci_documents d where d.id = m.document_id and d.parent_id = ?';
    }
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
