# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config::Names;

use strict;
use vars qw( $VERSION );

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub ResourceTypes() { (
                   'Session',
                   'User',
                   'Document',
                   'Content',
                   'Object',
                   'ObjectType',
                   'UserPriv',
                   'Bookmark',
                   'DataFormat',
                   'Language',
                   'ObjectPriv',
                   'ObjectTypePriv',
                   'MimeType',
                   'QuestionnaireResult',
                   'VLibAuthor',
                   'VLibAuthorMap',
                   'VLibKeyword',
                   'VLibKeywordMap',
                   'VLibSubject',
                   'VLibSubjectMap',
                   'VLibPublication',
                   'VLibPublicationMap',
                   'VLibMeta'
                    )
}

sub Properties() { (
    Session => [
               'session.id',
               'session.session_id',
               'session.user_id',
               'session.attributes',
               'session.host',
               'session.last_access_timestamp',
               'session.salt'
             ],
    User =>   [
              'user.password',
              'user.enabled',
              'user.admin',
              'user.id',
              'user.system_privs_mask',
              'user.name',
              'user.lastname',
              'user.middlename',
              'user.firstname',
              'user.email',
              'user.url',
              'user.object_type'
             ],
    Content => [
              'content.binfile',
              'content.last_modification_timestamp',
              'content.notes',
              'content.marked_new',
              'content.id',
              'content.locked_time',
              'content.abstract',
              'content.body',
              'content.title',
              'content.keywords',
              'content.status',
              'content.creation_timestamp',
              'content.attributes',
              'content.locked_by_id',
              'content.style_id',
              'content.script_id',
              'content.language_id',
              'content.last_modified_by_id',
              'content.owned_by_id',
              'content.created_by_id',
              'content.css_id',
              'content.image_id',
              'content.document_id',
              'content.published',
              'content.last_publication_timestamp',
              'content.last_published_by_id',
              'content.marked_deleted',
              'content.locked_by_lastname',
              'content.locked_by_middlename',
              'content.locked_by_firstname',
              'content.last_modified_by_lastname',
              'content.last_modified_by_middlename',
              'content.last_modified_by_firstname',
              'content.owned_by_lastname',
              'content.owned_by_middlename',
              'content.owned_by_firstname',
              'content.created_by_lastname',
              'content.created_by_middlename',
              'content.created_by_firstname',
              'content.last_published_by_lastname',
              'content.last_published_by_middlename',
              'content.last_published_by_firstname',
              'content.data_format_name',
              'content.schema_id'
             ],
    Document =>
             [
              'document.location',
              'document.status',
              'document.id',
              'document.parent_id',
              'document.object_type_id',
              'document.department_id',
              'document.data_format_id',
              'document.symname_to_doc_id',
              'document.position'
             ],
    ObjectType =>
             [
              'objecttype.id',
              'objecttype.name',
              'objecttype.is_fs_container',
              'objecttype.is_xims_data',
              'objecttype.redir_to_self',
              'objecttype.publish_gopublic',
              'objecttype.parent_id',
              'objecttype.is_objectroot'
             ],
    Bookmark =>
             [
              'bookmark.id',
              'bookmark.content_id',
              'bookmark.owner_id',
              'bookmark.stdhome'
             ],
    DataFormat =>
             [
              'dataformat.mime_type',
              'dataformat.id',
              'dataformat.name',
              'dataformat.suffix'
             ],
    Language =>
             [
              'language.id',
              'language.code',
              'language.fullname'
             ],
    UserPriv =>
             [
              'userpriv.id',
              'userpriv.grantor_id',
              'userpriv.grantee_id',
              'userpriv.role_master',
              'userpriv.default_role'
             ],
    ObjectPriv =>
             [
              'objectpriv.privilege_mask',
              'objectpriv.grantor_id',
              'objectpriv.grantee_id',
              'objectpriv.content_id'
             ],
    ObjectTypePriv =>
             [
              'objecttypepriv.grantor_id',
              'objecttypepriv.grantee_id',
              'objecttypepriv.object_type_id',
              'objecttypepriv.userselection'
             ],
    MimeType =>
             [
              'mimetype.id',
              'mimetype.data_format_id',
              'mimetype.mime_type'
             ],
    QuestionnaireResult =>
             [
              'questionnaireresult.document_id',
              'questionnaireresult.tan',
              'questionnaireresult.question_id',
              'questionnaireresult.answer',
              'questionnaireresult.answer_timestamp',
              'questionnaireresult.id'
             ],
    VLibAuthor =>
             [
              'vlibauthor.id',
              'vlibauthor.lastname',
              'vlibauthor.middlename',
              'vlibauthor.firstname',
              'vlibauthor.object_type',
             ],
    VLibAuthorMap =>
             [
              'vlibauthormap.id',
              'vlibauthormap.document_id',
              'vlibauthormap.author_id',
             ],
    VLibKeyword =>
             [
              'vlibkeyword.id',
              'vlibkeyword.name',
              'vlibkeyword.description',
             ],
    VLibKeywordMap =>
             [
              'vlibkeywordmap.id',
              'vlibkeywordmap.document_id',
              'vlibkeywordmap.keyword_id',
             ],
    VLibSubject =>
             [
              'vlibsubject.id',
              'vlibsubject.name',
              'vlibsubject.description',
             ],
    VLibSubjectMap =>
             [
              'vlibsubjectmap.id',
              'vlibsubjectmap.document_id',
              'vlibsubjectmap.subject_id',
             ],
    VLibPublication =>
             [
              'vlibpublication.id',
              'vlibpublication.name',
              'vlibpublication.isbn',
              'vlibpublication.issn',
              'vlibpublication.volume',
             ],
    VLibPublicationMap =>
             [
              'vlibpublicationmap.id',
              'vlibpublicationmap.document_id',
              'vlibpublicationmap.publication_id',
             ],
    VLibMeta =>
             [
              'vlibmeta.id',
              'vlibmeta.document_id',
              'vlibmeta.legalnotice',
              'vlibmeta.bibliosource',
              'vlibmeta.mediatype',
              'vlibmeta.subtitle',
             ],
) }


1;
