# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package XIMS::DataProvider::DBI;

use strict;
use XIMS;
use XIMS::Names;
use DBIx::SQLEngine 0.017;
use DBIx::SQLEngine::Criteria::And;
use XIMS::DataProvider;
use vars qw( %Tables %Names %PropertyAttributes %PropertyRelations $VERSION);
#use Data::Dumper;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

# now only needs scalar refs (for sql literals). The previous was
# a premature and unneeded 'enhancement'.

# move to Config.pm, pull in via XIMS.pm or XIMS::DataProvider::DBI::Names...
%PropertyAttributes = (
    'content.id'                          => \'ci_content_id_seq_nval()',
    'user.id'                             => \'ci_users_roles_id_seq_nval()',
    'session.id'                          => \'ci_sessions_id_seq_nval()',
    'session.last_access_timestamp'       => \'now()',
    'document.id'                         => \'ci_documents_id_seq_nval()',
    'bookmark.id'                         => \'ci_bookmarks_id_seq_nval()',
    'language.id'                         => \'ci_languages_id_seq_nval()',
    'objecttype.id'                       => \'ci_object_types_id_seq_nval()',
    'dataformat.id'                       => \'ci_data_formats_id_seq_nval()',
    'mimetype.id'                         => \'ci_mime_aliases_id_seq_nval()',
    'questionnaireresult.id'              => \'ci_quest_results_id_seq_nval()',
    'vlibauthor.id'                       => \'cilib_authors_id_seq_nval()',
    'vlibauthormap.id'                    => \'cilib_authormap_id_seq_nval()',
    'vlibkeyword.id'                      => \'cilib_keywords_id_seq_nval()',
    'vlibkeywordmap.id'                   => \'cilib_keywordmap_id_seq_nval()',
    'vlibsubject.id'                      => \'cilib_subjects_id_seq_nval()',
    'vlibsubjectmap.id'                   => \'cilib_subjectmap_id_seq_nval()',
    'vlibpublication.id'                  => \'cilib_publications_id_seq_nval()',
    'vlibpublicationmap.id'               => \'cilib_publmap_id_seq_nval()',
    'vlibmeta.id'                         => \'cilib_meta_id_seq_nval()',
);

# move to Config.pm, pull in via XIMS.pm or XIMS::DataProvider::DBI::Names...
%PropertyRelations = (
    'Object' => { 'document.id' => \'ci_content.document_id' }
);

# move to Config.pm, pull in via XIMS.pm or XIMS::DataProvider::DBI::Names...
%Tables = (
            content        => 'ci_content',
            user           => 'ci_users_roles',
            session        => 'ci_sessions',
            document       => 'ci_documents',
            objecttype     => 'ci_object_types',
            userpriv       => 'ci_roles_granted',
            objectpriv     => 'ci_object_privs_granted',
            objecttypepriv => 'ci_object_type_privs',
            dataformat     => 'ci_data_formats',
            language       => 'ci_languages',
            mimetype       => 'ci_mime_type_aliases',
            bookmark       => 'ci_bookmarks',
            questionnaireresult => 'ci_questionnaire_results',
            vlibauthor          => 'cilib_authors',
            vlibauthormap       => 'cilib_authormap',
            vlibkeyword         => 'cilib_keywords',
            vlibkeywordmap      => 'cilib_keywordmap',
            vlibsubject         => 'cilib_subjects',
            vlibsubjectmap      => 'cilib_subjectmap',
            vlibpublication     => 'cilib_publications',
            vlibpublicationmap  => 'cilib_publicationmap',
            vlibmeta            => 'cilib_meta',
          );


%Names =  reverse ( %Tables );

my @AllProps = map {@{$_}} values %XIMS::Names::Properties;

sub resolve_resource {
    # here is where we resolve the uri-id to the tables and fields
    # in the database.
    # we can autogen here, all drivers might not be able to
    my $self = shift;
    my $resource_id = shift;
    my ($r_type, $property_name) = split /\./, $resource_id;
    my $table_name = $Tables{$r_type};
    return [ $table_name,  $table_name . '.' . $property_name ];
}

##################################################################################
# Core Methods
##################################################################################
# These are the low-level methods for getting data into and out of the
# the DB.
##################################################################################

