# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::VLibraryItem::DocBookXML;

#use Data::Dumper;
use XIMS::VLibAuthor;
use XIMS::VLibKeyword;
use XIMS::VLibSubject;
use XIMS::VLibPublication;
use XIMS::VLibMeta;

use XIMS::Importer::Object::XML;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::Object::XML);

sub import {
    XIMS::Debug(5, "called");

    my $self = shift;
    my $object = shift;
    my $updateexisting = shift;
    return undef unless $object;

    my $body = $object->body();
    return undef unless $body;

    my $root = $self->get_rootelement( \$body, nochunk => 1 );
    return undef unless $root;

    # hmmm, this is a rather subtle way to check and decode the body if it has not already been decoded upstream
    my $decbody = XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$root->toString()) : $root->toString();
    $object->body( $decbody ) if defined $decbody and length $decbody;

    my $id = $self->SUPER::import( $object, $updateexisting );

    $self->vlproperties_from_document( $root, $object );

    return $id;
}


sub vlproperties_from_document {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;
    my $object = shift;

    #title
    $object->title( $self->_trim(
      $self->_nodevalue($root->findnodes( "/article/articleinfo/title|/book/bookinfo/title|/book/title" ) )));

    #abstract
    $object->abstract( ($root->getElementsByTagName("abstract"))[0]->firstChild->toString(0,1) )
      if $root->getElementsByTagName("abstract");

    #vlauthors
    my @authorgroup = $root->findnodes( "/article/articleinfo/authorgroup|/book/bookinfo/authorgroup" );
    my @authors = $self->authors_from_node( $authorgroup[0] );

    $object->vleauthors( @authors );

    #vlkeywords
    my @keywordset = $root->findnodes( "/book/bookinfo/keywordset|/article/articleinfo/keywordset" );
    my @keywords = $self->keywords_from_node( $keywordset[0] );

    $object->vlekeywords( @keywords );

    #vlsubjects
    my @subjectset = $root->findnodes( "/book/bookinfo/subjectset|/article/articleinfo/subjectset" );
    my @subjects = $self->subjects_from_node( $subjectset[0] );

    $object->vlesubjects( @subjects );

    #vlmeta
    my @metaset = $root->findnodes( "/book/bookinfo|/article/articleinfo" );

    my $meta = $self->meta_from_node( $metaset[0] );
    $meta->subtitle( $self->_trim(
           $self->_nodevalue($root->findnodes( '/book/bookinfo/subtitle|/article/articleinfo/subtitle' ))));

    $object->vlemeta( $meta );

    #vlpublication
    my @issuenumnode = $root->findnodes( "/article/articleinfo/biblioset|/book/bookinfo/biblioset");
    if ( @issuenumnode ) {
        my ($journal, $volume);
        if ( $journal = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("title") ) ) ) {
            $volume = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("issuenum") ) );
            #$isbn = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("isbn") ) ) or "";
            #$issn = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("issn") ) ) or "";

            if ( $journal ) {
                my $vlpublication = $self->vlpublication( $self->_trim($journal), $self->_trim($volume) );
                $object->vlepublications( ($vlpublication) );
            }
        }

    map { $_->unbindNode() } $root->findnodes( "/book/bookinfo|/article/articleinfo" );

        if ( $root->findnodes('/book') ){
            $object->body( ($root->findnodes('/book'))[0]->toString(0,1) );
        }
        elsif ($root->findnodes('/article')) {
            $object->body( ($root->findnodes('/article'))[0]->toString(0,1) );
        }

        return $object->update();
    }
}


sub _nodevalue {
    my $self = shift;
    my $node = shift;

    if ( defined $node ) {
        my $value = "";
        if ( $node->hasChildNodes() ) {
            map { $value .= $_->toString(0,1) } $node->childNodes;
        }
        else {
            $value = $node->textContent();
        }
        if ( length $value ) {
#            $value = XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$value) : $value;
            return $value;
        }
    }
}


sub _trim {
    my $self = shift;
    my $string = shift;

    return undef unless $string;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}


sub _unquot {
    my $self = shift;
    my $string = shift;

    return undef unless $string;

    $string =~ s/&apos;/'/g;
    $string =~ s/&quot;/"/g;

    return $string;
}


sub _escapewildcard {
    my $self = shift;
    my $string = shift;

    return undef unless $string;
    $string =~ s/%/%%/g;

    return $string;
}


