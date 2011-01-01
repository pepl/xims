=head1 NAME

XIMS::DataProvider::DBI -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::DataProvider::DBI;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::DataProvider::DBI;

use strict;
use XIMS;
use XIMS::Names;
use DBIx::SQLEngine 0.017;
use DBIx::SQLEngine::Criteria::And;
use XIMS::DataProvider;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our %PropertyAttributes = XIMS::Config::DataProvider::DBI::PropertyAttributes();
our %PropertyRelations = XIMS::Config::DataProvider::DBI::PropertyRelations();
our %Tables = XIMS::Config::DataProvider::DBI::Tables();
our %Names =  reverse ( %Tables );

# build forward and reverse property indices
my %PropIndex;
my %PropIndexByName;
my $i = 0;
foreach my $values (values %XIMS::Names::Properties) {
    foreach my $property ( @{$values} ) {
        $PropIndexByName{$property} = $i;
        $PropIndex{$i} = $property;
        $i++;
    }
}

=head2 resolve_resource()

=cut

sub resolve_resource {
    # here is where we resolve the uri-id to the tables and fields
    # in the database.
    # we can autogen here, all drivers might not be able to
    my $self = shift;
    my $resource_id = shift;
    my ($r_type, $property_name) = split /\./, $resource_id; #/
    my $table_name = $Tables{$r_type};
    return [ $table_name, $table_name . '.' . $property_name ];
}


=head2 Core Methods

 These are the low-level methods for getting data into and out of the
 the DB.

=cut

=head2 get()

=cut

sub get {
    my ($self, %args) = @_;
    my $properties = delete $args{properties};
    my $conditions = delete $args{conditions};
    my @qualified_names = keys( %{$properties} );
    my ($tables, $columns) = $self->tables_and_columns_get( $properties );
    my $crit = $self->crit_get( $conditions );
    my @columns = keys( %{$columns} );
    my $data = $self->{dbh}->fetch_select( tables   => $tables,
                                           columns  => \@columns,
                                           criteria => $crit,
                                           %args);

    my @out = map { name_fixer( $_ ) } @{$data};
    #warn "Driver returned: " . Dumper( \@out ) . "\n";
    return  \@out;
}

=head2 create()

=cut

sub create {
    my ($self, %args) = @_;
    #warn "create called " . Dumper( $args{properties} ) . "\n";
    my $insert_id;
    foreach my $property ( keys( %{$args{properties}} ) ) {
        if ( exists $PropertyAttributes{$property} ) {
            $insert_id = $self->function_val( ${$PropertyAttributes{$property}} );
            if ( not defined $insert_id ) {
                XIMS::Debug( 2, "Could not retrieve current value for primary key from sequence function" );
                return;
            }
            $args{properties}->{$property} = $insert_id;
        }
    }
    my ($table, $column_map) = $self->tables_and_columns( $args{properties} );
    #warn "and after " . Dumper( $column_map ) . "\n";

    my $test = $self->{dbh}->do_insert( table    => $table->[0],
                                        values   => $column_map );

    if ( $test ) {
        # to make things friendlier for the object and app classes,
        # we'll select back the auto-generated id of the data we
        # of the data we just inserted if the have been inserting
        # into a table with an auto-generated id

        if ( defined $insert_id ) {
            return $insert_id;
        }
        else {
            return $test;
        }
    }
    else {
        return;
    }
}

=head2 delete()

=cut

sub delete {
    my ($self, %args) = @_;
    my ($table, $columns) = $self->tables_and_columns( $args{properties} );

    my $crit = $self->crit( $args{conditions} );
    return $self->{dbh}->do_delete( table     => $table->[0],
                                    criteria  => $crit );
}

=head2 update()

=cut

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


=head2 Helper Methods

 These are helper subs for munging SQL queries and returned data

=cut

=head2 name_fixer()

=cut

sub name_fixer {
    my $row = shift;
    my %out_row = ();
    foreach ( keys( %{$row} ) ) {
        my $out_name;
        my ($token, $idx) =  split(/__/, $_);
        if ( defined( $idx ) and length( $idx ) ) {
            $out_name = $PropIndex{$idx};
        }
        else {
            $out_name = 'adhoc.' . $token;
        }
        $out_row{"$out_name"} = $row->{$_};
    }
    return \%out_row;
}

