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
use Data::Dumper;
# for compatibility, to be removed later
use Text::Iconv;

use XIMS::Importer::Object::XML;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::Object::XML);

sub import {
    XIMS::Debug(5, "called");
    #warn Dumper (@_);
    my $self = shift;
    my $object = shift;
    my $updateexisting = shift;
    return undef unless $object;

    my $body = $object->body();
    return undef unless $body;
    #warn "ZEYA: ", $self->{Object}->document_id();
    my $root = $self->get_rootelement( \$body, nochunk => 1 );
    return undef unless $root;

    my $id = $self->SUPER::import( $object, $updateexisting );

    $self->vlproperties_from_document( $root, $object );

    return $id;
}

sub vlproperties_from_document {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;
    my $object = shift;
    #warn XIMS::Object->new()->document_id();
    #warn Dumper($self);
    #title
    $object->title( $self->_trim( $self->_nodevalue($root->findnodes( "/article/articleinfo/title|/book/bookinfo/title|/book/title" ) ) ) ); #/book/bookinfo/title|/book/title

    #abstract
    $object->abstract( ($root->getElementsByTagName("abstract"))[0]->firstChild->toString(0,1) ) if $root->getElementsByTagName("abstract");

    #vlauthors
    my @authorgroup = $root->findnodes( "/article/articleinfo/authorgroup|/book/bookinfo/authorgroup" ); #/book/bookinfo/authorgroup
    my @authors = $self->authors_from_node( $authorgroup[0] );

    # compatibility, to be removed later
    if ( scalar @authors < 1 ) {
        @authors = $self->__compatauthors( $root );
    }
    $object->vleauthors( @authors );

    #vlkeywords
    my @keywordset = $root->findnodes( "/article/articleinfo/keywordset|/book/bookinfo" ); #/book/bookinfo/
    my @keywords = $self->keywords_from_node( $keywordset[0] );

    # compatibility, to be removed later
    if ( scalar @keywords < 1 ) {
        @keywords = $self->__compatkeywords( $root );
    }

    $object->vlekeywords( @keywords );

    #vlsubjects
    my @subjectset = $root->findnodes( "/article/articleinfo/subjectset|/book/bookinfo" ); #/book/bookinfo/
    my @subjects = $self->subjects_from_node( $subjectset[0] );

    # compatibility, to be removed later
    if ( scalar @subjects < 1 ) {
        @subjects = $self->__compatsubjects( $root );
    }

    $object->vlesubjects( @subjects );

    #vlmeta
    my @metaset = $root->findnodes( "/article/articleinfo" ); # || $root->findnodes( "/book" );
    #warn Dumper(@metaset);
    my $meta = $self->meta_from_node( $metaset[0] );
    $meta->subtitle( $self->_trim( $self->_nodevalue( $root->findnodes( "/article/articleinfo/subtitle|/book/bookinfo/subtitle|/book/subtitle" ) ) ) ); #/book/bookinfo/subtitle|/book/subtitle

    # compatibility, to be removed later
    if ( not $meta->subtitle() ) {
        my ( $node ) = $root->findnodes( "/article/book/subtitle|/book/subtitle" );
        if ( defined $node ) {
            $meta->subtitle( $self->_trim( _decode( $node->textContent() ) ) );
            $node->unbindNode();
        }
    }

    # compatibility, to be removed later
    if ( not $meta->legalnotice() ) {
        my ( $node ) = $root->findnodes( "/article/book/copyright|/book/copyright" );
        if ( defined $node ) {
            $meta->legalnotice( $self->_trim( _decode( $node->textContent() ) ) );
        }
    }

    # compatibility, to be removed later
    if ( not $meta->bibliosource() ) {
        my ( $node ) = $root->findnodes( "/article/book/info|/book/info" );
        if ( defined $node ) {
            $meta->bibliosource( $self->_trim( $self->_nodevalue( $node ) ) );
        }
    }

    # compatibility, to be removed later
    if ( not $meta->mediatype() ) {
        my ( $node ) = $root->findnodes( "/article/book/mediatype" );
        if ( defined $node ) {
            $meta->mediatype( $self->_trim( _decode( $node->textContent() ) ) );
        }
    }

    $object->vlemeta( $meta );

    #vlpublication
    my @issuenumnode = $root->findnodes( "/article/articleinfo/issuenum|/book/bookinfo/biblioset");  # and /book/bookinfo/biblioset
    if ( @issuenumnode ) {
        my ($journal, $volume);
        # compat, in the future use title, isbn, issn and issuenum
        if ( $journal = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("journal") ) ) ) {
            $volume = $self->_trim( $self->_nodevalue( $issuenumnode[0]->getChildrenByTagName("issue") ) )
        }
        # for older Bidok export style compatibility...can be removed later
        # compatibility, to be removed later
        else {
            my $issuenum = $self->_nodevalue( $issuenumnode[0] );
            if ( $issuenum ) {
                ($journal, $volume) = split(';', $issuenum );
            }
        }
        if ( $journal ) {
            my $vlpublication = $self->vlpublication( $self->_trim($journal), $self->_trim($volume) );
            $object->vlepublications( ($vlpublication) );
        }
    }

    # compatibility, to be removed later
    if ( not $object->vlepublications() ) {
        my ( $node ) = $root->findnodes( "/article/book/journal" );
        my $journal = $self->_trim( _decode( $node->textContent() ) ) if $node;
        if ( $journal ) {
            my ( $volumenode ) = $root->findnodes( "/article/book/issue" );
            my $volume = $self->_trim( _decode( $volumenode->textContent() ) ) if $volumenode;
            my $vlpublication = $self->vlpublication( $self->_trim($journal), $self->_trim($volume) );
            $object->vlepublications( ($vlpublication) );
        }
    }

    # compatibility, to be removed later
    # update body after /article/book/* has been stripped
    map { $_->unbindNode() } $root->findnodes( "/article/book/abstract|/book/abstract" );
    map { $_->unbindNode() } $root->findnodes( "/article/book/author|/book/author");
    map { $_->unbindNode() } $root->findnodes( "/article/book/info|/book/info" );
    map { $_->unbindNode() } $root->findnodes( "/article/book/copyright|/book/copyright" );
    map { $_->unbindNode() } $root->findnodes( "/article/book/mediatype|/book/mediatype" );
    map { $_->unbindNode() } $root->findnodes( "/article/book/keywords|/book/keywords" );
    map { $_->unbindNode() } $root->findnodes( "/article/book/subjects|/book/subjects" );
    map { $_->unbindNode() } ( $root->findnodes( "/article/book/issue|/book/issue|/article/book/journal|/book/journal" ) );

    $object->body( ($root->getElementsByTagName("book"))[0]->toString(0,1) ) if $root->getElementsByTagName("book");

    return $object->update();
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
        my $lastname = $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("surname") ) );
        my $middlename = $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("middlename") ) ); # "othername" -> /book/bookinfo/authrogroup/author/othername
        my $firstname = $self->_trim( $self->_nodevalue( $author->getChildrenByTagName("firstname") ) );
        $middlename ||= '';
        $firstname ||= '';
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => $self->_escapewildcard( $lastname ), middlename => $middlename, firstname => $firstname);
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
        my $lastname = $self->_trim( $self->_nodevalue( $author ) );
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => $self->_escapewildcard( $lastname ), object_type => '1' );
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

    foreach my $subject ( $subjectset->getChildrenByTagName("subject") ) {
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

    # legalnotice, compat, in the future use "legalnotice"
    my $year = $self->_trim( $self->_nodevalue( $metaset->getElementsByTagName("year") ) );
    my $holder = $self->_trim( $self->_nodevalue( $metaset->getElementsByTagName("holder") ) );
    my $legalnotice;
    $legalnotice = "$year" if $year;
    $legalnotice .= " $holder" if $holder;
    $meta->legalnotice( $legalnotice );

    # mediatype
    $meta->mediatype( $self->_trim( $self->_nodevalue( $metaset->getChildrenByTagName("mediatype") ) ) ); # compat, in the future use "biblioset[@relation]"

    # bibliosource
    my @bibliosourceset = $metaset->getChildrenByTagName("releaseinfo"); # compat, in the future use "/book/bookinfo/biblioset/bibliosource"
    my $bibliosource;
    if ( $bibliosourceset[0] ) {
        map { $bibliosource .= $_->toString(0,1) } $bibliosourceset[0]->childNodes();
        $meta->bibliosource( $self->_trim( $bibliosource ) );
    }

    return $meta;
}

