-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- assume that this data is LATIN1 encoded
-- ans let psql translate it to whatever the database itself is set to
-- (which should be UNICODE)

SET SESSION AUTHORIZATION 'xims';
SET CLIENT_ENCODING TO 'LATIN1';

\echo inserting into ci_languages...

INSERT INTO ci_languages ( id, fullname, code )
       VALUES ( nextval('ci_languages_id_seq'), 'English (US)', 'en-us' );
INSERT INTO ci_languages ( id, fullname, code )
       VALUES ( nextval('ci_languages_id_seq'), 'Deutsch (Österreich)', 'de-at' );

\echo inserting into ci_object_types...
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Folder', 1, 1, 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Document', 0, 1, 1, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Image', 0, 0, 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'File', 0, 0, 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'XML', 0, 1, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'DepartmentRoot', 1, 1, 0, 0, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'XSLStylesheet', 0, 0, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'AxPointPresentation', 0, 0, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'sDocBookXML', 0, 0, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'XSPScript', 0, 0, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'URLLink', 0, 1, 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'SymbolicLink', 0, 1, 0, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'NewsItem', 0, 1, 1, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Annotation', 0, 0, 0, 0, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Portlet', 0, 1, 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Portal', 0, 0, 1, 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'SiteRoot', 1, 1, 0, 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Text', 0, 1, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'CSS', 0, 1, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Questionnaire', 0, 0, 1, 1, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'TAN_List', 0, 0, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibrary', 1, 1, 1, 1, 1, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibraryItem', 0, 1, 1, 0, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'DocBookXML', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'URLLink', 0, 1, 0, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Document', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'NewsItem', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );       
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'DocBookXML', 0, 0, 1, 0, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'JavaScript', 0, 1, 1, 0, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'SQLReport', 0, 1, 1, 2 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Event', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_mailable, menu_level ) 
       VALUES ( nextval('ci_object_types_id_seq'), 'NewsLetter', 0, 1, 1, 0, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'Gallery', 1, 1, 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_mailable, menu_level, is_davgetable, davprivval )
       VALUES ( nextval('ci_object_types_id_seq'), 'Markdown', 0, 1, 1, 0, 1, 2, 1, 2 );

\echo inserting into ci_data_formats...

INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Text', 'text/plain', 'txt' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'HTML', 'text/html', 'html' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'XSLT', 'text/xml', 'xsl' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'XML', 'text/xml', 'xml' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'CSS', 'text/css', 'css' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'XPS', 'text/x-xpathscript', 'xps' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'JPEG', 'image/jpeg', 'jpg' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'TIFF', 'image/tiff', 'tif' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'GIF', 'image/gif', 'gif' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PDF', 'application/pdf', 'pdf' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DOC', 'application/vnd.ms-word', 'doc' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPT', 'application/vnd.ms-powerpoint', 'ppt' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'XLS', 'application/vnd.ms-excel', 'xls' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Binary', 'application/octet-stream', 'exe' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PNG', 'image/png', 'png' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'ZIP', 'application/x-zip-compressed', 'zip' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'TAR', 'application/x-tar', 'tar' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Container', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Gallery', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PJPEG', 'image/pjpeg', 'jpg' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'AXPML', 'text/xml', 'axp' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'sDocBookXML', 'text/xml', 'sdbk' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'URL', 'text/plain', 'url' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'SymbolicLink', 'text/plain' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'GNU-Zip', 'application/x-gzip','gz' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'BZip', 'application/x-bzip2','bz2' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'XSP', 'text/xml', 'xsp');
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'ECMA', 'text/javascript','js' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Portlet', 'text/xml', 'ptlt' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DepartmentRoot', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'SiteRoot', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Postscript', 'application/postscript', 'ps' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Questionnaire', 'text/xml' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'TAN_List', 'text/plain', 'tls' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Icon', 'image/x-icon', 'ico' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPZ', 'application/vnd.ms-powerpoint', 'ppz' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'POT', 'application/vnd.ms-powerpoint', 'pot' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPS', 'application/vnd.ms-powerpoint', 'pps' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'VLibrary', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DocBookXML', 'text/xml', 'dbk' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MP3', 'audio/mpeg', 'mp3' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'M4A', 'audio/x-m4a', 'm4a' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MP4', 'video/mp4', 'mp4' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'M4V', 'video/x-m4v', 'm4v' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MOV', 'video/quicktime', 'mov' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'ODT', 'application/vnd.oasis.opendocument.text', 'odt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'ODS', 'application/vnd.oasis.opendocument.spreadsheet', 'ods' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'ODP', 'application/vnd.oasis.opendocument.presentation', 'odp' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'DOCX', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'docx' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'XLSX', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'xlsx' );  
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'SLDX', 'application/vnd.openxmlformats-officedocument.presentationml.slide', 'sldx' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPTX', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'pptx' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'Markdown', 'text/x-markdown', 'md' );


\echo inserting into ci_mime_type_aliases...

INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 11, 'application/msword' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 12, 'application/ppt' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 13, 'application/msexcel' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 13, 'application/x-msexcel' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 13, 'application/x-mspowerpoint' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 15, 'image/x-png' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 14, 'application/x-msdos-program' );
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 16, 'application/zip' );

\echo inserting into ci_users_roles...
\echo ...$password = Digest::MD5::md5_hex('xgu');
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin)
       VALUES ( nextval('ci_users_roles_id_seq'), 'xgu', 'XIMS Test User', 0, 0, '43a008171c3de746fde9c6e724ee1001', 1, 0);