=head2 tables_and_columns()

=cut

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

=head2 tables_and_columns_get()

=cut

sub tables_and_columns_get {
    my ($self, $hashref) = @_;
    my %seen_tables = ();
    my %columns = ();
    foreach my $key ( keys %{$hashref} ) {
        my ($table, $column) = @{$self->resolve_resource( $key )};
        my $idx = $PropIndexByName{$key};
        my $fake_key = 'a__' . $idx;
        my $col_string = "$column AS $fake_key";
        $columns{$col_string} = $hashref->{$key};
        $seen_tables{$table} = 1 unless defined $seen_tables{$table};
    }
    my @tables = map { "$_ $_" } ( keys( %seen_tables ));
    return ( \@tables, \%columns );
}

=head2 crit()

=cut

sub crit {
    my ($self, $conds) = @_;
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

=head2 crit_get()

=cut

sub crit_get {
    my ($self, $conds) = @_;
    my @outie = ();
    foreach my $key ( keys( %{$conds} )) {
        #warn "in Crit $key = " . Dumper($conds->{$key}) . "\n";
        if ( $key =~ /adhoc/ ) {
            push @outie, DBIx::SQLEngine::Criteria->auto( $conds->{$key} );
        }
        else {
            my ($table, $column) = @{$self->resolve_resource( $key )};
            push @outie, DBIx::SQLEngine::Criteria->auto( { $column => $conds->{$key} } );
        }
    }

    my $cond_object = DBIx::SQLEngine::Criteria::And->new( @outie );
    return $cond_object;
}

=head2 property_relationships()

=cut

sub property_relationships {
    # make sure the conditions include any object or method specific joins
    # that the app classes will be ignorant of.
    my $self = shift;
    my ($r_type, $method_type ) = @_;

    if ( defined ($PropertyRelations{$r_type}) ) {
        return $PropertyRelations{$r_type};
    }
    return;
}



=head2 Binary File Support

Despite the overall goodness of the DBI/DBD/DBIx modules, some rdbmses handle
inserting binary data specially, and in a way that breaks the otherwise clean
and tidy "it just works" syntax normalization (/me glares at Oracle).

To avoid the possible overkill of having special helper classes just to deal
with *one* column in *one* table in XIMS, we will resort to RDBMS-specific
branching in the following methods. If these start to get too messy as support
for new DBs are added, we should reconsider using helper classes instead.

=cut

=head2 update_content_binfile()

=cut

sub update_content_binfile {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $content_id, $data ) = @_;

    my $content_length;
    do { use bytes; $content_length = length( $data ) };

    my $sth = $self->{dbh}->get_dbh->prepare("UPDATE ci_content set binfile = ?, content_length = ? where id = ?");

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

    $sth->bind_param( 2, $content_length );
    $sth->bind_param( 3, $content_id );

    return $sth->execute;
}

=head2 update_content_body()

=cut

sub update_content_body {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $content_id, $data ) = @_;

    # Oracle needs a special bind to update CLOBs
    # Passing the content_length here save the trigger work which is costly
    # for Oracle CLOBs
    my $content_length;
    do { use bytes; $content_length = length( $data ) };

    return $self->{dbh}->do_sql("UPDATE ci_content set body = ?, content_length = ? where id = ?",
      [$data, ($self->{RDBMSClass} eq 'Oracle') ? {ora_type=>112} : ()],
      $content_length,
      $content_id
    );
}

=head2 dbh()

=cut

sub dbh { $_[0]->{dbh} }


=head2 One-offs

 These are the DP methods that do not easliy fit into the
 cleaner abstraction model for one reason or another or
 need to be revisited.

=cut

=head2 reposition()

=cut