sub vlpublication {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $name = shift;
    my $volume = shift;

    return undef unless $name;

    my $vlpublication = XIMS::VLibPublication->new( name => $name, volume => $volume );
    if ( not (defined $vlpublication and $vlpublication->id) ) {
        $vlpublication = XIMS::VLibPublication->new();
        $vlpublication->name( $name );
        $vlpublication->volume( $volume );
        if ( not $vlpublication->create() ) {
            XIMS::Debug( 3, "could not create VLibPublication $name" );
        }
    }

    return $vlpublication;
}

sub __compatauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;

    my @vlibauthors;

    my ( $na ) = $root->findnodes( "/article/book/author|/article/book/institution" );
    if ( defined $na ) {
        my @authors = split(",", $self->_trim( _decode( $na->textContent() ) ) );
        my ( $firstname, $lastname, $middlename );
        my $object_type;
        foreach my $a ( @authors ) {
            if ( $na->nodeName() eq "author" ) {
                $a =~ s/^\s*|\s*$//g;
                # von|vom|zu are part of the firstname
                ( $firstname, $lastname ) = ( $a =~ /^([^ ]+) (.+)$/ );
            }
            else {
                my $lastname = $self->_trim( $self->_nodevalue( $na ) );
                $object_type = 1;
            }

            $middlename = '';
            $firstname ||= '';

            my %param = ( lastname => $self->_escapewildcard( $lastname ), middlename => $middlename, firstname => $firstname );
            $param{object_type} = 1 if $object_type;
            my $vlibauthor = XIMS::VLibAuthor->new( %param );
            if ( not (defined $vlibauthor and $vlibauthor->id) ) {
                $vlibauthor = XIMS::VLibAuthor->new();
                $vlibauthor->lastname( $lastname );
                $vlibauthor->middlename( $middlename );
                $vlibauthor->firstname( $firstname );
                $vlibauthor->object_type( 1 ) if $object_type;
                if ( not $vlibauthor->create() ) {
                    XIMS::Debug( 3, "could not create VLibauthor $lastname" );
                    next;
                }
            }
            push(@vlibauthors, $vlibauthor);
        }
    }

    return @vlibauthors;
}

