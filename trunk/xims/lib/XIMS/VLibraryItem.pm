# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibraryItem;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::Object;
use XIMS::DataFormat;
use XIMS::VLibrary;
use XIMS::VLibAuthor;
use XIMS::VLibAuthorMap;
use XIMS::VLibKeyword;
use XIMS::VLibKeywordMap;
use XIMS::VLibSubject;
use XIMS::VLibSubjectMap;
use XIMS::VLibPublication;
use XIMS::VLibPublicationMap;
use XIMS::VLibMeta;


$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Object');

use Class::MethodMaker
        list       => [ qw(vlkeywords vlsubjects vlpublications) ];

use Data::Dumper;

##
#
# SYNOPSIS
#    XIMS::VLibraryItem->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $dept: XIMS::VLibraryItem instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'VLibraryItem' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

sub vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @authors = @_;

    return undef unless $self->document_id();

    if ( not (@authors and scalar @authors > 0) ) {
        # think of doing join here instead of two queries
        my @author_ids = $self->data_provider->getVLibAuthorMap( document_id => $self->document_id(), properties => [qw(author_id)] );
        @author_ids = map { $_->{'vlibauthormap.author_id'} } @author_ids;
        return undef unless scalar @author_ids;
        my @authors_data = $self->data_provider->getVLibAuthor( id => \@author_ids );
        @authors = map { XIMS::VLibAuthor->new->data( %{$_} ) } @authors_data;
        #warn "authors" . Dumper( \@authors ) . "\n";
        return wantarray ? @authors : $authors[0];
    }
    else {
        my $retval;
        my $authormap;
        foreach my $author ( @authors ) {
            next unless defined $author and ref $author and $author->isa( 'XIMS::VLibAuthor' );
            $authormap = XIMS::VLibAuthorMap->new( document_id => $self->document_id(), author_id => $author->id() );
            if ( not defined $authormap ) {
                $authormap = XIMS::VLibAuthorMap->new();
                $authormap->document_id( $self->document_id() );
                $authormap->author_id( $author->id() );
                my $id = $authormap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created authormap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create authormap for author " . $author->lastname() );
                }
            }
        }
        return $retval;
    }
}

sub vlekeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @keywords = @_;

    return undef unless $self->document_id();

    if ( not (@keywords and scalar @keywords > 0) ) {
        # think of doing join here instead of two queries
        my @keyword_ids = $self->data_provider->getVLibKeywordMap( document_id => $self->document_id(), properties => [qw(keyword_id)] );
        @keyword_ids = map { $_->{'vlibkeywordmap.keyword_id'} } @keyword_ids;
        return undef unless @keyword_ids and scalar @keyword_ids;
        my @keywords_data = $self->data_provider->getVLibKeyword( id => \@keyword_ids );
        @keywords = map { XIMS::VLibKeyword->new->data( %{$_} ) } @keywords_data;
        #warn "keywords" . Dumper( \@keywords ) . "\n";
        return wantarray ? @keywords : $keywords[0];
    }
    else {
        my $retval;
        my $keywordmap;
        foreach my $keyword ( @keywords ) {
            next unless defined $keyword;
            if ( not (ref $keyword and $keyword->isa( 'XIMS::VLibKeyword' )) ) {
                $keyword = XIMS::VLibKeyword->new( name => $keyword );
                next unless defined $keyword;
            }
            $keywordmap = XIMS::VLibKeywordMap->new( document_id => $self->document_id(), keyword_id => $keyword->id() );
            if ( not defined $keywordmap ) {
                $keywordmap = XIMS::VLibKeywordMap->new();
                $keywordmap->document_id( $self->document_id() );
                $keywordmap->keyword_id( $keyword->id() );
                my $id = $keywordmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created keywordmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create keywordmap for keyword " . $keyword->lastname() );
                }
            }
        }
        return $retval;
    }
}