sub get {
    my ($self, %args) = @_;
    my @qualified_names = keys( %{$args{properties}} );
    my ($tables, $columns) = $self->tables_and_columns_get( $args{properties} );
    my $crit = $self->crit_get( $args{conditions} );
    my @columns = keys( %{$columns} );
    my $data = $self->{dbh}->fetch_select( tables   => $tables,
                                           columns  => \@columns,
                                           criteria => $crit );

    my @out = map { name_fixer( $_ ) } @{$data};
    #warn "Driver returned: " . Dumper( \@out ) . "\n";
    return  \@out;
}

sub create {
    my ($self, %args) = @_;
    #warn "create called " . Dumper( $args{properties} ) . "\n";
    foreach ( keys( %{$args{properties}} ) ) {
       $args{properties}->{$_} = set_attributes( $_ ) || $args{properties}->{$_}
    }
    my ($table, $column_map) = $self->tables_and_columns( $args{properties} );
    # warn "and after " . Dumper( $column_map ) . "\n";
    my $test = $self->{dbh}->do_insert( table    => $table->[0],
                                        values   => $column_map );

    if ( $test ) {
        # to make things friendlier for the object and app classes,
        # we'll select back the auto-generated id of the data we
        # of the data we just inserted.

        return $test if $table->[0] eq 'ci_object_privs_granted'; # no data that the app class doesn't already know about.

        my $r_type = $Names{$table->[0]};
        my $id_col_name;
        my @select_crits = ();
        foreach my $column ( keys( %{$column_map} ) ) {
            my $reverse_lookup = $r_type . '.' . $column;
            if ( $column eq 'id' ) {
                $id_col_name = $column;
                delete $column_map->{$column};
            }
            elsif ( ( not defined( $column_map->{$column})) ||
                    ( $column_map->{$column} eq '' ) ||
                    ( $column =~ /time/gi ) ||
                    ( defined( $PropertyAttributes{"$reverse_lookup"})) ) {
                delete $column_map->{$column};
            }
            else {
               push @select_crits, DBIx::SQLEngine::Criteria->auto( { $column => $column_map->{$column} } );
            }
        }

        my $select_crits = DBIx::SQLEngine::Criteria::And->new( @select_crits );
        my $id_list = $self->{dbh}->fetch_select( table    => $table->[0],
                                                  columns  => [ $id_col_name ],
                                                  criteria => $select_crits
                                                 );

        #warn "IDS in Table " . $table->[0] . " : " . Dumper( $id_list );
        return undef unless scalar( @{$id_list} ) > 0 ;
        #warn "we got here because: ", scalar( @{$id_list} );
        #warn "we will return: ", $id_list->[-1]->{id};
        return $id_list->[-1]->{id};
    }
    else {
        return undef;
    }
}


sub delete {
    my ($self, %args) = @_;
    my ($table, $columns) = $self->tables_and_columns( $args{properties} );

    my $crit = $self->crit( $args{conditions} );
    return $self->{dbh}->do_delete( table     => $table->[0],
                                    criteria  => $crit );
}


sub update {
    my ($self, %args) = @_;
    my ($table, $column_map) = $self->tables_and_columns( $args{properties} );
    my $crit = $self->crit( $args{conditions} );
    my $table_name = $table->[0];

    my $data = $self->{dbh}->do_update( table    => $table_name,
                                        values   => $column_map,
                                        criteria => $crit );

    #warn "In update. Driver returned: " . Dumper( $data ) . "\n";
    return $data;
}

##################################################################################
# Helper Methods
##################################################################################
# These are helper subs for munging SQL queries and returned data
##################################################################################

sub name_fixer {
    my $row = shift;
    my %out_row = ();
    foreach ( keys( %{$row} ) ) {
        my $out_name;
        my ($token, $idx) =  split(/__/, $_);
        if ( defined( $idx )) {
            $out_name = $AllProps[$idx];
        }
        else {
            $out_name = 'adhoc.' . $token;
        }
        $out_row{"$out_name"} = $row->{$_};
    }
    return \%out_row;
}

sub set_attributes {
    my $prop_name = shift;
    return undef unless defined( $PropertyAttributes{$prop_name} );
    return $PropertyAttributes{$prop_name};
}