sub reposition {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return unless (defined $args{document_id}
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

=head2 max_position()

=cut

sub max_position {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return unless exists $args{parent_id};

    my $query = 'SELECT max(position) AS position FROM ci_documents WHERE parent_id = ?';
    my $data = $self->{dbh}->fetch_select( sql => [ $query, $args{parent_id} ] );

    return $data->[0]->{'position'};
}

=head2 close_position_gap()

=cut

sub close_position_gap {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return unless (defined $args{parent_id}
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

=head2 update_descendant_department_id()

=cut

sub update_descendant_department_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return unless (defined $args{parent_location_path}
                         and defined $args{old_department_id}
                         and defined $args{new_department_id});

    return $self->{dbh}->do_update( table    => 'ci_documents',
                                    values   => { 'department_id' => $args{new_department_id} },
                                    criteria => { 'department_id' => $args{old_department_id},
                                                  'location_path' => $args{parent_location_path} . '/%' } );
}

=head2 function_val()

=cut

sub function_val {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $function = shift;
    my $query;
    if ( $self->{RDBMSClass} eq 'Oracle' ) {
        $query = "select $function as val from dual";
    }
    else {
        $query = "select $function as val";
    }
    my $data = $self->{dbh}->fetch_select( sql => $query );
    return $data->[0]->{'val'};
}

=head2 db_now()

=cut

sub db_now {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $query;
    if ( $self->{RDBMSClass} eq 'Oracle' ) {
        $query = 'select now() as now from dual';
    }
    else {
        # PostgreSQL's now() returns a timestamp with timezone. We want one
        # without timezone and with a precision to seconds
        $query = 'select LOCALTIMESTAMP(0) as now';
    }
    my $data = $self->{dbh}->fetch_select( sql => $query );

    return $data->[0]->{'now'};
}

=head2 get_object_id()

=cut

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
    $criteria->{'ci_content.document_id'} = \'ci_documents.id'; #'

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents, ci_content',
                                           columns =>  'ci_documents.id',
                                           criteria => $criteria,
                                           %param);
    foreach my $row ( @{$data} ) {
        push @ids, $row->{id};
    }
    return \@ids;
}

=head2 find_object_id()

=cut

sub find_object_id {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    if ( not defined $args{criteria} or
         defined $args{criteria} and not ref($args{criteria}) and not length $args{criteria} ) {
        return;
    }

    my $tables = 'ci_content';
    my $columns = delete $args{columns};
    # The DISTINCT here will disable the index scan for Pg :-/
    # Did not find an easy way to fix this yet
    $columns ||= 'DISTINCT ci_content.ID, last_modification_timestamp as ts';

    my %param;
    unless ( delete $args{noorder} ) {
        $param{order} = delete $args{order};
        $param{order} ||= 'ci_content.last_modification_timestamp DESC';
    }

    # hack alarm - fix this in Intermedia.pm (after refactoring QueryBuilder) and CGI.pm event_search!!!
    $columns .= ', score(1) as s' if ($param{order} and $param{order} eq 'score(1) DESC');

    my $critstring;
    my @critvals;
    my $criteria = delete $args{criteria};
    # Allow both a literal string and a array ref [ $string, @vals ] to be passed
    if ( not ref $criteria and length $criteria ) {
        $critstring = $criteria;
    }
    elsif ( ref $criteria eq 'ARRAY' ) {
        ( $critstring, @critvals ) = @{$criteria};
    }
    else {
        XIMS::Debug( 2, "Illegal parameters passed" );
        return;
    }

    if ( exists $args{start_here} or $critstring =~ /ci_documents|location_path|object_type_id|data_format_id/i ) {
        $tables .= ',ci_documents ';
        $critstring = ' ci_documents.id=ci_content.document_id AND ' . $critstring;
    }

    $param{limit} = delete $args{limit};
    $param{offset} = delete $args{offset};

    # since we want to use limit and offset here, we have to include the basic
    # privilege check here, and not higher up in the chain
    my $user_id = delete $args{user_id};
    my $role_ids = delete $args{role_ids};
    if ( $user_id and scalar @{$role_ids} > 0 ) {
        my @user_ids =( $user_id, @{$role_ids} );
        $critstring .= " AND ci_content.id = ci_object_privs_granted.content_id AND ci_object_privs_granted.grantee_id IN (" . join(',', map { '?' } @user_ids) . ") AND ci_object_privs_granted.privilege_mask > 0";
        push( @critvals, @user_ids );

        $tables .= ', ci_object_privs_granted';
        # tell the Oracle optimizer to use the fk index - this speeds up the query by about 100%!
        $columns = '/*+ INDEX (ci_object_privs_granted opg_usr_grantee_fk_i) */ ' . $columns if $self->{RDBMSClass} eq 'Oracle';
    }

    my $start_here = delete $args{start_here};
    if ( defined $start_here ) {
        if ( ref $start_here and $start_here->isa('XIMS::Object') and defined $start_here->id() ) {
            $start_here = $start_here->location_path();
        }
        $critstring .= " AND location_path LIKE ?";
        push( @critvals, "$start_here%" );
    }

    if ( scalar keys %args > 0 ) {
        my ( $sql, @params ) = $self->_sqlwhere_from_hashgroup( %args );
        $param{criteria} = [ $critstring . ' AND ' . $sql, @critvals, @params ];
    }
    else {
        $param{criteria} = [ $critstring, @critvals ];
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

=head2 find_object_id_count()

=cut

sub find_object_id_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    $args{columns} = 'count(DISTINCT ci_content.id) AS id';

    my $ids = $self->find_object_id( %args, noorder => 1 );
    return $ids->[0] if $ids;
}

=head2 get_descendant_id_level()

=cut

sub get_descendant_id_level {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my %param;

    return unless exists $args{parent_id};

    my $maxlevel = delete $args{maxlevel};
    $maxlevel ||= 0;
    my $parent_id = delete $args{parent_id};
    my $order = delete $args{order};
    $param{limit} = delete $args{limit};
    $param{offset} = delete $args{offset};
    $param{order} = $order; # pass into

    my $noorder;
    $noorder = 1 if (defined $order or scalar keys %args > 0);

    my $query = $self->_get_descendant_sql( $parent_id, $maxlevel, 1, $noorder );
    return unless $query;

    #warn "query: $query";
    my $data = $self->{dbh}->fetch_select( sql => $query, %param, criteria => \%args );

    my @ids;
    my @lvls;
    foreach my $row ( @{$data} ) {
        push @ids, $row->{id};
        push @lvls, $row->{lvl};
    }

    return [[ \@ids, \@lvls ]];
}




=head2    get_descendant_infos()

=head3 Parameter

    $param{parent_id}

=head3 Returns

    \@rv : [ number of descendants, the newest modification timestamp, latest
    publication timestamp found ]

=head3 Description

$dp->get_descendant_infos( %param );

Takes a document_id as argument; returns the count of its descendants and
the newest last_modification_timestamp and last_publication_timestamp of all
descendants and the object itself.

=cut

sub get_descendant_infos {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    return unless exists $args{parent_id};

    my $query = $self->_get_descendant_sql( $args{parent_id}, undef, undef, 1, 'count(last_modification_timestamp) AS count, max(last_modification_timestamp) AS max, max(last_publication_timestamp) AS pubmax' );
    my $data = $self->{dbh}->fetch_select( sql => $query );
    my @rv = ( @{$data}[0]->{count}, @{$data}[0]->{max}, @{$data}[0]->{pubmax} ); # NOTE: assumes that there is one content_child per document;
                                                           #       may have to be changed in future!
    return \@rv ;
}

=head2 location_path()

=cut

sub location_path {
    my $self = shift;
    my $document_id;

    if ( scalar( @_ ) == 1 and ref( $_[0] ) ) {
        my $obj = shift;
        $document_id = $obj->document_id();
        return '' if $document_id == 1; # root has no location_path
    }
    else {
        my %args = @_;
        return '' if ( defined $args{document_id} and $args{document_id} == 1 or defined $args{id} and $args{id} == 1);
        if ( defined $args{document_id} ) {
            $document_id = $args{document_id};
        }
        elsif ( defined $args{id} ) {
            my $data = $self->{dbh}->fetch_select( table => 'ci_content',
                                                   columns => 'document_id',
                                                   criteria => { id => $args{id} } );
            return unless ref( $data ) and scalar( @{$data} > 0);
            $document_id = $data->[0]->{document_id};
        }
        else {
            return;
        }
    }

    my $data = $self->{dbh}->fetch_select( table   =>  'ci_documents',
                                           columns =>  'location_path',
                                           criteria => { id => $document_id } );

    return unless ref( $data ) and scalar( @{$data} > 0);
    return $data->[0]->{location_path};
}

=head2 location_path_relative()

=cut

sub location_path_relative {
    my $self = shift;
    my $relative_path = $self->location_path( @_ );
    return '' unless $relative_path;
    # snip off the site portion of the path ('/site/somepath')
    $relative_path =~ s/^\/[^\/]+//;
    return $relative_path;
}

# mini request factory to allow compatibility of 'property => value' conditions
# currently used by find_object_ids and find_object_id_count

=head2 _sqlwhere_from_hashgroup()

=cut

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



=head2    _get_descendant_sql()

=head3 Parameter

    $parent_id             :  document_id of the parent object to descend from
    $maxlevel   (optional) :  maxlevel of recursion, if unspecified or 0 means
                              no recursion limit
    $getlevel   (optional) :  per default, only document_id is returned, if
                              $getlevel is specified, the level property will
                              be included in the query
    $noorder    (optional) :  if given, siblings are not ordered by position
    $properties (optional) :  if given, this string is used to specify which
                              properties are to be returned

=head3 Returns

    $query : Reference to an Array, including the hierarchical SQL query with
             ci_documents.id, or level and ci_documents.id at index '0' and
             bind params at the following indices

=head3 Description

$dp->_get_descendant_sql( $parent_id[, $maxlevel, $getlevel, $noorder] );

Helper method for get_descendant_id_level() and get_descendant_infos()
Returns reference to an array which may be passed to
$dbh->fetch_select( sql => $query ) for example

=cut

sub _get_descendant_sql {
    my $self = shift;
    my $parent_id = shift;
    my $maxlevel = shift;
    my $getlevel = shift;
    my $noorder = shift;
    my $properties = shift;

    my $levelproperty;
    my $orderby = '';
    if ( $self->{RDBMSClass} eq 'Pg' ) {
        $maxlevel ||= 0;
        $orderby = "ORDER BY t.position" unless defined $noorder;
        $levelproperty = 't.lvl,' if defined $getlevel;
        $properties ||= "$levelproperty t.id AS id";
        #
        # PostgreSQL 7.3.x contrib-tablefunction connectby() does not support ordering of siblings :-|...
        #
        my $server_version = $self->dbh->get_dbh->{pg_server_version}; # DBD::Pg >= 1.41
        if ( not defined $server_version ) {
            eval { $server_version = DBD::Pg::_pg_server_version( $self->dbh ); };
        }
        # DBD:Pg < 1.40 returns a dotted version, DBD::Pg == 1.40 returns the integer variant
        if ( defined $server_version and ($server_version =~ '703' or $server_version =~ /7\.3/) ) {
            return ["SELECT $properties FROM ci_content c, connectby('ci_documents', 'id', 'parent_id', ?, ?) AS t(id int, parent_id int, lvl int), ci_documents d  WHERE t.id <> t.parent_id AND c.document_id = t.id AND t.id = d.id", [$parent_id, 12], $maxlevel]; # 12 => bind as 'Text'
        }
        else {
            return ["SELECT $properties FROM ci_content c, connectby('ci_documents', 'id', 'parent_id', 'position', ?, ?) AS t(id int, parent_id int, lvl int, position int), ci_documents d WHERE t.id <> t.parent_id AND c.document_id = t.id AND t.id = d.id $orderby", [$parent_id, 12], [$maxlevel, 4]]; # 12 => bind as 'Text', 4 => bind as 'Integer'
        }
    }
    elsif ( $self->{RDBMSClass} eq 'Oracle' ) {
        my @binds = ( $parent_id );
        $levelproperty = 'l-1 AS lvl,' if defined $getlevel;
        $properties ||= "$levelproperty d.id AS id";
        my $levelcond = '';
        if ( defined $maxlevel and $maxlevel > 0 ) {
            $levelcond = "AND level <= ?";
            push( @binds, $maxlevel + 1 );
        }
        $orderby = "ORDER SIBLINGS BY position" unless defined $noorder;
        return ["SELECT /*+ ALL_ROWS */ $properties FROM ci_content c, (SELECT level AS l, ci_documents.* FROM ci_documents START WITH id = ? CONNECT BY PRIOR id = parent_id $levelcond AND id != parent_id $orderby) d WHERE c.document_id = d.id AND l > 1", @binds];
    }
    else {
        XIMS::Debug( 1, "Unsupported RDBMSClass!" );
        return;
    }
}


=head2    get_object_id_by_path()

=head3 Parameter

    $param{path}

=head3 Returns

    $retval: document_id on success, undef otherwise

=head3 Description

$dp->get_object_id_by_path( %param );

Fetches document_id corresponding to $param{path}.

=cut

sub get_object_id_by_path {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %param = @_;
    my $retval; # return value

    #my $fallbacklangid = XIMS::Config::FallbackLangID();
    #my $requested_lang = $param{language_id};
    #$requested_lang ||= $fallbacklangid;

    # no trailing slashes there...
    $param{path} =~ s#/$##;

    if ( exists $param{path} ) {
        return 1 if $param{path} eq '/root' or $param{path} eq '/' or $param{path} eq ''; # special case for 'root' since it does not have got a parent_id
        # first, try a lookup via location_path

        #my $location_path_sqlstr = "SELECT c.id FROM ci_documents d, ci_content c WHERE c.document_id=d.id AND c.marked_deleted IS NULL AND d.location_path = ? AND c.language_id IN (?,$fallbacklangid) ORDER BY CASE WHEN language_id = ? THEN 1 END";
        #my $data = $self->{dbh}->fetch_select( sql => [ $location_path_sqlstr, $param{path}, $requested_lang, $requested_lang ], limit => 1 );
        my $location_path_sqlstr = "SELECT d.id FROM ci_documents d, ci_content c WHERE c.document_id=d.id AND c.marked_deleted = 0 AND location_path = ?";
        my $data = $self->{dbh}->fetch_select( sql => [ $location_path_sqlstr, $param{path} ] );
        my $docid = $data->[0]->{'id'};
        if ( defined $docid ) {
            $retval = $docid;
        }
        else {
            # either we have got a 404 or the path contains a symname
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
                #my $sqlstr = "SELECT c.id,symname_to_doc_id
                my $sqlstr = "SELECT d.id, d.symname_to_doc_id FROM ci_documents d, ci_content c
                              WHERE c.document_id=d.id
                              AND c.marked_deleted = 0
                              AND d.location = ?
                              AND d.parent_id IN (" .  join(',', map { '?' } @ids ) . ") ";
                              #. " AND c.language_id IN (?,$fallbacklangid) ORDER BY CASE WHEN c.language_id = ? THEN 1 END";

                my $row;
                if ( $row = $self->{dbh}->fetch_select_rows(
                                                        sql => [ $sqlstr,
                                                                 $location,
                                                                 #$requested_lang, $requested_lang,
                                                                 @ids,
                                                               ],
                                                        limit => 1
                                                           )
                      and $row->[0]->[0] ) {
                    $id = $row->[0]->[0];
                    $symid = $row->[0]->[1];
                    XIMS::Debug( 6, "new id: '$id' (symid '" . (defined $symid ? $symid : '') . "')" );
                }
                else {
                    XIMS::Debug( 3, "could not resolve path, got 404" );
                    return;
                }
            }
            $retval = $id;
        }
        XIMS::Debug( 6, "got id '$retval' from path '" . $param{path} . "'" );
    }
    else {
        XIMS::Debug( 2, "need path to fetch the document_id by path" );
        #XIMS::Debug( 2, "need path to fetch the id by path" );
    }

    return $retval;
}

=head2 new()

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;
    my $self = {};

    if ( exists $args{dbdsn} and exists $args{dbuser} and exists $args{dbpasswd} ) {
        #warn "new db connect";
        my $dbh;
        eval {
            $dbh = DBIx::SQLEngine->new( $args{dbdsn}, $args{dbuser}, $args{dbpasswd} );
        };

        if ( $@ ) {
            die( "could not connect to database: $@\n" );
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

            XIMS::Config::DebugLevel() == 6 ? $dbh->SQLLogging( 1 ) : $dbh->SQLLogging( 0 );

            $self->{dbh} = $dbh;
        }
    }
    else {
        die( "wrong parameters!" );
    }

    return bless $self, $class;
}

=head2 DESTROY()

=cut

sub DESTROY {
    my $self = shift;
    if ( defined $self->{dbh} ) {
        my $dbh = $self->{dbh}->get_dbh();
        $dbh->disconnect() if $dbh;
    }
}

1;


__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

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

