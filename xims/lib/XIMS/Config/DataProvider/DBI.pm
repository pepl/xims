# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config::DataProvider::DBI;

use strict;
use vars qw( $VERSION );

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub PropertyAttributes { (
    'content.id'                          => \'ci_content_id_seq_nval()',
    'user.id'                             => \'ci_users_roles_id_seq_nval()',
    'session.id'                          => \'ci_sessions_id_seq_nval()',
    'session.last_access_timestamp'       => \'now()',
    'document.id'                         => \'ci_documents_id_seq_nval()',
    'bookmark.id'                         => \'ci_bookmarks_id_seq_nval()',
    'language.id'                         => \'ci_languages_id_seq_nval()',
    'objecttype.id'                       => \'ci_object_types_id_seq_nval()',
    'dataformat.id'                       => \'ci_data_formats_id_seq_nval()',
    'mimetype.id'                         => \'ci_mime_aliases_id_seq_nval()',
    'questionnaireresult.id'              => \'ci_quest_results_id_seq_nval()',
    'vlibauthor.id'                       => \'cilib_authors_id_seq_nval()',
    'vlibauthormap.id'                    => \'cilib_authormap_id_seq_nval()',
    'vlibkeyword.id'                      => \'cilib_keywords_id_seq_nval()',
    'vlibkeywordmap.id'                   => \'cilib_keywordmap_id_seq_nval()',
    'vlibsubject.id'                      => \'cilib_subjects_id_seq_nval()',
    'vlibsubjectmap.id'                   => \'cilib_subjectmap_id_seq_nval()',
    'vlibpublication.id'                  => \'cilib_publications_id_seq_nval()',
    'vlibpublicationmap.id'               => \'cilib_publmap_id_seq_nval()',
    'vlibmeta.id'                         => \'cilib_meta_id_seq_nval()',
) }

sub PropertyRelations { (
    'Object' => { 'document.id' => \'ci_content.document_id' }
) }

sub Tables { (
            content        => 'ci_content',
            user           => 'ci_users_roles',
            session        => 'ci_sessions',
            document       => 'ci_documents',
            objecttype     => 'ci_object_types',
            userpriv       => 'ci_roles_granted',
            objectpriv     => 'ci_object_privs_granted',
            objecttypepriv => 'ci_object_type_privs',
            dataformat     => 'ci_data_formats',
            language       => 'ci_languages',
            mimetype       => 'ci_mime_type_aliases',
            bookmark       => 'ci_bookmarks',
            questionnaireresult => 'ci_questionnaire_results',
            vlibauthor          => 'cilib_authors',
            vlibauthormap       => 'cilib_authormap',
            vlibkeyword         => 'cilib_keywords',
            vlibkeywordmap      => 'cilib_keywordmap',
            vlibsubject         => 'cilib_subjects',
            vlibsubjectmap      => 'cilib_subjectmap',
            vlibpublication     => 'cilib_publications',
            vlibpublicationmap  => 'cilib_publicationmap',
            vlibmeta            => 'cilib_meta',
          ) }

1;