sub __compatkeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;

    my @vlibkeywords;

    my ( $na ) = $root->findnodes( "/article/book/keywords" );
    if ( defined $na ) {
        my @keywords = split(",", $self->_trim( _decode( $na->textContent() ) ) );

        foreach my $keywordvalue ( @keywords ) {
            my $vlibkeyword = XIMS::VLibKeyword->new( name => $keywordvalue );
            if ( not (defined $vlibkeyword and $vlibkeyword->id) ) {
                $vlibkeyword = XIMS::VLibKeyword->new();
                $vlibkeyword->name( $keywordvalue );
                if ( not $vlibkeyword->create() ) {
                    XIMS::Debug( 3, "could not create VLibKeyword $keywordvalue" );
                    next;
                }
            }
            push(@vlibkeywords, $vlibkeyword);
        }
    }

    return @vlibkeywords;
}

sub __compatsubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;

    my @vlibsubjects;

    my ( $na ) = $root->findnodes( "/article/book/subjects" );
    if ( defined $na ) {
        my @subjects = split(",", $self->_trim( _decode( $na->textContent() ) ) );

        foreach my $subjectvalue ( @subjects ) {
            my $vlibsubject = XIMS::VLibSubject->new( name => $subjectvalue );
            if ( not (defined $vlibsubject and $vlibsubject->id) ) {
                $vlibsubject = XIMS::VLibSubject->new();
                $vlibsubject->name( $subjectvalue );
                if ( not $vlibsubject->create() ) {
                    XIMS::Debug( 3, "could not create VLibSubject $subjectvalue" );
                    next;
                }
            }
            push(@vlibsubjects, $vlibsubject);
        }
    }

    return @vlibsubjects;
}

sub _encode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( XIMS::DBENCODING(), "UTF-8" );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

sub _decode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( "UTF-8", XIMS::DBENCODING() );
    $string = $converter->convert($string) if defined $string;
    return $string;
}


1;