\echo ...$password = Digest::MD5::md5_hex('_adm1nXP');
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin)
       VALUES ( nextval('ci_users_roles_id_seq'), 'admin', 'admin', 0, 4294967295, 'f6d399e7dc811d185234a5d45f2b3caa', 1, 1);

\echo ...creation of basic roles should go here
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'guests', 'XIMS guests', 1, 0, 1);
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'admins', 'XIMS admins', 1, 4294967295, 1);
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'everyone', 'XIMS everyone', 1, 0, 1);

\echo ...add public user
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled)
       VALUES ( nextval('ci_users_roles_id_seq'), 'public', 'public', 1, 1, 1);

\echo ...add an implicit role for everyone BUT the public user
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled ) 
       VALUES ( nextval('ci_users_roles_id_seq'), 'authenticated', 'Authenticated users', 1, 0, 1);

-- grant roles
\echo inserting into ci_roles_granted...

-- grant 'xgu' and 'admin' their default roles 'guests' and 'admins'
INSERT INTO ci_roles_granted ( id, grantor_id, grantee_id, default_role )
       VALUES ( 3, 2, 1, 1 );
INSERT INTO ci_roles_granted ( id, grantor_id, grantee_id, role_master, default_role )
       VALUES ( 4, 2, 2, 1, 1 );
-- grant 'everyone' role to 'public' user, 'guests' and 'admins' roles
INSERT INTO ci_roles_granted ( id, grantor_id, grantee_id )
       VALUES ( 5, 2, 6 );
INSERT INTO ci_roles_granted ( id, grantor_id, grantee_id )
       VALUES ( 5, 2, 3 );
INSERT INTO ci_roles_granted ( id, grantor_id, grantee_id, role_master )
       VALUES ( 5, 2, 4, 1 );


\echo inserting into ci_documents and ci_content...

-- add root folder
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position )
       VALUES ( nextval('ci_documents_id_seq'), NULL, 6, 18, 1, 'root', 1);
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, content_length, published, marked_new, marked_deleted, data_format_name )
       VALUES ( nextval('ci_content_id_seq'), 1, 'root', 2, 2, 2, 2, 0, 0, 0, 0, 'Container');

---------------------------------------------------------
-- add default data content
--
-- for a manual XIMS install we only create two SiteRoots
-- for a the XIMS-box we include more default data
--
-- we have a manual XIMS install (via XIMS-installer)
\i defaultdata-content.sql

-- the following line is for building a XIMS-box
--\i xims-box-defaultdata-content.sql

\echo inserting into ci_bookmarks...
-- add default bookmarks
INSERT INTO ci_bookmarks ( id, owner_id, content_id, stdhome)
       VALUES ( nextval('ci_bookmarks_id_seq'), 3, 2, 1 );
INSERT INTO ci_bookmarks ( id, owner_id, content_id, stdhome)
       VALUES ( nextval('ci_bookmarks_id_seq'), 4, 1, 1 );

\echo inserting into ci_object_type_privs...

-- grants on object-types (for creation)

-- for role everyone
-- Document
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 2 );
-- Folder
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 1 );
-- File
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 4 );
-- URLLink
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 11 );
-- Image
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 3 );
-- DocBooxXML
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 9 );
-- AxPointPresentation
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 8 );
-- XML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 5 );
-- XSLStylesheet
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 7 );
-- SymbolicLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 13 );
-- Text
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 20 );
-- CSS
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 21 );
-- JavaScript
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, 28 );
-- grants on the created folders should go here

\echo inserting into ci_object_privs_granted...

INSERT INTO ci_object_privs_granted ( privilege_mask, grantee_id, grantor_id, content_id )
       VALUES ( 1, 3, 2, 2 );


\echo Setting is_ci_object_types.davgetable
UPDATE ci_object_types SET is_davgetable = 0;
UPDATE ci_object_types SET is_davgetable = 1 WHERE id IN (SELECT id from ci_object_types WHERE name IN ('Annotation', 'AxPointPresentation', 'CSS', 'DepartmentRoot', 'DocBookXML', 'Document', 'File', 'Folder', 'Image', 'JavaScript', 'NewsItem', 'Portal', 'Portlet', 'Questionnaire', 'SQLReport', 'SiteRoot', 'Text', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML','Event','Gallery'));

\echo Setting ci_object_types.davprivval
UPDATE ci_object_types SET davprivval = 0;
-- Container and Binary types
UPDATE ci_object_types SET davprivval = 1 WHERE name IN ('DepartmentRoot', 'File', 'Folder', 'Image', 'SiteRoot','Gallery');
-- Text based types
UPDATE ci_object_types SET davprivval = 2 WHERE name IN ('CSS', 'JavaScript', 'Text');
-- XML types
UPDATE ci_object_types SET davprivval = 4 WHERE name IN ('AxPointPresentation', 'DocBookXML', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML');

UPDATE ci_object_types SET davprivval = 8 WHERE name = 'Document';
UPDATE ci_object_types SET davprivval = 16 WHERE name = 'NewsItem';
UPDATE ci_object_types SET davprivval = 32 WHERE name = 'Questionnaire';
UPDATE ci_object_types SET davprivval = 64 WHERE name = 'SQLReport';
UPDATE ci_object_types SET davprivval = 128 WHERE name = 'Portlet';

\echo Setting ci_users_roles.dav_otprivs_mask;
-- Container, Binary, Text
UPDATE ci_users_roles SET dav_otprivs_mask = 3;
-- All types (0xFFFFFFFF bit bitmask) for admin
UPDATE ci_users_roles SET dav_otprivs_mask = 4294967295 WHERE admin = 1;

