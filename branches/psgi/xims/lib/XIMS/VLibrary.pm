
=head1 NAME

XIMS::VLibrary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::VLibrary;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::VLibrary;

use strict;
use base qw( XIMS::Folder );
use XIMS::DataFormat;
use XIMS::VLibraryItem;
use XIMS::VLibKeyword;
use XIMS::VLibSubject;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2    XIMS::VLibrary->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $dept: XIMS::VLibrary instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args  = @_;

    if (
        not(   defined( $args{path} )
            or defined( $args{id} )
            or defined( $args{document_id} ) )
      )
    {
        $args{data_format_id} =
          XIMS::DataFormat->new( name => 'VLibrary' )->id()
          unless defined $args{data_format_id};
    }

    return $class->SUPER::new(%args);
}

=head2 vlkeywords()

=cut

sub vlkeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects('Keyword');
}

=head2 vlsubjects()

=cut

sub vlsubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects('Subject');
}

=head2 vlpublications()

=cut

sub vlpublications {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects('Publication');
}

=head2 vlauthors()

=cut

sub vlauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->_vlobjects('Author');
}

=head2 vlsubjectinfo()

=cut

sub vlsubjectinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT s.name, s.id, s.description, d.object_type_id, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c '
            . 'WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = s.document_id AND d.parent_id = ? '
            . 'GROUP BY s.name, s.id, s.description, d.object_type_id '
            . 'UNION '
            . 'SELECT s.name, s.id, s.description, 0 AS object_type_id, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_subjects s '
            . 'WHERE s.document_id = ? AND NOT EXISTS (select 1 FROM cilib_subjectmap m where m.subject_id = s.id )';
     my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
         $sql, $self->document_id(), $self->document_id() ] );

    return $sidata;
}

=head2 vlsubjectinfo_granted()

=cut

sub vlsubjectinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlsubjectinfo() if $user->admin();

    my ( $userprivsql, @userprivids ) = $self->_userpriv_where_clause($user);

    my $sql = 'SELECT s.name, s.id, s.description, d.object_type_id, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_subjectmap m, cilib_subjects s, ci_documents d, ci_content c, ci_object_privs_granted o '
            . 'WHERE d.ID = m.document_id AND m.subject_id = s.ID AND d.id = c.document_id AND d.parent_id = s.document_id AND d.parent_id = ? '
            . $userprivsql
            . ' GROUP BY s.name, s.id, s.description, d.object_type_id '
            . 'UNION '
            . 'SELECT s.name, s.id, s.description, 0 AS object_type_id, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_subjects s '
            . 'WHERE s.document_id = ? AND NOT EXISTS (select 1 FROM cilib_subjectmap m where m.subject_id = s.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), @userprivids, $self->document_id() ] );

    return $sidata;
}

=head2  this_propertyinfo

=head3 Parameter

one of:

     'subject'     => $subjectid
     'keyword'     => $keywordid
     'author'      => $authorid
     'publication' => $publicationid

=head3 Returns

A reference to an anonymous hash, e.g.:

 $VAR1 = {
           'vlauthorinfo' => {
                               'author' => [
                                             {
                                               'firstname' => 'Leo',
                                               'object_type' => undef,
                                               'middlename' => undef,
                                               'object_count' => '1',
                                               'lastname' => 'XIII.',
                                               'email' => undef,
                                               'url' => undef,
                                               'image_url' => undef,
                                               'id' => '1642'
                                             }
                                           ]
                             }
         };

=head3 Description

Common method to generate and populate the single-entry
vl(author|subject|keyword|publication)info nested data-structure used for
event_(author|subject|keyword|publication).

=cut

sub this_propertyinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my %sql = (
        'subject'     => 'SELECT a.id, a.name, a.description ',
        'keyword'     => 'SELECT a.id, a.name, a.description ',
        'author'      => 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, a.email, a.url, a.image_url ',
        'publication' => 'SELECT a.id, a.name, a.isbn, a.issn, a.volume, a.document_id, a.url, a.image_url ',
    );

    foreach (keys(%sql)) {
        $sql{$_} .= ", (SELECT COUNT(*) FROM cilib_${_}map b WHERE b.${_}_id = a.id) AS object_count "
                 .  "FROM cilib_${_}s a WHERE a.id = ? AND a.document_id = ?";
    }

    my ( $key, $value ) = each %args;
    if ( $sql{$key} ) {
        my $pidata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql{$key}, $value, $self->document_id() ] );
        my $rv = { "vl${key}info" => {"$key" => $pidata} };

        return $rv;
    }
    else {
        XIMS::Debug( 1, "Wrong Parameter!" );
        return;
    }
}

