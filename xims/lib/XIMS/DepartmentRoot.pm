# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::DepartmentRoot;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::Object;
use XIMS::Folder;
use XIMS::Portlet;
use XIMS::URLLink;
use XIMS::DataFormat;
use XIMS::Importer::Object;
use XIMS::Importer::Object::URLLink;

use XML::LibXML;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Folder');

##
#
# SYNOPSIS
#    XIMS::DepartmentRoot->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $dept: XIMS::DepartmentRoot instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'DepartmentRoot' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
# SYNOPSIS
#    my $boolean = $deptroot->add_departmentlinks( @objects );
#
# PARAMETER
#    @objects    : Array of content objects to be used as departmentlinks
#
# RETURNS
#    $boolean : True or False on success or failure
#
# DESCRIPTION
#    Checks for an already assigned departmentlinks portlet and adds additional departmentlinks
#    if such portlet already exists.  If not, a 'departmentlinks' folder is created,
#    the departmentlinks and the portlet added and assigned respectively.
#
sub add_departmentlinks {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @objects = @_;

    return undef unless @objects and scalar @objects > 0;

    my $oimporter = XIMS::Importer::Object->new( User => $self->User, Parent => $self );

    # hardcode alarm
    my $dpl_location = 'departmentlinks';
    my $dplp_location = 'departmentlinks_portlet.ptlt';

    # check for portlet
    my @portlet_ids = $self->get_portlet_ids();

    my $deptlinksportlet;
    $deptlinksportlet = XIMS::Portlet->new( id => \@portlet_ids, location => $dplp_location, marked_deleted => undef ) if $portlet_ids[0];

    my $deptlinksfolder;
    $deptlinksfolder = $deptlinksportlet->target() if $deptlinksportlet;
    $deptlinksfolder = undef if (defined $deptlinksfolder and $deptlinksfolder->marked_deleted());
    if ( not $deptlinksfolder ) {
        # add folder if its not here already
        my @children = $self->children( location => $dpl_location, marked_deleted => undef );
        $deptlinksfolder = $children[0];
        if ( not ($deptlinksfolder and $deptlinksfolder->id) ) {
            $deptlinksfolder = XIMS::Folder->new( User => $self->User, location => $dpl_location );
            my $id = $oimporter->import( $deptlinksfolder );
            if ( not $id ) {
                XIMS::Debug( 2, "could not create departmentlinks folder '$dpl_location'" );
                return undef;
            }
        }
    }

    # add links
    my $urlimporter = XIMS::Importer::Object::URLLink->new( User => $self->User, Parent => $deptlinksfolder );
    return undef unless $urlimporter;
    my $location_path;
    foreach my $object ( @objects ) {
        next if ($object->location eq $dpl_location or $object->location eq $dplp_location);
        $location_path = XIMS::RESOLVERELTOSITEROOTS() eq '1' ? $object->location_path_relative() : $object->location_path();
        my $urllink = XIMS::URLLink->new( User => $self->User(),
                                          location => $location_path,
                                          title => $object->title(),
                                          abstract => $object->abstract(),
                                       );
        my $id = $urlimporter->import( $urllink );
        XIMS::Debug( 3, "could not create departmentlink '$location_path'. Perhaps it already exists." ) unless $id;
    }

    # create and assign portlet if neccessary
    if ( not $deptlinksportlet ) {
        my $dplp_location_nosuffix = $dplp_location;
        $dplp_location_nosuffix =~ s/\.[^\.]+$//;
        $deptlinksportlet = XIMS::Portlet->new( User => $self->User, location => $dplp_location, title => $dplp_location_nosuffix );
        $deptlinksportlet->target( $deptlinksfolder );
        # *do not look at the following lines, hack-attack!*
        # see portlet::generate_body why this hack is here.
        # REWRITE!
        my $body = '<content><column name="abstract"/><column name="location"/><column name="title"/><object-type name="URLLink"/></content>';
        $deptlinksportlet->body( $body );
        my $id = $oimporter->import( $deptlinksportlet );
        if ( not $id ) {
            XIMS::Debug( 2, "could not create departmentlinks portlet '$dplp_location'" );
            return undef;
        }
        if ( not ($self->add_portlet( $deptlinksportlet ) and $self->update()) ) {
            XIMS::Debug( 2, "could not assign departmentlinks portlet '$dplp_location'" );
            return undef;
        }
    }

    return 1;
}

