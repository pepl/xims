
=head1 NAME

XIMS::Importer::Object::VLibraryItem::DocBookXML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::Object::VLibraryItem::DocBookXML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::Object::VLibraryItem::DocBookXML;

use common::sense;
use parent qw(XIMS::Importer::Object::XML);
use XIMS::VLibAuthor;
use XIMS::VLibKeyword;
use XIMS::VLibSubject;
use XIMS::VLibPublication;
use XIMS::VLibMeta;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 import()

=cut

sub import {
    XIMS::Debug(5, "called");

    my $self = shift;
    my $object = shift;
    my $updateexisting = shift;
    return unless $object;

    my $body = $object->body();
    return unless $body;

    my $root = $self->get_rootelement( \$body, nochunk => 1 );
    return unless $root;

    # hmmm, this is a rather subtle way to check and decode the body if it has not already been decoded upstream
    my $decbody = $root->toString();
    $object->body( $decbody ) if defined $decbody and length $decbody;

    my $id = $self->SUPER::import( $object, $updateexisting );

    $self->vlproperties_from_document( $root, $object );

    return $id;
}

=head2 vlproperties_from_document()

=cut

sub vlproperties_from_document {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $root = shift;
    my $object = shift;

    #title
    $object->title( XIMS::clean(
      XIMS::nodevalue($root->findnodes( "/article/articleinfo/title|/book/bookinfo/title|/book/title" ) )));

    #abstract
    my $abstract = XIMS::clean( XIMS::nodevalue($root->findnodes('/book/bookinfo/abstract/simpara|/article/articleinfo/abstract/simpara') ) );
    $object->abstract( $abstract ) if defined $abstract;

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
    if ( defined $meta ) {
        $meta->subtitle( XIMS::clean(
               XIMS::nodevalue($root->findnodes( '/book/bookinfo/subtitle|/article/articleinfo/subtitle' ))));

        $object->vlemeta( $meta );
    }

    #vlpublication
    my @issuenumnode = $root->findnodes( "/article/articleinfo/biblioset|/book/bookinfo/biblioset");
    if ( @issuenumnode ) {
        my ($journal, $volume);
        if ( $journal = XIMS::clean( XIMS::nodevalue( $issuenumnode[0]->getChildrenByTagName("title") ) ) ) {
            $volume = XIMS::clean( XIMS::nodevalue( $issuenumnode[0]->getChildrenByTagName("issuenum") ) );
            #$isbn = $self->_trim( XIMS::nodevalue( $issuenumnode[0]->getChildrenByTagName("isbn") ) ) or "";
            #$issn = $self->_trim( XIMS::nodevalue( $issuenumnode[0]->getChildrenByTagName("issn") ) ) or "";

            if ( $journal ) {
                my $vlpublication = $self->vlpublication( $journal, $volume );
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

=head2 authors_from_node()

=cut

sub authors_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $authorset = shift;
    my @authors;

    return () unless $authorset;

    foreach my $author ( $authorset->getChildrenByTagName("author") ) {
        my $lastname = XIMS::clean( XIMS::nodevalue( $author->getChildrenByTagName("surname") ) );
        my $middlename = XIMS::clean( XIMS::nodevalue( $author->getChildrenByTagName("othername") ) );
        my $firstname = XIMS::clean( XIMS::nodevalue( $author->getChildrenByTagName("firstname") ) );
        $middlename ||= '';
        $firstname ||= '';
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => XIMS::escapewildcard( $lastname ),
                                                middlename => $middlename,
                                                firstname => $firstname,
                                                document_id => $self->{Parent}->document_id() );
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->middlename( $middlename );
            $vlibauthor->firstname( $firstname );
            $vlibauthor->document_id ( $self->{Parent}->document_id() );
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "could not create VLibauthor $lastname" );
                next;
            }
        }
        push(@authors, $vlibauthor);
    }

    foreach my $author ( $authorset->getChildrenByTagName("corpauthor") ) {
        my $lastname = XIMS::clean( XIMS::nodevalue( $author ) );
        my $vlibauthor = XIMS::VLibAuthor->new( lastname => XIMS::escapewildcard( $lastname ),
                                                object_type => '1',
                                                document_id => $self->{Parent}->document_id() );
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->object_type( '1' );
            $vlibauthor->document_id ( $self->{Parent}->document_id() );
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "could not create VLibauthor $lastname" );
                next;
            }
        }
        push(@authors, $vlibauthor);
    }

    return @authors;
}