=head2 vlkeywordinfo()

=cut

sub vlkeywordinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT k.name, k.id, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_keywordmap m, cilib_keywords k, ci_documents d, ci_content c '
            . 'WHERE d.ID = m.document_id AND m.keyword_id = k.ID AND d.id = c.document_id AND d.parent_id = ? '
            . 'GROUP BY k.name, k.id '
            . 'UNION '
            . 'SELECT k.name, k.id, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_keywords k '
            . 'WHERE k.document_id = ? AND NOT EXISTS (select 1 FROM cilib_keywordmap m where m.keyword_id = k.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), $self->document_id() ] );

    return $sidata;
}

=head2 vlkeywordinfo_granted()

=cut

sub vlkeywordinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlkeywordinfo() if $user->admin();

    my ( $userprivsql, @userprivids ) = $self->_userpriv_where_clause($user);

    my $sql = 'SELECT k.name, k.id, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_keywordmap m, cilib_keywords k, ci_documents d, ci_content c, ci_object_privs_granted o '
            . 'WHERE d.ID = m.document_id AND m.keyword_id = k.ID AND d.id = c.document_id AND d.parent_id = ? '
            . $userprivsql
            . ' GROUP BY k.name, k.id '
            . 'UNION SELECT k.name, k.id, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_keywords k '
            . 'WHERE k.document_id = ? AND NOT EXISTS (select 1 FROM cilib_keywordmap m where m.keyword_id = k.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), @userprivids, $self->document_id() ] );

    return $sidata;
}

=head2 vlauthorinfo()

=cut

sub vlauthorinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c '
            . 'WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = a.document_id AND d.parent_id = ? '
            . 'GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type '
            . 'UNION '
            . 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_authors a WHERE a.document_id = ? AND NOT EXISTS (select 1 FROM cilib_authormap m where m.author_id = a.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), $self->document_id() ] );

    return $sidata;
}

=head2 vlauthorinfo_granted()

=cut

sub vlauthorinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlauthorinfo() if $user->admin();

    my ( $userprivsql, @userprivids ) = $self->_userpriv_where_clause($user);

    my $sql = 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, count(DISTINCT c.id) AS object_count, max(c.last_modification_timestamp) AS last_modification_timestamp  '
            . 'FROM cilib_authormap m, cilib_authors a, ci_documents d, ci_content c, ci_object_privs_granted o '
            . 'WHERE d.ID = m.document_id AND m.author_id = a.ID AND d.id = c.document_id AND d.parent_id = a.document_id AND d.parent_id = ? '
            . $userprivsql
            . ' GROUP BY a.id, a.lastname, a.middlename, a.firstname, a.object_type '
            . 'UNION '
            . 'SELECT a.id, a.lastname, a.middlename, a.firstname, a.object_type, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_authors a '
            . 'WHERE a.document_id = ? AND NOT EXISTS (select 1 FROM cilib_authormap m where m.author_id = a.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), @userprivids, $self->document_id() ] );

    return $sidata;
}

=head2 vlpublicationinfo()

=cut

sub vlpublicationinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, count(c.id) AS object_count, '
            .        'max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_publicationmap m, cilib_publications p, ci_documents d, ci_content c '
            . 'WHERE d.ID = m.document_id AND m.publication_id = p.ID AND d.id = c.document_id AND d.parent_id = ? '
            . 'GROUP BY p.id, p.name, p.volume, p.isbn, p.issn '
            . 'UNION '
            . 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_publications p '
            . 'WHERE p.document_id = ? AND NOT EXISTS (select 1 FROM cilib_publicationmap m where m.publication_id = p.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), $self->document_id() ] );

    return $sidata;
}

=head2 vlpublicationinfo_granted()

=cut