sub _prop_index {
   my $qname = shift;
   my $i = 0;
   for ($i = 0; $i < scalar ( @AllProps ); $i++ ) {
       return $i if $AllProps[$i] eq $qname;
   }
}

sub tables_and_columns {
    my ($self, $hashref) = @_;
    my %seen_tables = ();
    my %columns = ();
    foreach my $key ( keys %{$hashref} ) {
        my ($table, $column) = @{$self->resolve_resource( $key )};
        my ( $r_type, $prop_name ) = split /\./, $column;
        $columns{$prop_name} = $hashref->{$key};
        $seen_tables{$table} = 1 unless defined $seen_tables{$table};
    }
    my @tables = keys( %seen_tables );
    return ( \@tables, \%columns );
}

sub tables_and_columns_get {
    my ($self, $hashref) = @_;
    my %seen_tables = ();
    my %columns = ();
    foreach my $key ( keys %{$hashref} ) {
        my ($table, $column) = @{$self->resolve_resource( $key )};
        my $idx = _prop_index( $key );
        my $fake_key = 'a__' . $idx;
        my $col_string = "$column AS $fake_key";
        $columns{$col_string} = $hashref->{$key};
        $seen_tables{$table} = 1 unless defined $seen_tables{$table};
    }
    my @tables = map { "$_ $_" } ( keys( %seen_tables ));
    return ( \@tables, \%columns );
}

sub crit {
    my ($self, $conds) = @_;
    my %out = ();
    my @outie = ();
    foreach my $key ( keys( %{$conds} )) {
        #warn "in Crit $key = " . $conds->{$key} . "\n";
        if ( $key =~ /adhoc/ ) {
            push @outie, DBIx::SQLEngine::Criteria->auto( $conds->{$key} );
        }
        else {
            my ($table, $column) = @{$self->resolve_resource( $key )};
            my ( $r_type, $prop_name ) = split /\./, $column;
            push @outie, DBIx::SQLEngine::Criteria->auto( { $prop_name => $conds->{$key} } );
        }
    }

    my $cond_object = DBIx::SQLEngine::Criteria::And->new( @outie );
    return $cond_object;
}

sub crit_get {
    my ($self, $conds) = @_;
    my %out = ();
    my @outie = ();
    foreach my $key ( keys( %{$conds} )) {
        #warn "in Crit $key = " . Dumper($conds->{$key}) . "\n";
        if ( $key =~ /adhoc/ ) {
            push @outie, DBIx::SQLEngine::Criteria->auto( $conds->{$key} );
        }
        else {
            my ($table, $column) = @{$self->resolve_resource( $key )};
            $out{"$column"} = $conds->{$key};
            push @outie, DBIx::SQLEngine::Criteria->auto( { $column => $conds->{$key} } );
        }
    }

    my $cond_object = DBIx::SQLEngine::Criteria::And->new( @outie );
    return $cond_object;
}

sub property_relationships {
    # make sure the conditions include any object or method specific joins
    # that the app classes will be ignorant of.
    my $self = shift;
    my ($r_type, $method_type ) = @_;

    if ( defined ($PropertyRelations{$r_type}) ) {
        return $PropertyRelations{$r_type};
    }
    return undef;
}


##################################################################################
# Binary File Support
##################################################################################
# Despite the overall goodness of the DBI/DBD/DBIx modules, some rdbmses
# handle inserting binary data specially, and in a way that breaks the
# otherwise clean and tidy "it just works" syntax normalization (/me glares at Oracle).
#
# To avoid the possible overkill of having special helper classes just to deal
# with *one* column in *one* table in XIMS, we will resort to RDBMS-specific branching
# in the following methods. If these start to get too messy as support for new DBs
# are added, we should reconsider using helper classes instead.
##################################################################################

sub update_content_binfile {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $content_id, $data ) = @_;

    my $sth = $self->{dbh}->get_dbh->prepare("UPDATE ci_content set binfile = ? where id = ?");

    if ( $self->{RDBMSClass} eq 'Oracle' ) {
        $sth->bind_param( 1, $data, { ora_type => 113 } );
    }
    elsif ( $self->{RDBMSClass} eq 'Pg' ) {
        $sth->bind_param( 1, $data, { pg_type => 17 } );
    }
    # other special binds in 'elsif's here as needed
    # the following is the default
    else {
        $sth->bind_param( 1, $data );
    }

    # bind the id (should be the same for all)
    $sth->bind_param( 2, $content_id );

    return $sth->execute;
}