sub vlesubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @subjects = @_;

    return undef unless $self->document_id();

    if ( not (@subjects and scalar @subjects > 0) ) {
        # think of doing join here instead of two queries
        my @subject_ids = $self->data_provider->getVLibSubjectMap( document_id => $self->document_id(), properties => [qw(subject_id)] );
        @subject_ids = map { $_->{'vlibsubjectmap.subject_id'} } @subject_ids;
        return undef unless scalar @subject_ids;
        my @subjects_data = $self->data_provider->getVLibSubject( id => \@subject_ids );
        @subjects = map { XIMS::VLibSubject->new->data( %{$_} ) } @subjects_data;
        #warn "subjects" . Dumper( \@subjects ) . "\n";
        return wantarray ? @subjects : $subjects[0];
    }
    else {
        my $retval;
        my $subjectmap;
        foreach my $subject ( @subjects ) {
            next unless defined $subject;
            if ( not (ref $subject and $subject->isa( 'XIMS::VLibSubject' )) ) {
                $subject = XIMS::VLibSubject->new( name => $subject );
                next unless defined $subject;
            }
            $subjectmap = XIMS::VLibSubjectMap->new( document_id => $self->document_id(), subject_id => $subject->id() );
            if ( not defined $subjectmap ) {
                $subjectmap = XIMS::VLibSubjectMap->new();
                $subjectmap->document_id( $self->document_id() );
                $subjectmap->subject_id( $subject->id() );
                my $id = $subjectmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created subjectmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create subjectmap for subject " . $subject->lastname() );
                }
            }
        }
        return $retval;
    }
}

sub vlepublications {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @publications = @_;

    return undef unless $self->document_id();

    if ( not (@publications and scalar @publications > 0) ) {
        # think of doing join here instead of two queries
        my @publication_ids = $self->data_provider->getVLibPublicationMap( document_id => $self->document_id(), properties => [qw(publication_id)] );
        @publication_ids = map { $_->{'vlibpublicationmap.publication_id'} } @publication_ids;
        return undef unless scalar @publication_ids;
        my @publications_data = $self->data_provider->getVLibPublication( id => \@publication_ids );
        @publications = map { XIMS::VLibPublication->new->data( %{$_} ) } @publications_data;
        #warn "publications" . Dumper( \@publications ) . "\n";
        return wantarray ? @publications : $publications[0];
    }
    else {
        my $retval;
        my $publicationmap;
        foreach my $publication ( @publications ) {
            next unless defined $publication and ref $publication and $publication->isa( 'XIMS::VLibPublication' );
            $publicationmap = XIMS::VLibPublicationMap->new( document_id => $self->document_id(), publication_id => $publication->id() );
            if ( not defined $publicationmap ) {
                $publicationmap = XIMS::VLibPublicationMap->new();
                $publicationmap->document_id( $self->document_id() );
                $publicationmap->publication_id( $publication->id() );
                my $id = $publicationmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created publicationmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create publicationmap for publication " . $publication->name() );
                }
            }
        }
        return $retval;
    }
}

sub vlemeta {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $meta = shift;

    return undef unless $self->document_id();

    if ( not $meta ) {
        return XIMS::VLibMeta->new( document_id => $self->document_id() );
    }
    else {
        next unless (defined $meta and ref $meta and $meta->isa( 'XIMS::VLibMeta' ));
        $meta->document_id( $self->document_id() );
        my $id = $meta->create();
        if ( defined $id ) {
            XIMS::Debug( 4, "successfully created meta with id $id" );
            return $id;
        }
        else {
            XIMS::Debug( 2, "could not create associate meta" );
            return undef;
        }
    }
}

sub _vleproperties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $property = shift;
    my @objects = @_;

    return undef unless $property;

    return undef unless $self->document_id();

    my $class = "XIMS::VLib$property";

    if ( not (@objects and scalar @objects > 0) ) {
        # think of doing join here instead of two queries
        my $method = "getVLib".$property."Map";
        my $propertyid = lc $property . "_id";
        my @object_ids = $self->data_provider->$method( document_id => $self->document_id(), properties => [($propertyid)] );
        my $key = lc ("vlib".$property."map.".$property."_id");
        @object_ids = map { $_->{$key} } @object_ids;
        return undef unless scalar @object_ids;
        $method = "getVlib".$property;
        my @objects_data = $self->data_provider->$method( id => \@object_ids );
        @objects = map { $class->new->data( %{$_} ) } @objects_data;
        #warn "objects" . Dumper( \@objects ) . "\n";
        return wantarray ? @objects : $objects[0];
    }
    else {
        my $retval;
        my $objectmap;
        my $mapclass= "$classMap";
        foreach my $object ( @objects ) {
            #
            # check if want to use author|publ logic here instead
            #next unless defined $object and ref $object and $object->isa( $class );
            next unless defined $object;
            if ( not (ref $object and $object->isa( $class )) ) {
                $object = $class->new( name => $object );
                next unless defined $object;
            }
            $objectmap = $mapclass->new( document_id => $self->document_id(), object_id => $object->id() );
            if ( not defined $objectmap ) {
                $objectmap = $mapclass->new();
                $objectmap->document_id( $self->document_id() );
                my $method = "$property_id";
                $objectmap->$method( $object->id() );
                my $id = $objectmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created objectmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create objectmap for object " . $object->id() );
                }
            }
        }
        return $retval;
    }
}

1;
