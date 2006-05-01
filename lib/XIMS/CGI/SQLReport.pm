# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SQLReport;

use strict;
use base qw(XIMS::CGI);
use Text::Iconv;
use DBIx::XHTML_Table;
use XML::Generator::DBI;
use XML::LibXML;
use XML::LibXSLT;
use XML::LibXML::SAX::Builder;
use XIMS::DataProvider;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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
    $self->_generate_body_from_sql( $ctxt);

    # Since a connect string including a password is stored there, we do not want to display it for ?passthru=1
    $ctxt->object->attributes( undef );

    # Let XIMS::CGI::selectStylesheet do the right thing - choose from a stylesheet directory assigned to the
    # DepartmentRoot and not use the stylesheet explictly assigned for transforming the body
    $ctxt->object->style_id( undef );

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
        if ( defined XIMS::Config::SQLReportTestGrantedSchemas() and XIMS::Config::SQLReportTestGrantedSchemas() == 1 ) {
            return 0 unless $self->_test_granted_schemata( $ctxt, $1 );
        }
        $ctxt->object->body( $body );
    }

    my $skeys  = $self->param( 'skeys' );
    if ( defined $skeys ) {
        $skeys =~ s/\s+//g;
        $ctxt->object->attribute( skeys => $skeys );
    }

    my $pagesize  = $self->param( 'pagesize' );
    if ( defined $pagesize ) {
        $pagesize = XIMS::trim($pagesize);
        if ( not defined $pagesize or length $pagesize and $pagesize =~ /^\d+$/ ) {
            $ctxt->object->attribute( pagesize => $pagesize );
        }
    }

    my $dbdsn  = $self->param( 'dbdsn' );
    if ( defined $dbdsn ) {
        $dbdsn = XIMS::trim( $dbdsn );
        $ctxt->object->attribute( dbdsn => $dbdsn );
    }

    my $dbuser  = $self->param( 'dbuser' );
    if ( defined $dbuser ) {
        $dbuser = XIMS::trim( $dbuser );
        $ctxt->object->attribute( dbuser => $dbuser );
    }

    my $dbpwd  = $self->param( 'dbpwd' );
    if ( defined $dbpwd ) {
        $dbpwd = XIMS::trim( $dbpwd );
        $ctxt->object->attribute( dbpwd => $dbpwd );
    }

    return $self->SUPER::event_store( $ctxt );
}


sub event_plain {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->_generate_body_from_sql( $ctxt );

    my $df = XIMS::DataFormat->new( id => $ctxt->object->data_format_id() );
    my $mime_type = $df->mime_type;

    my $charset;
    if (! ($charset = XIMS::DBENCODING )) { $charset = "UTF-8"; }
    print $self->header( -Content_type => $mime_type."; charset=".$charset );
    print $ctxt->object->body();
    $self->skipSerialization(1);

    return 0;
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
    my $self = shift;
    return $self->publish_gopublic( @_ );
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->unpublish_gopublic( @_ );
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

    $form .= $self->hidden(-name => 'onepage',
                           -value => '1') if $self->param('onepage');
    $form .= $self->submit(-name => 's',
                           -value => 'Submit');
    $form .= $self->endform();

    return $form;
}