##
# SYNOPSIS
#    my @portlet_ids = $deproot->get_portlet_ids();
#
# PARAMETER
#    none
#
# RETURNS
#    @portlet_ids : Array of content ids of portlets stored in the body's XML-Fragment
#
# DESCRIPTION
#    Returns a list of content ids of the portlets stored in the body's XML-Fragment. In scalar context it returns the first entry.
#
sub get_portlet_ids {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my @portlet_ids;

    return undef unless ($self->body and length $self->body);

    my $fragment = $self->_getbodyfragment();
    return undef unless $fragment;

    foreach my $node ( grep {$_->nodeName() eq 'portlet'} $fragment->childNodes ) {
        push @portlet_ids, $node->string_value();
    }

    return undef unless (@portlet_ids and scalar @portlet_ids > 0);
    return wantarray ? @portlet_ids : $portlet_ids[0];
}


##
# SYNOPSIS
#    my $boolean = $deproot->add_portlet( $target );
#
# PARAMETER
#    $target   :  XIMS::Object instance or location_path to one
#
# RETURNS
#    $boolean : True or False on success or failure
#
# DESCRIPTION
#    Adds a portlet entry to the body in form of an XML-Fragment.
#    Storing the portlets that way and not relational is something still
#    to be discussed I guess.
#
sub add_portlet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $target = shift;

    return undef unless $target;

    my $pobject = $target if (ref $target and $target->isa('XIMS::Object'));
    $pobject ||= XIMS::Object->new( path => $target );
    if ( $pobject ) {
        my $id = $pobject->id;
        XIMS::Debug( 4, "got portlet with id = $id ");
        if ( defined $self->body and length $self->body ) {
            XIMS::Debug( 4, "got existing department info" );

            my $fragment = $self->_getbodyfragment();
            return undef unless $fragment;

            # check if id is already there
            my ( $node ) = grep {$_->string_value() eq $id} $fragment->childNodes;
            if ( defined $node ) {
                XIMS::Debug( 3, "portlet ($id) already exists here" );
                return 1;
            }
            else {
                XIMS::Debug( 4, "3. step: insert the entry" );
                $node = XML::LibXML::Element->new("portlet");
                $node->appendText( $id );
                $fragment->appendChild( $node );

                XIMS::Debug( 4, "4. step: store body back." );
                $self->body( $fragment->toString() );
            }
        }
        else {
            $self->body( "<portlet>$id</portlet>" );
        }
    }
    else {
        XIMS::Debug( "Portlet not found for $target!");
        return undef;
    }

    return 1;
}

##
# SYNOPSIS
#    my $boolean = $deproot->remove_portlet( $portlet_id );
#
# PARAMETER
#    $portlet_id   :  Content id of portlet to be removed
#
# RETURNS
#    $boolean : True or False on success or failure
#
# DESCRIPTION
#    Removes a portlet entry from the body's XML-Fragment.
#
sub remove_portlet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $portlet_id = shift;

    return undef unless ($portlet_id and $portlet_id > 0);
    return undef unless ($self->body and length $self->body);

    my $fragment = $self->_getbodyfragment();
    return undef unless $fragment;

    my ( $node ) = grep {$_->string_value() eq $portlet_id} $fragment->childNodes;
    if ( defined $node ) {
        XIMS::Debug( 6, "found node" );
        $node->unbindNode; # remove node from its context.
        $self->body( $fragment->toString() );
    }
    else {
        XIMS::Debug( 3, "no portlet with id '$portlet_id' found" );
        return 0;
    }

    return 1;
}

sub _getbodyfragment {
    my $self = shift;

    my $parser = XML::LibXML->new();
    my $fragment;
    eval {
        $fragment = $parser->parse_xml_chunk( $self->body );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "problem with the department body ($@)"  );
        return undef;
    }

    return $fragment;
}

1;
