# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package XIMS::DataProvider::DBI;

use strict;
use XIMS;
use XIMS::Names;
use DBIx::SQLEngine 0.008;
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
    'questionnaireresult.id'              => \'ci_quest_results_id_seq_nval()'
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
            questionnaireresult => 'ci_questionnaire_results'
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
        #warn "we will return: ", $id_list->[-1]->{ID};
        return $id_list->[-1]->{ID};
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
    #warn "FIXER CALLED " . Dumper( @_ ) . "\n";
    my $row = shift;
    my %out_row = ();
    foreach ( keys( %{$row} ) ) {
        my $out_name;
        my ($token, $idx) =  split /__/, lc( $_ );
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

    my $ret = $sth->execute;
    #warn "update binary returning $ret";
    return $ret;
}

sub update_content_body {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $content_id, $data ) = @_;

    my $sth = $self->{dbh}->get_dbh->prepare("UPDATE ci_content set body = ? where id = ?");

    if ( $self->{RDBMSClass} eq 'Oracle' ) {
        $sth->bind_param( 1, $data, { ora_type => 112 } );
    }
    # other special binds in 'elsif's here as needed
    # the following is the default
    else {
        $sth->bind_param( 1, $data );
    }

    # bind the id (should be the same for all)
    $sth->bind_param( 2, $content_id );

    my $ret = $sth->execute;
    #warn "update character returning $ret";
    return $ret;
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
    my $data = $self->{dbh}->do_update( sql => qq{UPDATE ci_documents
                                                  SET
                                                    position = position $udop 1
                                                  WHERE
                                                    position $upperop $old_position
                                                    AND position $lowerop $new_position
                                                    AND parent_id = $parent_id
                                                  }
                                       );

    #warn "Repositioning Siblings. Driver returned: " . Dumper( $data ) . "\n";

    $data = $self->{dbh}->do_update( table    => 'ci_documents',
                                     values   => { 'position' => $new_position },
                                     criteria => "id = $document_id AND position = $old_position" );

    #warn "Repositioning Object. Driver returned: " . Dumper( $data ) . "\n";

    return $data;
}

sub max_position {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return undef unless exists $args{parent_id};

    my $query = 'SELECT max(position) AS position FROM ci_documents WHERE parent_id = ' . $args{parent_id};
    my $data = $self->{dbh}->fetch_select( sql => $query );

    return $data->[0]->{'POSITION'};
}

sub db_now {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $query = 'select now()';
    $query .= ' from dual' if $self->{RDBMSClass} eq 'Oracle';
    my $data = $self->{dbh}->fetch_select( sql => $query );

    return defined ( $data->[0]->{'NOW'} ) ? $data->[0]->{'NOW'} : $data->[0]->{'NOW()'};
}

sub get_object_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @ids;
    my $criteria = \%args;
    $criteria->{'ci_content.document_id'} = \'ci_documents.id';

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents, ci_content',
                                           columns =>  'ci_documents.id',
                                           criteria => $criteria );
    foreach my $row ( @{$data} ) {
        push @ids, $row->{ID};
    }
    return \@ids;
}
# '
# Unfortunately, Oracle needs that strange ROWNUM subquery mechanism to limit the number of rows returned.
# and with Oracle, conditions testing for ROWNUM values greater than a positive integer are always false!
# Therefore we cannot use the abstract model of $self->get_object_id() but have to build the SQL on our own :-/
sub find_object_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @ids;
    my $criteria = $args{criteria};
    $args{orderby} ||= 'ci_content.last_modification_timestamp DESC';

    my $query = "SELECT ci_documents.id FROM ci_documents, ci_content WHERE ci_content.document_id = ci_documents.id";
    $query .= " AND $criteria" if (defined $criteria and length $criteria);
    $query .= " ORDER BY " . $args{orderby} . " ";
    if ( exists $args{rowlimit} and $args{rowlimit} > 0 ) {
        $args{offset} ||= '0';
        if ( $self->{RDBMSClass} eq 'Oracle' ) {
            $query = "SELECT id FROM ( SELECT id, ROWNUM AS position FROM (" . $query . ")) WHERE position > " . $args{offset} . " AND position <= " . ( $args{offset} + $args{rowlimit} );

        }
        elsif ( $self->{RDBMSClass} eq 'Pg' ) {
            $query = $query . " LIMIT " . $args{rowlimit} . " OFFSET " . $args{offset};
        }
        # other special binds in 'elsif's here as needed
    }

    #warn "query: $query";
    my $data = $self->{dbh}->fetch_select( sql => $query );
    foreach my $row ( @{$data} ) {
        push @ids, $row->{ID};
    }
    return \@ids;
}