sub authors_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $authorset = shift;
    my @authors;

    return () unless $authorset;

    foreach my $author ( $authorset->getChildrenByTagName("author") ) {
        my $lastname = $self->_unquot( $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("surname") ) ) );
        my $middlename = $self->_unquot( $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("othername") ) ) );
        my $firstname = $self->_unquot( $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("firstname") ) ) );
        $middlename ||= '';
        $firstname ||= '';
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => $self->_escapewildcard( $lastname ),
                                                middlename => $middlename,
                                                firstname => $firstname);
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->middlename( $middlename );
            $vlibauthor->firstname( $firstname );
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "could not create VLibauthor $lastname" );
                next;
            }
        }
        push(@authors, $vlibauthor);
    }

    foreach my $author ( $authorset->getChildrenByTagName("corpauthor") ) {
        my $lastname = $self->_unquot( $self->_trim( $self->_nodevalue( $author ) ) );
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => $self->_escapewildcard( $lastname ),
                                                object_type => '1' );
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->object_type( '1' );
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "could not create VLibauthor $lastname" );
                next;
            }
        }
        push(@authors, $vlibauthor);
    }

    return @authors;
}


sub keywords_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $keywordset = shift;
    my @keywords;

    return () unless $keywordset;

    foreach my $keyword ( $keywordset->getChildrenByTagName("keyword") ) {
        $keywordvalue = $self->_nodevalue( $keyword );
        my $vlibkeyword = XIMS::VLibKeyword->new( name => $keywordvalue );
        if ( not (defined $vlibkeyword and $vlibkeyword->id) ) {
            $vlibkeyword = XIMS::VLibKeyword->new();
            $vlibkeyword->name( $keywordvalue );
            if ( not $vlibkeyword->create() ) {
                XIMS::Debug( 3, "could not create VLibKeyword $keywordvalue" );
                next;
            }
        }
        push(@keywords, $vlibkeyword);
    }

    return @keywords;
}


sub subjects_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $subjectset = shift;
    my @subjects;

    return () unless $subjectset;

    foreach my $subject ( $subjectset->findnodes("subject/subjectterm") ) {

        $subjectvalue = $self->_nodevalue( $subject );
        my $vlibsubject = XIMS::VLibSubject->new( name => $subjectvalue );
        if ( not (defined $vlibsubject and $vlibsubject->id) ) {
            $vlibsubject = XIMS::VLibSubject->new();
            $vlibsubject->name( $subjectvalue );
            if ( not $vlibsubject->create() ) {
                XIMS::Debug( 3, "could not create VLibSubject $subjectvalue" );
                next;
            }
        }
        push(@subjects, $vlibsubject);
    }

    return @subjects;
}


sub meta_from_node {
    XIMS::Debug( 5, "called" );

    my $self = shift;
    my $metaset = shift;
    my $meta = XIMS::VLibMeta->new();
    return undef unless $metaset;

    # legalnotice
    my $legalnotice = $self->_trim(
      $self->_nodevalue( $metaset->findnodes('//legalnotice/simpara|//legalnotice/para')));
    $meta->legalnotice( $legalnotice ) if length( $legalnotice );

    # mediatype
    $meta->mediatype( $self->_trim( $self->_nodevalue( $metaset->findnodes('biblioset/@relation'))));

    # bibliosource
    my @bibliosourceset = $metaset->getChildrenByTagName("biblioset");
    my $bibliosource;
    if ( $bibliosourceset[0] ) {
        map { $bibliosource .= $self->_nodevalue($_) }
          ($bibliosourceset[0]->getChildrenByTagName('bibliosource'));
        $meta->bibliosource( $self->_trim( $bibliosource ) );
    }

    return $meta;
}


sub vlpublication {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $name = shift;
    my $volume = shift;
    #my $isbn = shift;
    #my $issn = shift;

    return undef unless $name;

    my $vlpublication = XIMS::VLibPublication->new( name => $name, volume => $volume );
    if ( not (defined $vlpublication and $vlpublication->id) ) {
        $vlpublication = XIMS::VLibPublication->new();
        $vlpublication->name( $name );
        $vlpublication->volume( $volume );
        #$vlpublication->volume( $isbn );
        #$vlpublication->volume( $issn );
        if ( not $vlpublication->create() ) {
            XIMS::Debug( 3, "could not create VLibPublication $name" );
        }
    }

    return $vlpublication;
}

1;
