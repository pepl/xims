-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- assume that this data is LATIN1 encoded
-- ans let psql translate it to whatever the database itself is set to
-- (which should be UNICODE)
SET CLIENT_ENCODING TO 'LATIN1';

\echo inserting into ci_languages...

INSERT INTO ci_languages ( id, fullname, code )
       VALUES ( nextval('ci_languages_id_seq'), 'English (US)', 'en-us' );
INSERT INTO ci_languages ( id, fullname, code )
       VALUES ( nextval('ci_languages_id_seq'), 'Deutsch (Österreich)', 'de-at' );

\echo inserting into ci_object_types...


INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Folder', 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Document', 0, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Image', 0, 0, 0);
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'File', 0, 0, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'XML', 0, 0, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'DepartmentRoot', 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'XSLStylesheet', 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'AxPointPresentation', 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'DocBookXML', 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'XSPScript', 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'URLLink', 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'SymbolicLink', 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'AnonDiscussionForum', 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'AnonDiscussionForumContrib', 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'NewsItem', 0, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Annotation', 0, 0, 0);
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Portlet', 0, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'Portal', 0, 0, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self )
       VALUES ( nextval('ci_object_types_id_seq'), 'SiteRoot', 1, 1, 0 );


\echo inserting into ci_data_formats...

INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Text', 'text/plain', 'txt' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'HTML', 'text/xhtml', 'html' );
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
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PJPEG', 'image/pjpeg', 'jpg' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'AXPML', 'text/xml', 'axp' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DocBookXML', 'text/xml', 'dkb' );
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
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'AnonDiscussionForum', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Portlet', 'text/xml' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DepartmentRoot', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'SiteRoot', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Postscript', 'application/postscript', 'ps' );

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

\echo inserting into ci_users_roles...
\echo ...$password = Digest::MD5::md5_hex('xgu');
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin)
       VALUES ( nextval('ci_users_roles_id_seq'), 'xgu', 'XIMS Test User', 0, 1, '43a008171c3de746fde9c6e724ee1001', 1, 0);
\echo ...$password = Digest::MD5::md5_hex('_adm1nXP');
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin)
       VALUES ( nextval('ci_users_roles_id_seq'), 'admin', 'admin', 0, 4294967296, 'f6d399e7dc811d185234a5d45f2b3caa', 1, 1);

\echo ...creation of basic roles should go here
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'guests', 'XIMS guests', 1, 0, 1);
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'admins', 'XIMS admins', 1, 4294967296, 1);
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled )
       VALUES ( nextval('ci_users_roles_id_seq'), 'everyone', 'XIMS everyone', 1, 0, 1);

\echo ...add public user
INSERT INTO ci_users_roles ( id, name, lastname, object_type, system_privs_mask, enabled)
       VALUES ( nextval('ci_users_roles_id_seq'), 'public', 'public', 1, 1, 1);


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
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, lft, rgt )
       VALUES ( nextval('ci_documents_id_seq'), 1, 6, 18, 1, 'root',1, 1, 4);
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
       VALUES ( nextval('ci_content_id_seq'), 1, 'root', 2, 2, 2, 2);
-- add siteroot "xims"
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, lft, rgt )
       VALUES (nextval('ci_documents_id_seq'), 1, 19, 31, 2, 'xims', 1, 2, 3);
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
       VALUES (nextval('ci_content_id_seq') , 2, 'xims', 2, 2, 2, 2);


\echo inserting into ci_bookmarks...
-- add default bookmarks
INSERT INTO ci_bookmarks ( id, owner_id, content_id, stdhome)
       VALUES ( nextval('ci_bookmarks_id_seq'), 3, 2, 1 );
INSERT INTO ci_bookmarks ( id, owner_id, content_id, stdhome)
       VALUES ( nextval('ci_bookmarks_id_seq'), 4, 1, 1 );

\echo inserting into ci_object_type_privs...

-- grants on object-types (for creation)
-- Document
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 2 );
-- Folder
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 1 );
-- File
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 4 );
-- URLLink
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 11 );
-- Image
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 3 );
-- DocBooxXML
INSERT INTO ci_object_type_privs ( grantee_id, grantor_id, object_type_id )
       VALUES ( 1, 2, 9 );

-- grants on the created folders should go here

\echo inserting into ci_object_privs_granted...

INSERT INTO ci_object_privs_granted ( privilege_mask, grantee_id, grantor_id, content_id )
       VALUES ( 1, 1, 2, 2 );