sub vlpublicationinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlpublicationinfo() if $user->admin();

    my ( $userprivsql, @userprivids ) = $self->_userpriv_where_clause($user);

    my $sql = 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, count(DISTINCT c.id) AS object_count, '
            .        'max(c.last_modification_timestamp) AS last_modification_timestamp '
            . 'FROM cilib_publicationmap m, cilib_publications p, ci_documents d, ci_content c, ci_object_privs_granted o '
            . 'WHERE d.ID = m.document_id AND m.publication_id = p.ID AND d.id = c.document_id AND d.parent_id = ? '
            . $userprivsql
            . ' GROUP BY p.id, p.name, p.volume, p.isbn, p.issn '
            . 'UNION '
            . 'SELECT p.id, p.name, p.volume, p.isbn, p.issn, 0 AS object_count, NULL AS last_modification_timestamp '
            . 'FROM cilib_publications p '
            . 'WHERE p.document_id = ? AND NOT EXISTS (select 1 FROM cilib_publicationmap m where m.publication_id = p.id )';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), @userprivids, $self->document_id() ] );

    return $sidata;
}

=head2 vlmediatypeinfo()

=cut

sub vlmediatypeinfo {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $sql = 'SELECT m.mediatype, count(c.id) AS object_count '
            . 'FROM cilib_meta m, ci_documents d, ci_content c '
            . 'WHERE d.ID = m.document_id AND d.id = c.document_id AND m.mediatype IS NOT NULL AND d.parent_id = ? '
            . 'GROUP BY m.mediatype';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id() ] );

    return $sidata;
}

=head2 vlmediatypeinfo_granted()

=cut

sub vlmediatypeinfo_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->vlmediatypeinfo() if $user->admin();

    my ( $userprivsql, @userprivids ) = $self->_userpriv_where_clause($user);

    my $sql = 'SELECT m.mediatype, count(DISTINCT c.id) AS object_count '
            . 'FROM cilib_meta m, ci_documents d, ci_content c, ci_object_privs_granted o '
            . 'WHERE d.ID = m.document_id AND d.id = c.document_id AND m.mediatype IS NOT NULL AND d.parent_id = ? '
            . $userprivsql
            . ' GROUP BY m.mediatype';

    my $sidata = $self->data_provider->driver->dbh->fetch_select( sql => [
        $sql, $self->document_id(), @userprivids ] );

    return $sidata;
}

=head2 vlitems_bysubject()

=cut

sub vlitems_bysubject {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'subject', @_ );
}

=head2 vlitems_bykeyword()

=cut

sub vlitems_bykeyword {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'keyword', @_ );
}

=head2 vlitems_byauthor()

=cut

sub vlitems_byauthor {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'author', @_ );
}

=head2 vlitems_bypublication()

=cut

sub vlitems_bypublication {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'publication', @_ );
}

=head2 vlitems_bysubject_granted()

=cut

sub vlitems_bysubject_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'subject', filter_granted => 1, @_ );
}

=head2 vlitems_bykeyword_granted()

=cut

sub vlitems_bykeyword_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'keyword', filter_granted => 1, @_ );
}

=head2 vlitems_byauthor_granted()

=cut

sub vlitems_byauthor_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'author', filter_granted => 1, @_ );
}

=head2 vlitems_bypublication_granted()

=cut

sub vlitems_bypublication_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vlitems_byproperty( 'publication', filter_granted => 1, @_ );
}

=head2 vlitems_bydate_granted()

=cut

sub vlitems_bydate_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->vlitems_bydate( @_, filter_granted => 1 );
}

=head2 vlitems_bydate_granted_count()

=cut

sub vlitems_bydate_granted_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->vlitems_bydate_count( @_, filter_granted => 1 );
}

=head2 vlitems_byfilter_granted()

=cut

sub vlitems_byfilter_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->vlitems_byfilter( @_, filter_granted => 1 );
}

=head2 vlitems_byfilter_granted_count()

=cut

sub vlitems_byfilter_granted_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->vlitems_byfilter_count( @_, filter_granted => 1 );
}

=head2 vlitems_byfilter()

=cut