=head2 keywords_from_node()

=cut

sub keywords_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $keywordset = shift;
    my @keywords;

    return () unless $keywordset;

    foreach my $keyword ( $keywordset->getChildrenByTagName("keyword") ) {
        my $keywordvalue = XIMS::clean( XIMS::nodevalue( $keyword ) );
        my $vlibkeyword = XIMS::VLibKeyword->new( name => $keywordvalue,
                                                  document_id => $self->{Parent}->document_id() );
        if ( not (defined $vlibkeyword and $vlibkeyword->id) ) {
            $vlibkeyword = XIMS::VLibKeyword->new();
            $vlibkeyword->name( $keywordvalue );
            $vlibkeyword->document_id ( $self->{Parent}->document_id() );
            if ( not $vlibkeyword->create() ) {
                XIMS::Debug( 3, "could not create VLibKeyword $keywordvalue" );
                next;
            }
        }
        push(@keywords, $vlibkeyword);
    }

    return @keywords;
}

=head2 subjects_from_node()

=cut

sub subjects_from_node {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $subjectset = shift;
    my @subjects;

    return () unless $subjectset;

    foreach my $subject ( $subjectset->findnodes("subject/subjectterm") ) {
        my $subjectvalue = XIMS::clean( XIMS::nodevalue( $subject ) );
        my $vlibsubject = XIMS::VLibSubject->new( name => $subjectvalue, document_id => $self->{Parent}->document_id() );
        if ( not (defined $vlibsubject and $vlibsubject->id) ) {
            $vlibsubject = XIMS::VLibSubject->new();
            $vlibsubject->name( $subjectvalue );
            $vlibsubject->document_id( $self->{Parent}->document_id() );
            if ( not $vlibsubject->create() ) {
                XIMS::Debug( 3, "could not create VLibSubject $subjectvalue" );
                next;
            }
        }
        push(@subjects, $vlibsubject);
    }

    return @subjects;
}

=head2 meta_from_node()

=cut

sub meta_from_node {
    XIMS::Debug( 5, "called" );

    my $self = shift;
    my $metaset = shift;
    my $meta = XIMS::VLibMeta->new();
    return unless $metaset;

    # legalnotice
    my $legalnotice = XIMS::clean(
        XIMS::nodevalue( $metaset->findnodes('//legalnotice/simpara|//legalnotice/para')));
    $meta->legalnotice( $legalnotice ) if length( $legalnotice );

    # mediatype
    $meta->mediatype( XIMS::clean( XIMS::nodevalue( $metaset->findnodes('biblioset/@relation'))));

    # bibliosource
    my @bibliosourceset = $metaset->getChildrenByTagName("biblioset");
    my $bibliosource;
    if ( $bibliosourceset[0] ) {
        map { $bibliosource .= XIMS::nodevalue($_) }
            ($bibliosourceset[0]->getChildrenByTagName('bibliosource'));
        $meta->bibliosource( XIMS::clean( $bibliosource ) );
    }

    return $meta;
}

=head2 vlpublication()

=cut

sub vlpublication {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $name = shift;
    my $volume = shift;
    #my $isbn = shift;
    #my $issn = shift;

    return unless $name;

    my $vlpublication = XIMS::VLibPublication->new( name => $name,
                                                    volume => $volume,
                                                    document_id => $self->{Parent}->document_id());
    if ( not (defined $vlpublication and $vlpublication->id) ) {
        $vlpublication = XIMS::VLibPublication->new();
        $vlpublication->name( $name );
        $vlpublication->volume( $volume );
        #$vlpublication->volume( $isbn );
        #$vlpublication->volume( $issn );
        $vlpublication->document_id( $self->{Parent}->document_id() );
        if ( not $vlpublication->create() ) {
            XIMS::Debug( 3, "could not create VLibPublication $name" );
        }
    }

    return $vlpublication;
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

Copyright (c) 2002-2013 The XIMS Project.

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