sub find_object_id_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $criteria = $args{criteria};
    return unless length $criteria;

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents, ci_content',
                                           columns =>  'count(ci_documents.id) AS COUNT',
                                           criteria => 'ci_content.document_id = ci_documents.id AND ' . $criteria );
    return $data->[0]->{COUNT};
}

sub content_length {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_content_loblength',
                                           columns =>  'lob_length',
                                           criteria => { id => $args{id} } );

    return undef unless ref( $data ) and scalar( @{$data} > 0);
    return $data->[0]->{LOB_LENGTH};
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
        push @ids, $row->{ID};
        push @lvls, $row->{LVL};
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
    my $query = 'SELECT count(last_modification_timestamp), max(last_modification_timestamp) FROM ci_content WHERE document_id IN ( ' . $desc_subquery . ')';
    my $data = $self->{dbh}->fetch_select( sql => $query );
    my @rv = ( @{$data}[0]->{COUNT}, @{$data}[0]->{MAX} ); # NOTE: assumes that there is one content_child per document;
                                                           #       may have to be changed in future!
    return  \@rv ;
}

##
#
# SYNOPSIS
#    $dp->_get_descendant_sql( $parent_id[, $maxlevel, $getlevel] );
#
# PARAMETER
#    $parent_id            :  document_id of the parent object to descend from
#    $maxlevel  (optional) :  maxlevel of recursion, if unspecified or 0 means no recursion limit
#    $getlevel  (optional) :  per default, only document_id is returned, if $getlevel is specified,
#                             the level property will be included in the query
#
# RETURNS
#    $query : Hierarchical SQL query including ci_documents.id or
#             level and ci_documents.id properties
#
# DESCRIPTION
#    Helper method for get_descendant_id_level() and get_descendant_infos()
#    Returns hierarchical SQL query string
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
        return "SELECT $levelproperty t.id AS id FROM connectby('ci_documents', 'id', 'parent_id', 'position', '". $parent_id . "', " . $maxlevel . ") AS t(id text, parent_id text, lvl int, pos int) WHERE t.id <> t.parent_id $orderby";
    }
    elsif ( $self->{RDBMSClass} eq 'Oracle' ) {
        $levelproperty = 'level-1 lvl,' if defined $getlevel;
        my $levelcond = '';
        $levelcond = "AND level <= " . ($maxlevel + 1) if defined $maxlevel and $maxlevel > 0;
        $orderby = "ORDER SIBLINGS BY position" unless defined $noorder;
        return "SELECT $levelproperty id FROM ci_documents WHERE id <> " . $parent_id . " $levelcond START WITH id = " . $parent_id . " CONNECT BY PRIOR id = parent_id $orderby";
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
#    $retval: majorid on success, undef otherwise
#
# DESCRIPTION
#    none yet NOTE: $param{path} FIXME!!!!!!!!!
#
sub get_object_id_by_path {
    XIMS::Debug( 5, "called" );

    my $self = shift;
    my %param = @_;

    my $retval = undef; # return value

    XIMS::Debug( 6, "parameters: " . @_ );

    my $dbh = $self->{dbh};
    if ( $dbh ) {
        if ( exists $param{path} and length $param{path} ) {
            my @path = split("/", $param{path});
            my $count = scalar( @path );
            my $id = 1; # start with objects in the first level of the hierarchy
            my $symid = $id;

            if ( not length $path[0] ) {
                shift @path; # remove the root
            }

            # this is rather inefficient, but there seems to be no better way
            foreach my $loc ( @path ) {
                my $sqlstr = "SELECT id,symname_to_doc_id FROM ci_documents".
                    " WHERE location = '" . $loc . "' AND parent_id IN ( ". join( ",", grep { defined $_ } ( $id, $symid )) ." )";
                XIMS::Debug( 6, "SQL: $sqlstr");
                if ( ($id, $symid) = $dbh->selectrow_array( $sqlstr ) ) {
                    XIMS::Debug( 6, "new id: $id ($symid)") if defined $id and defined $symid;
                }
                else {
                    XIMS::Debug( 3, "empty result set" );
                    last;
                }
            }
            $retval = $id;
            XIMS::Debug( 6, "retval is '$retval'" ) if defined $retval;
        }
        else {
            XIMS::Debug( 3, "need path to fetch the majorid by path" );
        }
    }
    else {
        XIMS::Debug( 1, "no database handler found" );
    }

    XIMS::Debug( 5, "done" );
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

