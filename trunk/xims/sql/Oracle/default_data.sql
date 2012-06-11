-- Copyright (c) 2002-2011 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
-- default data ** 4 testing **

-- should be done through the modules!!!

INSERT INTO CI_LANGUAGES ( id, fullname, code ) VALUES ( LNG_SEQ.NEXTVAL, 'English (US)', 'en-us' );
INSERT INTO CI_LANGUAGES ( id, fullname, code ) VALUES ( LNG_SEQ.NEXTVAL, 'Deutsch (Österreich)', 'de-at' );

INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Folder', 1, 1, 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Document', 0, 1, 1, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Image', 0, 0, 0, 0, 1);
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'File', 0, 0, 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'XML', 0, 1, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'DepartmentRoot', 1, 1, 0, 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'XSLStylesheet', 0, 0, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'AxPointPresentation', 0, 0, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'sDocBookXML', 0, 0, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'XSPScript', 0, 0, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'URLLink', 0, 1, 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'SymbolicLink', 0, 1, 0, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'NewsItem', 0, 1, 1, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Annotation', 0, 0, 0, 0, 0);
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Portlet', 0, 1, 1, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Portal', 0, 0, 1, 0, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'SiteRoot', 1, 1, 0, 0, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Text', 0, 1, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'CSS', 0, 1, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Questionnaire', 0, 0, 1, 1, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'TAN_List', 0, 0, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'VLibrary', 1, 1, 1, 1, 1, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'VLibraryItem', 0, 1, 1, 0, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'DocBookXML', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem'), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'URLLink', 0, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Document', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'DocBookXML', 0, 0, 1, 0, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'JavaScript', 0, 1, 1, 0, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'SQLReport', 0, 1, 1, 2 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Event', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_mailable, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'NewsLetter', 0, 1, 1, 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) VALUES ( OBT_SEQ.NEXTVAL, 'Gallery', 1, 1, 0, 0, 1 );


INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Text', 'text/plain', 'txt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'HTML', 'text/html', 'html' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XSLT', 'text/xml', 'xsl' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XML', 'text/xml', 'xml' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'CSS', 'text/css', 'css' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XPS', 'text/x-xpathscript', 'xps' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'JPEG', 'image/jpeg', 'jpg' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'TIFF', 'image/tiff', 'tif' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'GIF', 'image/gif', 'gif' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PDF', 'application/pdf', 'pdf' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'DOC', 'application/vnd.ms-word', 'doc' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PPT', 'application/vnd.ms-powerpoint', 'ppt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XLS', 'application/vnd.ms-excel', 'xls' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Binary', 'application/octet-stream', 'exe' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PNG', 'image/png', 'png' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'ZIP', 'application/x-zip-compressed', 'zip' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'TAR', 'application/x-tar', 'tar' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'Container', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'Gallery', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PJPEG', 'image/pjpeg', 'jpg' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'AXPML', 'text/xml', 'axp' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'sDocBookXML', 'text/xml', 'sdbk' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'URL', 'text/plain', 'url' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'SymbolicLink', 'text/plain' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'GNU-Zip', 'application/x-gzip','gz' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'BZip', 'application/x-bzip2','bz2' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XSP', 'text/xml', 'xsp');
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'ECMA', 'text/javascript','js' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Portlet', 'text/xml', 'ptlt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'DepartmentRoot', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'SiteRoot', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Postscript', 'application/postscript', 'ps' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'Questionnaire', 'text/xml' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'TAN_List', 'text/plain', 'tls' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Icon', 'image/x-icon', 'ico' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PPZ', 'application/vnd.ms-powerpoint', 'ppz' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'POT', 'application/vnd.ms-powerpoint', 'pot' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PPS', 'application/vnd.ms-powerpoint', 'pps' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'VLibrary', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'DocBookXML', 'text/xml', 'dbk' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'MP3', 'audio/mpeg', 'mp3' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'M4A', 'audio/x-m4a', 'm4a' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'MP4', 'video/mp4', 'mp4' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'M4V', 'video/x-m4v', 'm4v' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'MOV', 'video/quicktime', 'mov' );


INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 11, 'application/msword' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 12, 'application/ppt' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/msexcel' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/x-msexcel' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/x-mspowerpoint' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 15, 'image/x-png' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 14, 'application/x-msdos-program' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 16, 'application/zip' );


