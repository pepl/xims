# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SQLReport;

use strict;
use vars qw( $VERSION @ISA $AGENTUSER $AGENTPASSWORD $TESTGRANTEDSCHEMAS);
use XIMS::CGI;
use Text::Iconv;
use DBIx::XHTML_Table;
use XML::Generator::DBI;
use XML::LibXML;
use XML::LibXSLT;
use XML::LibXML::SAX::Builder;
use XIMS::DataProvider;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

# Credentials in whichs context the SQLReport query will be executed.
# This user needs to have SELECT grants on the database objects refered to in the SQLReport query.
$AGENTUSER = '';
$AGENTPASSWORD = '';

# If defined, all refered database objects need to exists in a database schema and have to be
# referenced explicitly with the schema name (select foo from schemaname.tablename). In addition,
# the currently logged in user has to be granted a role corresponding to the schema to execute
# the SQLReport query. That role must be called 'XIMS:SQLReportSchema:Schemaname'.
$TESTGRANTEDSCHEMAS = 0;

# (de)register events here
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          )
        );
}


sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # check for an SQL query in the body, return if none is found
    my $sql = XIMS::xml_unescape( $ctxt->object->body() );
    return 0 unless (defined $sql and length $sql);

    # connect to database using agent user
    my $dbh = $self->_agentdbh( $ctxt );
    return 0 unless defined $dbh;

    if ( defined $TESTGRANTEDSCHEMAS ) {
        # check for granted schema privileges
        my ($tables) = ($sql =~ /FROM\s(.*?)($|\sWHERE\s)/i);
        return 0 unless $self->_test_granted_schemata( $ctxt, $tables );
    }

    # check, whether we should build search conditions and a search form
    # based on the 'skeys' attribute
    my @skeys = split( ',', $ctxt->object->attribute_by_key( 'skeys' ) );
    my $body = '';
    my $criteria;
    if ( scalar @skeys > 0 ) {
        $body = $self->div( {-align=>'center'},
                                        $self->h1( $ctxt->object->title ),
                                        $self->_build_form_from_skeys( @skeys ),
                                        );
        if ( $self->param('s') ) {
            $criteria = $self->_build_crits_from_skeys( @skeys );
        }
        else {
            $ctxt->object->body( $body );
            return 0;
        }
    }

    # prepare pagination

    # calculate offset
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 30;
    $offset = $offset * $rowlimit;

    # create query for the search result count

    # remove trailing semicolons
    $sql =~ s/\s*;\s*$//;

    # order by and group by clauses have to be removed not to clash
    # with the SQLEngine generated where clause
    my ($orderby) = ( $sql =~ /\s+order\s+by\s+(\w+(\s+\w+)?)\s*$/i );
    my ($groupby) = ( $sql =~ /\s+group\s+by\s+(\w+)/i );
    $sql =~ s/\s+group\s+by\s+\w+//i;
    $sql =~ s/\s+order\s+by\s+\w+(\s+\w+)?\s*$//i;

    my $countsql = $sql;
    my ($properties) = ($countsql =~ /^\s*SELECT\s(.*?)\sFROM/i);

    if ( $properties =~ /^\s*\*\s*$/ ) {
        XIMS::Debug( 2, "* in properties " . $@ );
        $self->sendError( $ctxt, "Please specify explict query properties, do not use '*'.");
        return 0;
    }

    my $countproperty = 'count(*) as count';
    if ( defined $groupby ) {
        $countproperty = "count(distinct $groupby) as count";
    }

    $countsql =~ s/\Q$properties\E/$countproperty/;

    my $data = $dbh->fetch_select( sql => $countsql, criteria => $criteria );
    my $count = @{$data}[0]->{count};

    if ( $count eq '0' or not defined $count ) {
        $ctxt->object->body( $body . $self->strong( "Query did not return any results" ) );
        return 0;
    }
    $ctxt->session->searchresultcount( $count );

    # add param 'navparam' for pagination links
    my $navparam;
    my %vars = $self->Vars();
    foreach my $key ( keys %vars ) {
        if ( $key eq 's' or $key =~ /sqlrep\./ ) {
            $navparam .= "$key=" . $vars{$key} . ";";
        }
    }
    $self->param( 'navparam', $navparam ) if defined $navparam and length $navparam;

    # create the actual query including pagination, ordering, and grouping
    my @params;
    ( $sql, @params ) = $dbh->sql_select( sql => $sql,
                      limit => $rowlimit,
                      offset => $offset,
                      criteria => $criteria,
                      order => $orderby,
                      group => $groupby
    );


    # check for style_id and if there is a parseable stylesheet to transform the body there
    if ( $ctxt->object->style_id() and not $self->param('plaintable') ) {
        my $stylesheet = XIMS::Object->new( id => $ctxt->object->style_id() );

        my $handler = XML::LibXML::SAX::Builder->new();
        my $generator = XML::Generator::DBI->new( dbh => $dbh->get_dbh(), Handler => $handler, LowerCase => 1 );
        my $raw = $generator->execute( $sql, \@params );
        my $transformed;

        my $parser = XML::LibXML->new();
        my $xslt   = XML::LibXSLT->new();
        my $xsl_dom;
        my $style;

        eval {
            $xsl_dom  = $parser->parse_string( $stylesheet->body() );
        };
        if ( $@ ) {
            XIMS::Debug( 2, "Invalid Stylesheet: " . $@ );
            $self->sendError( $ctxt, "Invalid Stylesheet: " . $@ );
            return 0;
        }

        eval {
            $style = $xslt->parse_stylesheet( $xsl_dom );
        };
        if( $@ ) {
            XIMS::Debug( 2, "Invalid Stylesheet: " . $@ );
            $self->sendError( $ctxt, "Invalid Stylesheet: " . $@ );
            return 0;
        }

        eval {
            $transformed = $style->transform( $raw );
        };
        if( $@ ) {
            XIMS::Debug( 2, "Could not transform using stylesheet: " . $@ );
            $self->sendError( $ctxt, "Could not transform using stylesheet: " . $@ );
            return 0;
        }

        $ctxt->object->body( $body . $transformed->documentElement->toString() );
    }
    else {
        # otherwise use DBIx::XHTML_Table

        # execute the query by DBIx:XHTML_Table
        my $table = DBIx::XHTML_Table->new( $dbh->get_dbh() );
        $table->set_null_value('&#160;');
        $table->modify(td => {
            class => [qw(orange blue)],
        });
        $table->exec_query( $sql, \@params );

        $ctxt->object->body( $body . $table->output() );
    }

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );
    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $body = $self->param( 'body' );
    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }
        my $object = $ctxt->object();
        $body = XIMS::xml_escape( $body );
        $body =~ /FROM\s(.*?)($|\sWHERE\s)/i;
        return 0 unless $self->_test_granted_schemata( $ctxt, $1 );
        $ctxt->object->body( $body );
    }

    my $skeys  = $self->param( 'skeys' );
    if ( defined $skeys ) {
        $skeys =~ s/\s+//g;
        $ctxt->object->attribute( skeys => $skeys );
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        if ( not $object->publish() ) {
            XIMS::Debug( 2, "publishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Publishing object '" . $object->title() . "' failed." );
            return 0;
        }

        $object->grant_user_privileges (  grantee         => XIMS::PUBLICUSERID(),
                                          privilege_mask  => ( XIMS::Privileges::VIEW ),
                                          grantor         => $user->id() );
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        if ( not $object->unpublish() ) {
            XIMS::Debug( 2, "unpublishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Unpublishing object '" . $object->title() . "' failed." );
            return 0;
        }

        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $object->id() );
        $privs_object->delete();
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