sub update_content_body {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $content_id, $data ) = @_;

    # Oracle needs a special bind to update CLOBs
    return $self->{dbh}->do_sql("UPDATE ci_content set body = ? where id = ?",
      [$data, ($self->{RDBMSClass} eq 'Oracle') ? {ora_type=>112} : ()],
      $content_id
    );
}

sub dbh { $_[0]->{dbh} }

#############################################################
# One-offs
#
# These are the DP methods that do not easliy fit into the
# cleaner abstraction model for one reason or another or
# need to be revisited.
#############################################################

sub reposition {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return undef unless (defined $args{document_id}
                         and defined $args{parent_id}
                         and defined $args{new_position}
                         and defined $args{position});

    my $document_id  = delete $args{document_id};
    my $parent_id    = delete $args{parent_id};
    my $old_position = delete $args{position};
    my $new_position = delete $args{new_position};

    my $position_diff = $old_position - $new_position;

    my ( $udop, $upperop, $lowerop );
    if ( $position_diff > 0 ) {
        $udop    = "+";
        $upperop = "<";
        $lowerop = ">=";
    }
    else {
        $udop    = "-";
        $upperop = ">";
        $lowerop = "<=";
    }

    # hmmmm, did not find a cleaner way to do that with SQLEngine :-/
    my $data = $self->{dbh}->do_update( sql => [ qq{UPDATE ci_documents
                                                    SET
                                                      position = position $udop 1
                                                    WHERE
                                                      position $upperop ?
                                                      AND position $lowerop ?
                                                      AND parent_id = ?
                                                    }
                                                  , $old_position
                                                  , $new_position
                                                  , $parent_id
                                               ]
                                       );
    #warn "Repositioning Siblings. Driver returned: " . Dumper( $data ) . "\n";

    $data = $self->{dbh}->do_update( table    => 'ci_documents',
                                     values   => { 'position' => $new_position },
                                     criteria => { id => $document_id } );
    #warn "Repositioning Object. Driver returned: " . Dumper( $data ) . "\n";

    return $data;
}

sub max_position {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return undef unless exists $args{parent_id};

    my $query = 'SELECT max(position) AS position FROM ci_documents WHERE parent_id = ?';
    my $data = $self->{dbh}->fetch_select( sql => [ $query, $args{parent_id} ] );

    return $data->[0]->{'position'};
}

sub close_position_gap {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return undef unless (defined $args{parent_id}
                         and defined $args{position});

    return $self->{dbh}->do_update( sql => [ qq{UPDATE ci_documents
                                                  SET
                                                    position = position - 1
                                                  WHERE
                                                    position > ?
                                                    AND parent_id = ?}
                                                , $args{position}
                                                , $args{parent_id}
                                           ]
                                  );
}

sub db_now {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $query = 'select now()';
    $query .= ' from dual' if $self->{RDBMSClass} eq 'Oracle';
    my $data = $self->{dbh}->fetch_select( sql => $query );

    return defined ( $data->[0]->{'now'} ) ? $data->[0]->{'now'} : $data->[0]->{'now()'};
}

sub get_object_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @ids;
    my %param;
    $param{limit} = delete $args{limit};
    $param{offset} = delete $args{offset};
    $param{order} = delete $args{order};

    my $criteria = \%args;
    $criteria->{'ci_content.document_id'} = \'ci_documents.id';

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents, ci_content',
                                           columns =>  'ci_documents.id',
                                           criteria => $criteria,
                                           %param);
    foreach my $row ( @{$data} ) {
        push @ids, $row->{id};
    }
    return \@ids;
}