-- $password = Digest::MD5::md5_hex('xgu');
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin) VALUES ( USR_SEQ.NEXTVAL, 'xgu', 'XIMS Test User', 0, 0, '43a008171c3de746fde9c6e724ee1001', 1, 0);
-- $password = Digest::MD5::md5_hex('_adm1nXP');
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin) VALUES ( USR_SEQ.NEXTVAL, 'admin', 'admin', 0, 4294967295, 'f6d399e7dc811d185234a5d45f2b3caa', 1, 1);

-- creation of basic roles should go here
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'guests', 'XIMS guests', 1, 0, 1);
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'admins', 'XIMS admins', 1, 4294967295, 1);
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'everyone', 'XIMS everyone', 1, 0, 1);

-- add public user
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'public', 'public', 1, 1, 1);

-- an implicit role for everyone BUT the public user
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'authenticated', 'Authenticated users', 1, 0, 1);

-- grant roles
-- grant 'xgu' and 'admin' their default roles 'guests' and 'admins'
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, default_role ) VALUES ( 3, 2, 1, 1 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, role_master, default_role ) VALUES ( 4, 2, 2, 1, 1 );

-- grant 'everyone' role to 'public' user, 'guests' and 'admins' roles
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id ) VALUES ( 5, 2, 6 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id ) VALUES ( 5, 2, 3 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, role_master ) VALUES ( 5, 2, 4, 1 );

-- add root folder
INSERT INTO CI_DOCUMENTS ( id, parent_id, object_type_id, data_format_id, department_id, location, position) VALUES ( DOC_SEQ.NEXTVAL, NULL, 6, 18, 1, 'root', 1 );
INSERT INTO CI_CONTENT ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, content_length, published, marked_new, marked_deleted ) VALUES ( CTT_SEQ.NEXTVAL, 1, 'root', 2, 2, 2, 2, 0, 0, 0, 0);

-- add SiteRoot "xims" with SiteRoot URL '/ximspubroot/xims'
INSERT INTO CI_DOCUMENTS ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path ) VALUES ( DOC_SEQ.NEXTVAL, 1, 17, 31, 2, 'xims', 1, '/xims' );
INSERT INTO CI_CONTENT ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, content_length, published, marked_new, marked_deleted ) VALUES ( CTT_SEQ.NEXTVAL, 2, '/ximspubroot/xims', 2, 2, 2, 2, 0, 0, 0, 0);

-- add default bookmarks
INSERT INTO CI_BOOKMARKS ( id, owner_id, content_id, stdhome) VALUES ( BMK_SEQ.NEXTVAL, 3, 2, 1 );
INSERT INTO CI_BOOKMARKS ( id, owner_id, content_id, stdhome) VALUES ( BMK_SEQ.NEXTVAL, 4, 1, 1 );

-- grants on object-types (for creation)

-- for role everyone
---
-- Document
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 2 );
-- Folder
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 1 );
-- File
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 4 );
-- URLLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 11 );
-- Image
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 3 );
-- DocBooxXML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 9 );
-- AxPointPresentation
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 8 );
-- XML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 5 );
-- XSLStylesheet
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 7 );
-- SymbolicLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 13 );
-- Text
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 20 );
-- CSS
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 21 );
-- JavaScript
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 28 );


-- grants on the created folders should go here
INSERT INTO CI_OBJECT_PRIVS_GRANTED ( privilege_mask, grantee_id, grantor_id, content_id ) VALUES ( 1, 3, 2, 2 );


-- Setting is_ci_object_types.davgetable
UPDATE ci_object_types SET is_davgetable = 0;
UPDATE ci_object_types SET is_davgetable = 1 WHERE id IN (SELECT id from ci_object_types WHERE name IN ('Annotation', 'AxPointPresentation', 'CSS', 'DepartmentRoot', 'DocBookXML', 'Document', 'File', 'Folder', 'Image', 'JavaScript', 'NewsItem', 'Portal', 'Portlet', 'Questionnaire', 'SQLReport', 'SiteRoot', 'Text', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML','Event','Gallery'));

-- Setting ci_object_types.davprivval
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

-- Setting ci_users_roles.dav_otprivs_mask;
-- Container, Binary, Text
UPDATE ci_users_roles SET dav_otprivs_mask = 3;
-- All types (0xFFFFFFFF bit bitmask) for admin
UPDATE ci_users_roles SET dav_otprivs_mask = 4294967295 WHERE admin = 1;