sub _generate_body_from_sql {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    # check for an SQL query in the body, return if none is found
    my $sql = XIMS::xml_unescape( $ctxt->object->body() );
    return 0 unless (defined $sql and length $sql);

    # connect to database using agent user
    my $dbh = $self->_agentdbh( $ctxt );
    return 0 unless $dbh;

    if ( XIMS::Config::SQLReportTestGrantedSchemas() and XIMS::Config::SQLReportTestGrantedSchemas() == 1 ) {
        # check for granted schema privileges
        my ($tables) = ($sql =~ /FROM\s(.*?)($|\sWHERE\s)/i);
        return 0 unless $self->_test_granted_schemata( $ctxt, $tables );
    }

    # check, whether we should build search conditions and a search form
    # based on the 'skeys' attribute
    my $criteria;
    my $body = '';
    my $skeys = $ctxt->object->attribute_by_key( 'skeys' );
    if ( defined $skeys ) {
        my @skeys = split( ',', $skeys );
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
    }

    # prepare pagination unless onepage is set

    my $offset;
    my $rowlimit;

    if ( not $self->param('onepage') ) {
        # calculate offset
        $offset = $self->param('page');
        $offset = $offset - 1 if $offset;
        $offset ||= 0;

        # Check for object specific pagesize
        my $pagesize = $ctxt->object->attribute_by_key( 'pagesize' );
        if ( defined $pagesize ) {
            $rowlimit = $pagesize;
        }
        else {
            $rowlimit = XIMS::Config::SQLReportPagesize();
        }

        $self->param( 'pagesize', $rowlimit ); # Set it for the stylesheet and save a call to document()

        $offset = $offset * $rowlimit;
    }

    # create query for the search result count

    # get rid of newlines, DBIx::SQLEngine does not like them...
    $sql =~ s/\r\n/ /g;

    # remove trailing semicolons
    $sql =~ s/\s*;\s*$//;

    # order by and group by clauses have to be removed not to clash
    # with the SQLEngine generated where clause
    my ($orderby) = ( $sql =~ /\s+ORDER\s+BY\s+(.+)\s*$/i );
    my ($groupby) = ( $sql =~ /\s+GROUP\s+BY\s+(\w+)/i );
    $sql =~ s/\s+GROUP\s+BY\s+\w+//i;
    $sql =~ s/\s+ORDER\s+BY\s+(.+)\s*$//i;

    my $countsql = $sql;
    my ($properties) = ($countsql =~ /^\s*SELECT\s(.*?)\sFROM/i);

    if ( $properties =~ /^\s*\*\s*$/ ) {
        XIMS::Debug( 2, "* in properties " . $@ );
        $self->sendError( $ctxt, "Please specify explict query properties, do not use '*'.");
        return 0;
    }

    my $countproperty = 'COUNT(*) AS count';
    if ( defined $groupby ) {
        $countproperty = "COUNT(DISTINCT $groupby) AS count";
    }

    $countsql =~ s/\Q$properties\E/$countproperty/;

    my $count;
    eval { $count = $dbh->fetch_one_value( sql => $countsql, criteria => $criteria ); };
    if ( $@ ) {
        XIMS::Debug( 2, "SQL query failed " . $@ );
        return $self->sendError( $ctxt, "$@");
    }

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

    my $dbh;

    my $dbdsn = $ctxt->object->attribute_by_key( 'dbdsn' );

    if ( defined $dbdsn ) {
        XIMS::Debug( 4, "Trying configured DSN" );
        my $dbuser = $ctxt->object->attribute_by_key( 'dbuser' );
        my $dbpwd = $ctxt->object->attribute_by_key( 'dbpwd' );

        eval {
            $dbh = DBIx::SQLEngine->new( $dbdsn, $dbuser, $dbpwd );
        };
        if ( $@ or not defined $dbh ) {
            XIMS::Debug( 2, "Could not connect to database: $@");
            return $self->sendError( $ctxt, "Could not connect to database: $@");
        }
    }
    else {
        XIMS::Debug( 4, "Using default DSN with SQLReportAgentUser" );
        my $dp;

        eval {
            $dp = XIMS::DataProvider->new( 'DBI', { dbuser => XIMS::Config::SQLReportAgentUser(), dbpasswd => XIMS::Config::SQLReportAgentUserPassword() } );
        };
        if ( $@ or not defined $dp ) {
            XIMS::Debug( 2, "could not create data provider with the ximsagent user");
            return $self->sendError( $ctxt, "Could not connect to database using the SQLReportAgentUser. Please check your sqlreportconfig.xml");
        }
        $dbh = $dp->driver->dbh();
    }

    return $dbh;
}

1;