sub vlitems_byfilter {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my %args           = @_;
    my $criteria       = delete $args{criteria};
    my $params         = delete $args{params};
    my $filter_granted = delete $args{filter_granted};
   
    my $order;
    my %p2c = (
        'alpha'   => [ "c.title ",                       "ASC" ],
        'chrono'  => [ "m.date_from_timestamp ",         "ASC" ],
        'dc.date' => [ "m.dc_date ",                     "DESC" ],
        'create'  => [ "c.creation_timestamp ",          "DESC" ],
        'modify'  => [ "c.last_modification_timestamp ", "DESC" ],
        'loctn'   => [ "d.location ",                    "DESC" ],
    );
    my $oopts = join( '|', keys(%p2c) );

    foreach ( split( ',', delete $args{order} ) ) {
        my ( $o, $odir ) = /($oopts)(?:\s+(desc|asc))?/i;
        next unless length $o;
        $order .= ', ' if length $order;
        $order .= $p2c{lc($o)}[0];
        $order .= $odir ? $odir : $p2c{lc($o)}[1];
    }

    my $limit  = delete $args{limit};
    my $offset = delete $args{offset};

    # TODO: parse and validate date here

    my ( $sql, $values ) =
      $self->_vlitems_byfilter_sql( $criteria, $params, $filter_granted, undef, $order );

    my $data = $self->data_provider->driver->dbh->fetch_select(
        sql    => [ $sql, @{$values} ],
        limit  => $limit,
        offset => $offset,
        order  => $order
    );
    return unless defined $data;

    my @itemids;
    my @items;
    my %privmask;
    foreach my $kiddo ( @{$data} ) {

        # move meta info to meta key
        $kiddo->{meta}->{date_from_timestamp} =
          delete $kiddo->{date_from_timestamp};
        $kiddo->{meta}->{date_to_timestamp} =
          delete $kiddo->{date_to_timestamp};
        $kiddo->{meta}->{dc_date} =
          delete $kiddo->{dc_date};
        $kiddo->{meta}->{mediatype} = delete $kiddo->{mediatype};
        $kiddo->{meta}->{publisher} = delete $kiddo->{publisher};
        push( @items, ( bless $kiddo, 'XIMS::VLibraryItem' ) );
        push( @itemids, $kiddo->{id} );
        $privmask{ $kiddo->{id} } = 0xffffffff if $self->User->admin();
    }

    if ( $filter_granted and not $self->User->admin() ) {
        my @uid_list = ( $self->User->id(), $self->User->role_ids() );
        my @priv_data = $self->data_provider->getObjectPriv(
            content_id => \@itemids,
            grantee_id => \@uid_list,
            properties => [ 'privilege_mask', 'content_id' ]
        );
        my %seen = ();
        foreach my $priv (@priv_data) {
            next if exists $seen{ $priv->{'objectpriv.content_id'} };
            if ( $priv->{'objectpriv.privilege_mask'} eq '0' ) {
                $privmask{ $priv->{'objectpriv.content_id'} } = 0;
                $seen{ $priv->{'objectpriv.content_id'} }++;
            }
            else {
                $privmask{ $priv->{'objectpriv.content_id'} } |=
                  int( $priv->{'objectpriv.privilege_mask'} );
            }
        }
    }

    if ( scalar(@items) > 0 ) {
        foreach my $item (@items) {

            # Test for explicit lockout (privmask == 0)
            if ( not $privmask{ $item->{id} } ) {
                $item = undef;    # cheaper than splicing
                next;
            }
            $item->{user_privileges} =
              XIMS::Helpers::privmask_to_hash( $privmask{ $item->{id} } );
        }
    }

    return @items;

}

=head2 vlitems_byfilter_count()

=cut

sub vlitems_byfilter_count {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my %args           = @_;
    my $criteria       = delete $args{criteria};
    my $params         = delete $args{params};
    my $filter_granted = delete $args{filter_granted};

    my ( $sql, $values ) =
      $self->_vlitems_byfilter_sql( $criteria, $params, $filter_granted, 1 );
    my $data =
      $self->data_provider->driver->dbh->fetch_select(
        sql => [ $sql, @{$values} ], );

    return unless defined $data;
    return @{$data}[0]->{count};
}