sub _build_form_from_skeys {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @skeys = @_;

    return undef unless scalar @skeys > 0;

    my $form = $self->start_form( -method => 'GET', -class => 'sform' );
    my $origkey;
    foreach my $skey ( @skeys ) {
        # rename query params to avoid name clash with already used XIMS params
        $origkey = $skey;
        $skey = "sqlrep.$skey";
        $form .= $self->div($self->strong( $origkey ),
                            $self->textfield( -name => lc $skey,
                                              -default => XIMS::decode( $self->param( lc $skey ) ),
                                              -force => 1,
                                              -size => 50,
                                            )
                           );
    }

    $form .= $self->submit(-name => 's',
                           -value => 'Submit');
    $form .= $self->endform();

    return $form;
}

sub _build_crits_from_skeys {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @skeys = @_;

    return undef unless scalar @skeys > 0;

    my %criteria;
    my $origkey;
    foreach my $skey ( @skeys ) {
        # rename query params to avoid name clash with already used XIMS params
        $origkey = $skey;
        $skey = "sqlrep.$skey";
        my $value = $self->param( lc $skey );
        next unless defined $value and length $value;
        $value = XIMS::decode( $value );

        # allow * asterisk lookups
        $value =~ s/\*+/%/g;

        # play safe and do not allow multiple wildcards
        $value =~ s/%+/%/g;
        $value =~ s/\?+/?/g;

        # be case insensitive
        $criteria{ "lower($origkey)" } = lc $value;
    }

    return \%criteria;
}

sub _test_granted_schemata {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my $tables = shift;

    # during creation we do not have an object with an owner, so we take
    # the current (object creating) user
    my $user = $ctxt->object->id ? $ctxt->object->owner : $ctxt->session->user;

    my @schemata;
    while ( $tables =~ /([a-zA-z0-9\$-_]+)\./g) {
       push( @schemata, $1 );
    }

    unless ( scalar @schemata > 0 ) {
        $self->sendError( $ctxt, "Tablenames need schema prefix. Please edit the SQLReport SQL query." );
        return 0;
    }

    my @sqlrep_schemaroles;
    foreach ( $user->roles_granted() ) {
        if ( $_->name =~ /XIMS:SQLReportSchema:(.+)/i ) {
            push( @sqlrep_schemaroles, $1);
        }
    }

    foreach my $schema ( @schemata ) {
        unless ( grep { /$schema/i } @sqlrep_schemaroles ) {
            $self->sendError( $ctxt, "Schema $schema not granted. Please edit the SQLReport SQL query or get role grants for XIMS:SQLReportSchema:$schema." );
            return 0;
        }
    }

    return 1;
}

sub _agentdbh {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $dp = XIMS::DataProvider->new( 'DBI', { dbuser => $AGENTUSER, dbpasswd => $AGENTPASSWORD } );
    if ( not $dp ) {
        XIMS::Debug( 2, "could not create data provider with the ximsagent user");
        $self->sendError( $ctxt, "Could not connect to database using the Agent User");
        return 0;
    }

    return $dp->driver->dbh();
}

1;
