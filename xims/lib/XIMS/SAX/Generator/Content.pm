# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::Content;

use strict;
use vars qw(@ISA);
@ISA = qw(XIMS::SAX::Generator XML::Generator::PerlData);

use Data::Dumper;
use XIMS::SAX::Generator;
use XML::Generator::PerlData;
use XIMS::DataProvider;
use XML::Filter::CharacterChunk;

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
    $doc_data->{context}->{session} = {$ctxt->session->data()};
    $doc_data->{context}->{session}->{user} = {$ctxt->session->user->data()};

    # shove parent into object if we are creating things
    if ( $ctxt->parent() ) {
        $ctxt->object( $ctxt->parent() );
    }

    # fun with content objects
    if ( $ctxt->object() ) {
        # PHISH NOTE:
        # the escape body thing cannot be resolved otherwise, since
        # the default should be the filter set(!), we need a flag to
        # remove that filter.
        if ( not defined $ctxt->properties->content->escapebody()
             or $ctxt->properties->content->escapebody() == 0 ) {
                 push ( @{$self->{FilterList}},
                  XML::Filter::CharacterChunk->new(Encoding => "ISO-8859-1",
                                                   TagName=>[qw(body abstract)]) );
        }

        $doc_data->{context}->{object} = {$ctxt->object->data()};

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

        # add the user's privs.
        $doc_data->{context}->{object}->{user_privileges} = {$ctxt->session->user->object_privileges( $ctxt->object() )};
        # ubu
        #warn "privs in SAX: " . Dumper( $doc_data->{context}->{object}->{user_privileges} );
        
        $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats);
    }
    # end content-object joy

    if ( $ctxt->objectlist() ) {
        $doc_data->{objectlist} = { object => $ctxt->objectlist() };
    }

    if ( $ctxt->userlist() ) {
        # my @user_list = map{ $_->data() ) } @{$ctxt->userlist()};
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

    #warn "about to process: " . Dumper( $ctxt );
    $self->parse_chunk( $ctxt );

    return $self->parse_end;
}


##
#
# SYNOPSIS
#    $self->get_config();
#
# PARAMETER
#    none
#
# RETURNS
#    %opts : a plain HASH containing the PerlData parse options.
#
# DESCRIPTION
#    used internally to retrieve the XML::Generator::PerlData options for this class.
#
sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # The number of options here should become less and less as time goes on
    # and the API stablizes a bit.

    my %opts = (
                keymap  => { '*' => \&XIMS::SAX::Generator::elementname_fixer },
                attrmap => {object      => ['id', 'document_id', 'parent_id', 'level'],
                            data_format => 'id',
                            user        => 'id',
                            session     => 'id',
                            object_type => 'id' },
                skipelements => ['username', 'salt', 'objtype', 'properties', 'password', 'provider', 'driver', 'dbh'],
               );
    return %opts;
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

    my $object = $ctxt->object();
    my $gotsymlink = 1 if defined $ctxt->object()->symname_to_doc_id();
    my $tagname = 'children';
    my %childrenargs;

    # look if we should fetch children of another object
    if ( $ctxt->properties->content->getchildren->objectid() ) {
        $object = XIMS::Object->new( id => $ctxt->properties->content->getchildren->objectid(), User => $ctxt->session->user );
        unless ( $gotsymlink ) {
            $doc_data->{context}->{object}->{target} = { object => $object };
            $tagname = 'targetchildren';
            # since we don't fetch the children of the context-object,
            # the parents of the target come in handy for further browsing
            $doc_data->{context}->{object}->{targetparents} = {object => XIMS::Object->new( id => $ctxt->properties->content->getchildren->objectid() )->ancestors() };
        }
    }

    my @object_type_ids;
    if ( $ctxt->properties->content->getchildren->objecttypes and scalar @{$ctxt->properties->content->getchildren->objecttypes} > 0 ) {
        my $ot;
        foreach my $name ( @{$ctxt->properties->content->getchildren->objecttypes} ) {
            $ot = XIMS::ObjectType->new( name => $name );
            push(@object_type_ids, $ot->id()) if defined $ot;
        }
        $childrenargs{object_type_id} = \@object_type_ids;
    }

    my @children = $object->children_granted( %childrenargs );
    if ( scalar( @children ) > 0 ) {
        foreach my $child ( @children ) {
            if ( $ctxt->properties->content->getchildren->addinfo() ) {
                #my $chldinfo = $ctxt->data_provider->getChildObjectsInfo(
                #                                                       -majorid    => $child->id(),
                #                                                       -languageid => $child->language_id(),
                #                                                      );
                #$child->{children_count}      = $chldinfo->[0];
                #$child->{child_last_modified} = $chldinfo->[1];
            }

            # remember the seen objecttypes
            $object_types->{$child->object_type_id()} = 1;
            $data_formats->{$child->data_format_id()} = 1;

            # got another possible db-hit here per child :-/
            #
            # looks like the whole getting children process needs change because currently 
            # normal users get children back they have no grants on
            #
            # delete children with privmask 0 here? hacky, i guess not
            # $ctxt->session->user->children( $object )?
            #
            $child->{user_privileges} = {$ctxt->session->user->object_privileges( $child )};

            # yet another superfluos db hit! this has to be changed!!!
            $child->{content_length} = $child->content_length();
        }
    }

    $doc_data->{context}->{object}->{$tagname} = {object => \@children};
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