sub find_object_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    return unless (defined $args{criteria} and length $args{criteria});

    my $tables = 'ci_content';
    my $columns = delete $args{columns};
    $columns ||= 'DISTINCT ci_content.ID, last_modification_timestamp as ts';

    my %param;
    unless ( delete $args{noorder} ) {
        $param{order} = delete $args{order};
        $param{order} ||= 'ci_content.last_modification_timestamp DESC';
    }

    # hack alarm - fix this in Intermedia.pm (after refactoring QueryBuilder) and CGI.pm event_search!!!
    $columns .= ', score(1) as s' if ($param{order} and $param{order} eq 'score(1) DESC');

    $param{criteria} = delete $args{criteria};
    if ( exists $args{start_here} or $param{criteria} =~ /ci_documents|location_path|object_type_id|data_format_id/i ) {
        $tables .= ',ci_documents ';
        $param{criteria} = ' ci_documents.id=ci_content.document_id AND ' . $param{criteria};
    }

    $param{limit} = delete $args{limit};
    $param{offset} = delete $args{offset};

    # since we want to use limit and offset here, we have to include the basic
    # privilege check here, and not higher up in the chain
    my $user_id = delete $args{user_id};
    my $role_ids = delete $args{role_ids};
    my @critparams;
    if ( $user_id and scalar @{$role_ids} > 0 ) {
        my @user_ids =( $user_id, @{$role_ids} );
        @critparams = @user_ids;

        $param{criteria} .= " AND ci_content.id = ci_object_privs_granted.content_id AND ci_object_privs_granted.grantee_id IN (" . join(',', map { '?' } @user_ids) . ") AND ci_object_privs_granted.privilege_mask > 0";

        $tables .= ', ci_object_privs_granted';
        # tell the Oracle optimizer to use the fk index - this speeds up the query by about 100%!
        $columns = '/*+ INDEX (ci_object_privs_granted opg_usr_grantee_fk_i) */ ' . $columns if $self->{RDBMSClass} eq 'Oracle';
    }

    my $start_here = delete $args{start_here};
    if ( defined $start_here and ref $start_here and $start_here->id() ) {
        $param{criteria} .= " AND location_path LIKE '". $start_here->location_path() . "%'";
    }

    if ( scalar keys %args > 0 ) {
        my ( $sql, @params ) = $self->_sqlwhere_from_hashgroup( %args );
        $param{criteria} = [ $param{criteria} . ' AND ' . $sql, @critparams, @params ];
    }
    else {
        $param{criteria} = [ $param{criteria}, @critparams ];
    }

    my $data = $self->{dbh}->fetch_select( table   => $tables,
                                           columns => $columns,
                                           %param );

    my @ids;
    my %seen = ();
    foreach my $row ( @{$data} ) {
        # remove duplicates resulting from different role grants
        push (@ids, $row->{id}) unless $seen{$row->{id}}++;
    }
    return \@ids;
}

sub find_object_id_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    $args{columns} = 'count(DISTINCT ci_content.id) AS id';

    my $ids = $self->find_object_id( %args, noorder => 1 );
    return $ids->[0] if $ids;
}

sub content_length {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_content_loblength',
                                           columns =>  'lob_length',
                                           criteria => { id => $args{id} } );

    return undef unless ref( $data ) and scalar( @{$data} > 0);
    return $data->[0]->{lob_length};
}

sub get_descendant_id_level {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return undef unless exists $args{parent_id};

    my $maxlevel = $args{maxlevel};
    $maxlevel ||= 0;

    my $query = $self->_get_descendant_sql( $args{parent_id}, $maxlevel, 1 );
    return undef unless $query;

    #warn "query: $query";
    my $data = $self->{dbh}->fetch_select( sql => $query );

    my @ids;
    my @lvls;
    foreach my $row ( @{$data} ) {
        push @ids, $row->{id};
        push @lvls, $row->{lvl};
    }

    return [[ \@ids, \@lvls ]];
}


##
#
# SYNOPSIS
#    $dp->get_descendant_infos( %param );
#
# PARAMETER
#    $param{parent_id}
#
# RETURNS
#    \@rv : [ number of descendants, the newest modification timestamp found ]
#
# DESCRIPTION
#    takes a document_id as argument; returns the count of its descendants and
#    the newest last_modification_timestamp of all descendants and the object
#    itself.
#
sub get_descendant_infos {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    return undef unless exists $args{parent_id};

    my $desc_subquery = $self->_get_descendant_sql( $args{parent_id}, undef, undef, 1 );
    my $desc_subquery_sql = shift @{$desc_subquery};
    my $query = [ 'SELECT count(last_modification_timestamp) AS count, max(last_modification_timestamp) AS max FROM ci_content WHERE document_id IN ( ' . $desc_subquery_sql . ')', @{$desc_subquery} ];
    my $data = $self->{dbh}->fetch_select( sql => $query );
    my @rv = ( @{$data}[0]->{count}, @{$data}[0]->{max} ); # NOTE: assumes that there is one content_child per document;
                                                           #       may have to be changed in future!
    return \@rv ;
}