sub _vlitems_byfilter_sql {
    my $self           = shift;
    my $criteria       = shift;
    my $params         = shift;
    my $filter_granted = shift;
    my $count          = shift;
    my $order          = shift;

    use Data::Dumper;
    XIMS::Debug( 6, "Filter Criteria: " . Dumper($criteria) );
    my %criteria = %{$criteria};
    my %params   = %{$params};

    my $properties;
    if ( defined $count ) {
        $properties = 'count(distinct c.id) AS count';
    }
    else {
        $properties =
            'distinct c.id AS id, d.parent_id, d.location, d.object_type_id, d.data_format_id, c.document_id, '
          . 'c.abstract, c.title, c.last_modification_timestamp, '
          . 'c.status, c.status_checked_timestamp, '
          . 'c.marked_deleted, c.locked_time, c.locked_by_id, c.published';
    }

    # Select Tables
    # create conditions and values
    my $tables     = 'ci_documents d, ci_content c';
    my $conditions = 'd.ID = c.document_id AND d.parent_id = ? AND c.marked_deleted = 0 ';
    my @values     = ( $self->document_id() );
    if (   $criteria{mediatype} ne ''
        || $criteria{chronicle} ne ''
        || $criteria{publisher} ne ''
        || ( defined $order and $order =~ /m\./ ) )
    {
        XIMS::Debug( 6, "Mediatype or Chronicle filter" );
        $tables     .= ', cilib_meta m ';
        $conditions .= "AND d.ID = m.document_id ";
    }
    if ( $criteria{vlprop} ne '' ) {
         XIMS::Debug( 6, "Property filter" );
         $conditions .=  $criteria{vlprop};
         push @values, @{ $params{vlprop} };
    }
    if ( $criteria{object_type_id} ne '' ) {
        XIMS::Debug( 6, "OT filter" );
        $conditions .= " AND " . $criteria{object_type_id};
        push @values, @{ $params{object_type_id} };
    }
    if ( $criteria{mediatype} ne '' ) {
        XIMS::Debug( 6, "Mediatype filter" );
        $properties .= ", m.mediatype" if ( not defined $count );
        $conditions .= " AND " . $criteria{mediatype};
        push @values, $params{mediatype};
    }
    if ( $criteria{publisher} ne '' ) {
        XIMS::Debug( 6, "Publisher filter" );
        $properties .= ", m.publisher" if ( not defined $count );
        $conditions .= " AND " . $criteria{publisher};
        push @values, $params{publisher};
    }
    if ( $criteria{status} ne '' ) {
        XIMS::Debug( 6, "Status filter" );
        $conditions .= " AND " . $criteria{status};
        push @values, $params{status};
    }
    if ( $criteria{chronicle} ne ''
        || ( defined $order and $order =~ /m.date_from_timestamp/ ) )
    {
        XIMS::Debug( 6, "Chronicle filter" );
        $properties .= ", m.date_from_timestamp, m.date_to_timestamp"
          if ( not defined $count );
        if   ( $criteria{chronicle} ) {
            $conditions .= $criteria{chronicle};
            push @values, @{ $params{chronicle} };
        }
    }
    if ( $criteria{text} ne '' ) {
        XIMS::Debug( 6, "Text filter" );
        $conditions .= " AND " . $criteria{text};
        push @values, @{ $params{text} };
    }

    # SELECT DISTINCT requires the order item to be on the select list.
    foreach my $attr ( $order =~ m/([\w.]+)(?:\s(?:asc|desc))?/gi ) {
      $properties .= ", $attr" unless $properties =~ /$attr/;     
    }
    
    if ( $filter_granted and not $self->User->admin() ) {
        my @userids = ( $self->User->id(), $self->User->role_ids() );
        $tables .= ', ci_object_privs_granted p';
        $conditions .=
          ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN ('
          . join( ',', map { '?' } @userids ) . ')';
        push @values, @userids;
    }
    XIMS::Debug( 6,
        "SQL Filter: \n SELECT $properties FROM $tables WHERE $conditions \n"
          . Dumper( \@values ) );
    return ( "SELECT $properties FROM $tables WHERE $conditions", \@values );

}

=head2 vlitems_bydate_count()

=cut

sub vlitems_bydate_count {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my %args           = @_;
    my $date_from      = delete $args{from};
    my $date_to        = delete $args{to};
    my $filter_granted = delete $args{filter_granted};

    my ( $sql, $values ) =
      $self->_vlitems_by_date_sql( $date_from, $date_to, $filter_granted, 1 );
    my $data =
      $self->data_provider->driver->dbh->fetch_select(
        sql => [ $sql, @{$values} ], );

    return unless defined $data;
    return @{$data}[0]->{count};
}

# for chronicle

=head2 vlitems_bydate()

=cut

sub vlitems_bydate {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my %args           = @_;
    my $date_from      = delete $args{from};
    my $date_to        = delete $args{to};
    my $filter_granted = delete $args{filter_granted};

    my $order = delete $args{order};
    $order ||= 'm.date_from_timestamp asc';

    my $limit  = delete $args{limit};
    my $offset = delete $args{offset};

    # TODO: parse and validate date here

    my ( $sql, $values ) =
      $self->_vlitems_by_date_sql( $date_from, $date_to, $filter_granted );
    my $data = $self->data_provider->driver->dbh->fetch_select(
        sql    => [ $sql, @{$values} ],
        limit  => $limit,
        offset => $offset,
        order  => $order
    );
    return unless defined $data;

    my @itemids;
    my @items;
    my %privmask;
    foreach my $kiddo ( @{$data} ) {

        # move meta info to meta key
        $kiddo->{meta}->{date_from_timestamp} =
          delete $kiddo->{date_from_timestamp};
        $kiddo->{meta}->{date_to_timestamp} =
          delete $kiddo->{date_to_timestamp};

        push( @items, ( bless $kiddo, 'XIMS::VLibraryItem' ) );
        push( @itemids, $kiddo->{id} );
        $privmask{ $kiddo->{id} } = 0xffffffff if $self->User->admin();
    }

    if ( $filter_granted and not $self->User->admin() ) {
        my @uid_list = ( $self->User->id(), $self->User->role_ids() );
        my @priv_data = $self->data_provider->getObjectPriv(
            content_id => \@itemids,
            grantee_id => \@uid_list,
            properties => [ 'privilege_mask', 'content_id' ]
        );
        my %seen = ();
        foreach my $priv (@priv_data) {
            next if exists $seen{ $priv->{'objectpriv.content_id'} };
            if ( $priv->{'objectpriv.privilege_mask'} eq '0' ) {
                $privmask{ $priv->{'objectpriv.content_id'} } = 0;
                $seen{ $priv->{'objectpriv.content_id'} }++;
            }
            else {
                $privmask{ $priv->{'objectpriv.content_id'} } |=
                  int( $priv->{'objectpriv.privilege_mask'} );
            }
        }
    }

    if ( scalar(@items) > 0 ) {
        foreach my $item (@items) {

            # Test for explicit lockout (privmask == 0)
            if ( not $privmask{ $item->{id} } ) {
                $item = undef;    # cheaper than splicing
                next;
            }
            $item->{user_privileges} =
              XIMS::Helpers::privmask_to_hash( $privmask{ $item->{id} } );
        }
    }

    return @items;
}

sub _vlitems_by_date_sql {
    my $self           = shift;
    my $date_from      = shift;
    my $date_to        = shift;
    my $filter_granted = shift;
    my $count          = shift;

    my $properties;
    if ( defined $count ) {
        $properties = 'count(distinct c.id) AS count';
    }
    else {
        $properties = 'distinct c.id AS id, d.parent_id, d.location, c.document_id, '
                    . 'c.abstract, c.title, c.last_modification_timestamp, '
                    . 'c.marked_deleted, c.locked_time, c.locked_by_id, '
                    . 'c.published, m.date_from_timestamp, m.date_to_timestamp';
    }
    my $tables = 'cilib_meta m, ci_documents d, ci_content c';
    my $conditions =
      'd.ID = m.document_id AND d.ID = c.document_id AND d.parent_id = ? ';
    my @values = ( $self->document_id() );
    my %date_conditions_values =
      $self->_date_conditions_values( $date_from, $date_to );
    $conditions .= $date_conditions_values{conditions};
    push @values, @{ $date_conditions_values{values} };
    if ( $filter_granted and not $self->User->admin() ) {
        my @userids = ( $self->User->id(), $self->User->role_ids() );
        $tables .= ', ci_object_privs_granted p';
        $conditions .=
' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN ('
          . join( ',', map { '?' } @userids ) . ')';
        push @values, @userids;
    }
    return ( "SELECT $properties FROM $tables WHERE $conditions", \@values );
}

sub _vlobjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = shift;
    my $sql;

    $sql = "SELECT DISTINCT id FROM cilib_${type}s where document_id = ?";

    my $iddata =
      $self->data_provider->driver->dbh->fetch_select(
        sql => [ $sql, $self->document_id() ] );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method  = "getVLib$type";
    my @data    = $self->data_provider->$method( id => \@ids );
    my $class   = "XIMS::VLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}

sub _vlitems_byproperty {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my $property       = shift;
    my %args           = @_;
    my $key            = 'document_id';
    my $filter_granted = delete $args{filter_granted};

    my $propertyid = delete $args{ $property . "_id" };
    return unless $propertyid;

    # TODO think of fetching the whole object data here for performance

    my $sql = 'SELECT d.id AS id FROM cilib_'
      # UIBK  hint to even out buggy optimizer decisions (Oracle)
      #  'SELECT  /*+ FIRST_ROWS(2000) */ d.id AS id FROM cilib_'
      . $property
      . 'map m, cilib_'
      . $property
      . 's p, ci_documents d, ci_content c WHERE d.ID = m.document_id AND d.ID = c.document_id AND m.'
      . $property
      . '_id = p.ID AND p.id = ? AND d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select(
        sql => [ $sql, $propertyid, $self->document_id() ],
        %args
    );

    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    if ( $filter_granted and not $self->User->admin() ) {
        my @candidate_data = $self->data_provider->getObject(
            document_id => \@ids,
            properties  => [ 'document_id', 'id' ]
        );
        my @candidate_ids = map { $_->{'content.id'} } @candidate_data;
        @ids = $self->__filter_granted_ids( candidate_ids => \@candidate_ids );
        return () unless scalar(@ids) > 0;
        $key = 'id';
    }

    # TODO should be grepped from event/resource type specific list in
    # XIMS::Names
    my @default_properties =
      grep { $_ ne 'body' and $_ ne 'binfile' }
      @{ XIMS::Names::property_interface_names('Object') };

    my @data = $self->data_provider->getObject(
        $key       => \@ids,
        properties => \@default_properties
    );
    my @objects = map { XIMS::VLibraryItem->new->data( %{$_} ) } @data;

    return @objects;
}

