# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::Content;

use strict;
use base qw(XIMS::SAX::Generator XML::Generator::PerlData);
use XIMS::DataProvider;
use XML::Filter::CharacterChunk;
use XIMS::SAX::Filter::ContentObjectPropertyResolver;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    $generator->prepare( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData
#
# DESCRIPTION
#
#
sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %object_types = ();
    my %data_formats = ();

    $self->{FilterList} = [];

    my $doc_data = { context => {} };

    if ( $ctxt->session() ) {
        $doc_data->{context}->{session} = {$ctxt->session->data()};
        $doc_data->{context}->{session}->{user} = {$ctxt->session->user->data()} if defined $ctxt->session->user;
        my $publicusername = $ctxt->apache()->dir_config('ximsPublicUserName');
        $doc_data->{context}->{session}->{public_user} = 1 if defined $publicusername;
    }

    # fun with content objects
    if ( $ctxt->object() ) {
        $doc_data->{context}->{object} = {$ctxt->object->data()};
        # PHISH NOTE:
        # the escape body thing cannot be resolved otherwise, since
        # the default should be the filter set(!), we need a flag to
        # remove that filter.
        my %encargs;
        $encargs{Encoding} = XIMS::DBENCODING() if XIMS::DBENCODING();
        if ( not $ctxt->properties->content->escapebody() ) {
                 push ( @{$self->{FilterList}},
                  XML::Filter::CharacterChunk->new(%encargs,
                                                   TagName=>[qw(body)]) );
        }
        if ( $ctxt->properties->content->resolveimage_id() ) {
            push ( @{$self->{FilterList}},
                XIMS::SAX::Filter::ContentObjectPropertyResolver->new(  User           => $ctxt->session->user,
                                                                        ResolveContent => [ qw( image_id ) ],
                                                                        Properties     => [ qw( abstract ) ]
                                                               ) );
        }

        $self->_set_parents( $ctxt, $doc_data, \%object_types, \%data_formats );

        if ( $ctxt->properties->content->childrenbybodyfilter ) {
            $doc_data->{context}->{object}->{children} = $ctxt->object->body();
            delete $doc_data->{context}->{object}->{body};
        }
        else {
            $self->_set_children( $ctxt, $doc_data, \%object_types, \%data_formats );
        }

        if ( defined $ctxt->properties->content->siblingscount() ) {
            $doc_data->{context}->{object}->{siblingscount} = $ctxt->properties->content->siblingscount();
        }

        $object_types{$ctxt->object->object_type_id()} = 1;
        $data_formats{$ctxt->object->data_format_id()} = 1;

        if ( $ctxt->session() ) {
            # add the user's privs.
            my %userprivs = $ctxt->session->user->object_privileges( $ctxt->object() );
            $doc_data->{context}->{object}->{user_privileges} = {%userprivs} if ( grep { defined $_ } values %userprivs );
        }
        $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats);
    }
    # end content-object joy

    if ( $ctxt->objectlist() ) {
        $doc_data->{objectlist} = { object => $ctxt->objectlist() };
    }

    if ( $ctxt->userlist() ) {
        $doc_data->{userlist} = { user => $ctxt->userlist() };
    }

    if ( $ctxt->user() ) {
        $doc_data->{context}->{user} = $ctxt->user() ;
    }

    return $doc_data;
}


##
#
# SYNOPSIS
#    $generator->parse( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    the result of the last Handler after parsing
#
# DESCRIPTION
#    Used privately by XIMS::SAX to kick off the SAX event stream.
#
sub parse {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %opts = (@_, $self->get_config);

    $self->parse_start( %opts );

    # cases we need to parse a full document and not -chunk ?
    $self->parse_chunk( $ctxt );

    return $self->parse_end;
}

##
#
# SYNOPSIS
#    $generator->get_filters();
#
# PARAMETER
#    none
#
# RETURNS
#    @filters : an @array of Filter class names
#
# DESCRIPTION
#    Used internally by XIMS::SAX to allow this class to set
#    additional SAX Filters in the filter chain
#
sub get_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters =  $self->SUPER::get_filters();

    push @filters, @{$self->{FilterList}};

    return @filters;
}