sub location_path {
    my $self = shift;
    my $obj;

    if ( scalar( @_ ) == 1 and ref( $_[0] ) ) {
        $obj = shift;
    }
    else {
        $obj = XIMS::Object->new( @_ );
        return undef unless $obj and $obj->id;
    }

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents',
                                           columns =>  'location_path',
                                           criteria => { id => $obj->document_id() } );

    return undef unless ref( $data ) and scalar( @{$data} > 0);
    return $data->[0]->{location_path};
}

sub location_path_relative {
    my $self = shift;
    my $relative_path = $self->location_path( @_ );
    # snip off the site portion of the path ('/site/somepath')
    $relative_path =~ s/^\/[^\/]+//;
    return $relative_path;
}

# mini request factory to allow compatibility of 'property => value' conditions
# currently used by find_object_ids and find_object_id_count
sub _sqlwhere_from_hashgroup {
    my $self = shift;
    my %args = @_;

    my %conditions;
    foreach my $k ( keys %args ) {
        $conditions{XIMS::Names::get_URI( 'Object', $k )} = $args{$k};
    }
    my $crit = $self->crit_get( \%conditions );

    return $crit->sql_where();
}

##
#
# SYNOPSIS
#    $dp->_get_descendant_sql( $parent_id[, $maxlevel, $getlevel, $noorder] );
#
# PARAMETER
#    $parent_id            :  document_id of the parent object to descend from
#    $maxlevel  (optional) :  maxlevel of recursion, if unspecified or 0 means no recursion limit
#    $getlevel  (optional) :  per default, only document_id is returned, if $getlevel is specified,
#                             the level property will be included in the query
#    $noorder   (optional) :  if given, siblings are not ordered by position
#
# RETURNS
#    $query : Reference to an Array, including the hierarchical SQL query with ci_documents.id, or
#             level and ci_documents.id at index '0' and bind params at the following indices
#
# DESCRIPTION
#    Helper method for get_descendant_id_level() and get_descendant_infos()
#    Returns reference to an array which may be passed to $dbh->fetch_select( sql => $query ) for example
#
sub _get_descendant_sql {
    my $self = shift;
    my $parent_id = shift;
    my $maxlevel = shift;
    my $getlevel = shift;
    my $noorder = shift;

    my $levelproperty;
    my $orderby;
    if ( $self->{RDBMSClass} eq 'Pg' ) {
        $maxlevel ||= 0;
        $orderby = "ORDER BY t.pos" unless defined $noorder;
        $levelproperty = 't.lvl,' if defined $getlevel;
        #
        # PostgreSQL 7.3.x contrib-tablefunction connectby() does not support ordering of siblings :-|...
        #
        if ( DBD::Pg::_pg_server_version( $self->dbh ) =~ '7.3' ) {
            return ["SELECT $levelproperty t.id AS id FROM connectby('ci_documents', 'id', 'parent_id', ?, ?) AS t(id int, parent_id int, lvl int) WHERE t.id <> t.parent_id", [$parent_id, 12], $maxlevel]; # 12 => bind as 'Text'
        }
        else {
            return ["SELECT $levelproperty t.id AS id FROM connectby('ci_documents', 'id', 'parent_id', 'position', ?, ?) AS t(id int, parent_id int, lvl int, pos int) WHERE t.id <> t.parent_id $orderby", [$parent_id, 12], [$maxlevel, 4]]; # 12 => bind as 'Text', 4 => bind as 'Integer'
        }
    }
    elsif ( $self->{RDBMSClass} eq 'Oracle' ) {
        my @binds = ( $parent_id );
        $levelproperty = 'level-1 lvl,' if defined $getlevel;
        my $levelcond = '';
        if ( defined $maxlevel and $maxlevel > 0 ) {
            $levelcond = "AND level <= ?";
            push( @binds, $maxlevel + 1 );
        }
        $orderby = "ORDER SIBLINGS BY position" unless defined $noorder;
        return ["SELECT $levelproperty id FROM ci_documents WHERE id <> ? $levelcond START WITH id = ? CONNECT BY PRIOR id = parent_id $orderby", @binds, $parent_id];
    }
    else {
        XIMS::Debug( 1, "Unsupported RDBMSClass!" );
        return undef;
    }
}