sub _userpriv_where_clause {
    my $self     = shift;
    my $user     = shift;
    my @role_ids = ( $user->role_ids(), $user->id() );

    return (
        " AND c.id = o.content_id AND o.grantee_id IN ("
          . join( ',', map { '?' } @role_ids )
          . ") AND o.privilege_mask > 0",
        @role_ids
    );
}

sub _date_conditions_values {
    my $self       = shift;
    my $date_from  = shift;
    my $date_to    = shift;
    my $df         = ( defined $date_from and length $date_from );
    my $dt         = ( defined $date_to and length $date_to );
    my $conditions = '';
    my @values     = ();
    if ( $df or $dt ) {
        my $df_null = ' OR m.date_from_timestamp is NULL ';
        my $dt_null = ' OR m.date_to_timestamp is NULL ';
        $conditions .= ' AND ( ';
        if ( $df and $dt ) {
            $conditions .=
' ( ( m.date_from_timestamp >= ? ) AND ( m.date_to_timestamp <= ? ) ) ';
            push @values, ( $date_from, $date_to );
        }
        elsif ( !$dt ) {
            $conditions .= ' ( m.date_from_timestamp >= ? ) ';
            push @values, $date_from;
        }
        else {
            $conditions .= ' ( m.date_to_timestamp <= ? ) ';
            push @values, $date_to;
        }
        if ($df) {
            $conditions .=
                ' OR ( ( m.date_from_timestamp <= ? ' . $df_null
              . ' ) AND ( m.date_to_timestamp >= ? '
              . $dt_null . ' ) ) ';
            push @values, ( $date_from, $date_from );
        }
        if ($dt) {
            $conditions .=
                ' OR ( ( m.date_from_timestamp <= ? ' . $df_null
              . ' ) AND ( m.date_to_timestamp >= ? '
              . $dt_null . ' ) ) ';
            push @values, ( $date_to, $date_to );
        }
        $conditions .= " ) ";
    }
    return ( conditions => $conditions, values => \@values );
}

=head2 private functions/methods

=over

=item _vlitems_byfilter_sql()

=item _vlitems_by_date_sql()

=item _vlobjects()

=item _vlitems_byproperty()

=item _userpriv_where_clause()

=item _date_conditions_values()

=back

=cut

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