# helper function to fetch the parents.
sub _set_parents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    my $parents = $ctxt->object->ancestors();
    if ( length $parents && scalar( @{$parents} ) > 0 ) {
        foreach my $parent ( @{$parents} ) {
            $object_types->{$parent->object_type_id} = 1;
            $data_formats->{$parent->data_format_id} = 1;

        }
        $doc_data->{context}->{object}->{parents} = {object => $parents};
    }
}

# helper function to fetch the children.
sub _set_children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    # do not fetch children unless we are told to do so...
    my $level = $ctxt->properties->content->getchildren->level();
    return undef unless $level;

    my $object = $ctxt->object();
    my $ots = $ctxt->properties->content->getchildren->objecttypes();
    my $tagname = 'children';
    my %childrenargs;

    # look if we should fetch children of another object
    if ( $ctxt->properties->content->getchildren->objectid() ) {
        $object = XIMS::Object->new( id => $ctxt->properties->content->getchildren->objectid(), User => $ctxt->session->user );
        # set by event_move_browse or event_contentbrowse...talking about assumptions...
        my $style = $ctxt->properties->application->style();
        if ( $style =~ "browse" ) {
            $doc_data->{context}->{object}->{target} = { object => $object };
            $tagname = 'targetchildren';
            # since we don't fetch the children of the context-object,
            # the parents of the target come in handy for further browsing
            $doc_data->{context}->{object}->{targetparents} = {object => XIMS::Object->new( id => $ctxt->properties->content->getchildren->objectid() )->ancestors() };
        }
    }

    my @object_type_ids;
    if ( $ots and scalar @{$ots} > 0 ) {
        my $ot;
        foreach my $name ( @{$ots} ) {
            $ot = XIMS::ObjectType->new( fullname => $name );
            push(@object_type_ids, $ot->id()) if defined $ot;
        }
        $childrenargs{object_type_id} = \@object_type_ids;
    }

    my $child_count;
    my @children;
    my %privmask;
    if ( $level == 1 ) {
        #$child_count = $object->child_count_granted( %childrenargs );
        #$childrenargs{limit} = $ctxt->properties->content->getchildren->limit();
        #$childrenargs{offset} = $ctxt->properties->content->getchildren->offset();
        #$childrenargs{order} = $ctxt->properties->content->getchildren->order();
        #@children = $object->children_granted( %childrenargs );

        #
        # So this is dirty.
        # The following is a performance hack to avoid extra SQL queries to get the content length and user privileges *per child* in the
        # loop over the @children array further down below.
        # I am not happy with building SQL statements here, but it really saves a lot of processing time. As this query with the specific
        # joins, criteria and properties will be useful only here, as it looks now. Additionally, as we only got DBI-based data providers
        # currently, I do not see the need of encapsulating that logic in a method of XIMS::Object for now.
        #
        my $userid = $ctxt->session->user()->id();
        my $properties = 'distinct c.id, d.document_status, d.position, c.lob_length AS content_length, d.parent_id, object_type_id, creation_timestamp, symname_to_doc_id, last_modified_by_middlename, last_modified_by_firstname, language_id, last_publication_timestamp, last_published_by_lastname, css_id, created_by_firstname, data_format_id, keywords, last_modification_timestamp, last_modified_by_id, title, document_id, location, created_by_lastname, attributes, last_modified_by_lastname, image_id, created_by_id, owned_by_firstname, marked_deleted, last_published_by_id, notes, style_id, owned_by_lastname, owned_by_middlename, abstract, published, locked_by_lastname, locked_by_id, last_published_by_firstname, script_id, owned_by_id, created_by_middlename, data_format_name, locked_by_middlename, last_published_by_middlename, marked_new, locked_time, department_id, locked_by_firstname ';
        my $tables = 'ci_content_loblength c, ci_documents d';
        my $conditions = 'c.document_id = d.id AND d.parent_id = ?';
        my @values = ( $object->document_id() );
        if ( not $ctxt->session->user->admin() ) {
            my @userids = ( $userid, $ctxt->session->user->role_ids());
            $tables .= ', ci_object_privs_granted p';
            $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
            push @values, @userids;
        }
        if ( scalar @object_type_ids > 0 ) {
            $tables .= ', ci_object_types ot';
            $conditions .= " AND ot.id = d.object_type_id AND ot.id IN (". join(',', map { '?' } @object_type_ids) . ")";
            push @values, @object_type_ids;
        }

        my $countsql = "SELECT count(distinct c.id) AS cid FROM $tables WHERE $conditions";
        my $countdata = $object->data_provider->driver->dbh->fetch_select( sql => [ $countsql, @values ] );
        $child_count = $countdata->[0]->{cid};

        if ( defined $child_count and $child_count > 0 ) {
            my $sql = "SELECT $properties FROM $tables WHERE $conditions";
            my $data = $object->data_provider->driver->dbh->fetch_select(
                                                                         sql => [ $sql, @values ],
                                                                         limit => $ctxt->properties->content->getchildren->limit(),
                                                                         offset => $ctxt->properties->content->getchildren->offset(),
                                                                         order => $ctxt->properties->content->getchildren->order()
                                                                         );

            my @childids;
            foreach my $kiddo ( @{$data} ) {
                push( @children, (bless $kiddo, 'XIMS::Object') );
                push( @childids, $kiddo->{id} );
                $privmask{$kiddo->{id}} = 0xffffffff if $ctxt->session->user->admin();
            }

            if ( not $ctxt->session->user->admin() ) {
                my @uid_list = ($userid, $ctxt->session->user->role_ids());
                my @priv_data = $object->data_provider->getObjectPriv( content_id => \@childids,
                                                                 grantee_id => \@uid_list,
                                                                 properties => [ 'privilege_mask', 'content_id' ] );
                foreach my $priv ( @priv_data ) {
                    $privmask{$priv->{'objectpriv.content_id'}} |= int($priv->{'objectpriv.privilege_mask'});
                }
            }
        }
    }
    else {
        $childrenargs{maxlevel} = $level;
        $child_count = $object->descendant_count_granted( %childrenargs );
        $childrenargs{limit} = $ctxt->properties->content->getchildren->limit();
        $childrenargs{offset} = $ctxt->properties->content->getchildren->offset();
        $childrenargs{order} = $ctxt->properties->content->getchildren->order();
        @children = $object->descendants_granted( %childrenargs );
    }

    if ( scalar( @children ) > 0 ) {
        my %container_ids;
        if ( $level != 1 ) {
            my @container_id_data = $object->data_provider->getDataFormat( mime_type => 'application/x-container ' );
            map { $container_ids{$_->{'dataformat.id'}}++ } @container_id_data;
        }
        foreach my $child ( @children ) {
            if ( $ctxt->properties->content->getchildren->addinfo() ) {
                my @info = $ctxt->data_provider->get_descendant_infos( parent_id => $child->document_id() );
                $child->{descendant_count}                       = $info[0];
                $child->{descendant_last_modification_timestamp} = $info[1];
            }

            # remember the seen objecttypes
            $object_types->{$child->object_type_id()} = 1;
            $data_formats->{$child->data_format_id()} = 1;

            # if $level == 1 we are fetching the children and the object privileges have already
            # been loaded by the hack above
            if ( $level != 1 ) {
                my %uprivs = $ctxt->session->user->object_privileges( $child );
                $child->{user_privileges} = {%uprivs} if ( grep { defined $_ } values %uprivs );
            }
            else {
                my $privilege_mask = $privmask{$child->{id}};
                $child->{user_privileges} = XIMS::Helpers::privmask_to_hash( $privilege_mask );
            }

            # content length has already been loaded if $level == 1
            if ( $level != 1 and (not exists $container_ids{$child->data_format_id()}) ) {
                $child->{content_length} = $child->content_length();
            }
        }
    }

    $doc_data->{context}->{object}->{$tagname} = {object => \@children};
    $doc_data->{context}->{object}->{$tagname}->{totalobjects} = $child_count;

}

# helper function to fetch the used dataformats and object types
sub _set_formats_and_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    # add the used object-types and data-formats
    my $used_types;
    my $used_formats;
    if ( $ctxt->properties->content->getformatsandtypes() ) {
        # users shall only see object-types they have creation grants on
        @{$used_types} = $ctxt->session->user->creatable_object_types();
        @{$used_formats} = $ctxt->data_provider->data_formats() ;

    }
    else {
        # per default we need only the used dataformats and object types
        @{$used_types}   = grep { exists $object_types->{$_->id()} } $ctxt->data_provider->object_types() ;
        @{$used_formats} = grep { exists $data_formats->{$_->id()} } $ctxt->data_provider->data_formats() ;
    }

    $doc_data->{object_types} = {object_type => $used_types};
    $doc_data->{data_formats} = {data_format => $used_formats};
}

1;