##
#
# SYNOPSIS
#    $dp->get_object_id_by_path( %param );
#
# PARAMETER
#    $param{path}
#
# RETURNS
#    $retval: document_id on success, undef otherwise
#
# DESCRIPTION
#    Fetches document_id corresponding to $param{path} using an recursing algorithm.
#
sub get_object_id_by_path {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %param = @_;
    my $retval = undef; # return value

    if ( exists $param{path} and length $param{path} ) {
        return 1 if $param{path} eq '/root' or $param{path} eq '/'; # special case for 'root' since it does not have got a parent_id
        my @path = split("/", $param{path});
        my $count = scalar( @path );
        my $id = 1; # start with objects in the first level of the hierarchy
        my $symid;

        if ( not length $path[0] ) {
            shift @path; # remove the root
        }

        # this is rather inefficient, but there seems to be no better way
        foreach my $location ( @path ) {
            my @ids = ();
            map { defined $_ and push(@ids, $_) } ( $id, $symid );
            my $sqlstr = "SELECT d.id,symname_to_doc_id
                          FROM ci_documents d, ci_content c
                          WHERE c.document_id=d.id
                          AND c.marked_deleted IS NULL
                          AND location = ?
                          AND parent_id IN (" .  join(',', map { '?' } @ids ) . ") ";

            my $row;
            if ( $row = $self->{dbh}->fetch_select_rows(
                                                    sql => [ $sqlstr,
                                                             $location,
                                                             @ids
                                                           ]
                                                       )
                  and $row->[0]->[0] ) {
                $id = $row->[0]->[0];
                $symid = $row->[0]->[1];
                XIMS::Debug( 6, "new id: '$id' (symid '" . defined $symid ? $symid : '' . "')" );
            }
            else {
                XIMS::Debug( 3, "empty result set, 404" );
                return undef;
            }
        }
        $retval = $id;
        XIMS::Debug( 6, "retval is '$retval'" );
    }
    else {
        XIMS::Debug( 2, "need path to fetch the document_id by path" );
    }

    return $retval;
}

sub new {
    XIMS::Debug( 5, "called" );
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;
    my $self = {};

    # XIMS::Debug( 6, "parameters: @_" );

    if ( exists $args{dbdsn}  and exists $args{dbuser} and exists $args{dbpasswd} ) {
        XIMS::Debug( 4, "establishing database connection");
        my $dbh;

        eval {
            $dbh = DBIx::SQLEngine->new( $args{dbdsn},  $args{dbuser}, $args{dbpasswd} );
        };

        if ( $@ ) {
            XIMS::Debug( 1, "could not connect to database" );
            XIMS::Debug( 1, $@ );
            return;
        }
        else {

            # for use later w/ the binary helpers
            if ( $args{dbdsn} =~ /^dbi:(.+?):/ ) {
                $self->{RDBMSClass} = $1;
            }

            foreach ( split (";", $args{dbdopt}) ) {
                $_ =~ /(.+)=(.+)/;
                $dbh->get_dbh->{$1} = "$2";
            }
            $dbh->get_dbh->{FetchHashKeyName} = 'NAME_lc';

            foreach ( split (";", $args{dbsessionopt}) ) {
                $dbh->do("$_");
            }

            XIMS::DEBUGLEVEL() == 6 ? $dbh->SQLLogging( 1 ) : $dbh->SQLLogging( 0 );

            $self->{dbh} = $dbh;
        }
    }
    else {
        XIMS::Debug( 2, "wrong parameters!" );
    }

    return bless $self, $class;
}

sub DESTROY {
    my $self = shift;
    $self->{dbh}->disconnect() if defined $self->{dbh};
}

1;

