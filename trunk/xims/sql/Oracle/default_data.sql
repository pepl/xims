-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
-- default data ** 4 testing **

-- should be done through the modules!!!

INSERT INTO CI_LANGUAGES ( id, fullname, code ) VALUES ( LNG_SEQ.NEXTVAL, 'English (US)', 'en-us' );
INSERT INTO CI_LANGUAGES ( id, fullname, code ) VALUES ( LNG_SEQ.NEXTVAL, 'Deutsch (Österreich)', 'de-at' );

INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Folder', 1, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Document', 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Image', 0, 0, 0);
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'File', 0, 0, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'XML', 0, 0, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'DepartmentRoot', 1, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'XSLStylesheet', 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'AxPointPresentation', 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'DocBookXML', 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'XSPScript', 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'URLLink', 0, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'SymbolicLink', 0, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'AnonDiscussionForum', 1, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'AnonDiscussionForumContrib', 0, 1, 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'NewsItem', 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Annotation', 0, 0, 0);
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Portlet', 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Portal', 0, 0, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'SiteRoot', 1, 1, 0 );

INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Text', 'text/plain', 'txt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'HTML', 'text/xhtml', 'html' );
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
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PJPEG', 'image/pjpeg', 'jpg' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'AXPML', 'text/xml', 'axp' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'DocBookXML', 'text/xml', 'dkb' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'URL', 'text/plain', 'url' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'SymbolicLink', 'text/plain' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'GNU-Zip', 'application/x-gzip','gz' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'BZip', 'application/x-bzip2','bz2' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'XSP', 'application/x-xsp', 'xsp');
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'ECMA', 'application/x-javascript','js' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'AnonDiscussionForum', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'Portlet', 'text/xml' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'DepartmentRoot', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'SiteRoot', 'application/x-container' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Postscript', 'application/postscript', 'ps' );

INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 11, 'application/msword' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 12, 'application/ppt' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/msexcel' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/x-msexcel' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 13, 'application/x-mspowerpoint' );
INSERT INTO CI_MIME_TYPE_ALIASES ( id, data_format_id, mime_type ) VALUES ( MTA_SEQ.NEXTVAL, 15, 'image/x-png' );

-- $password = Digest::MD5::md5_hex('xgu');
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin) VALUES ( USR_SEQ.NEXTVAL, 'xgu', 'XIMS Test User', 0, 1, '43a008171c3de746fde9c6e724ee1001', 1, 0);
-- $password = Digest::MD5::md5_hex('_adm1nXP');
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, password, enabled, admin) VALUES ( USR_SEQ.NEXTVAL, 'admin', 'admin', 0, 4294967296, 'f6d399e7dc811d185234a5d45f2b3caa', 1, 1);

-- creation of basic roles should go here
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'guests', 'XIMS guests', 1, 0, 1);
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'admins', 'XIMS admins', 1, 4294967296, 1);
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'everyone', 'XIMS everyone', 1, 0, 1);

-- add public user
INSERT INTO CI_USERS_ROLES ( id, name, lastname, object_type, system_privs_mask, enabled ) VALUES ( USR_SEQ.NEXTVAL, 'public', 'public', 1, 1, 1);

-- grant roles
-- grant xgu and admin their default role
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, default_role ) VALUES ( 3, 2, 1, 1 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, role_master, default_role ) VALUES ( 4, 2, 2, 1, 1 );

-- grant public, user guests and admins to everyone
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id ) VALUES ( 5, 2, 6 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id ) VALUES ( 5, 2, 3 );
INSERT INTO CI_ROLES_GRANTED ( id, grantor_id, grantee_id, role_master ) VALUES ( 5, 2, 4, 1 );


-- add root folder
INSERT INTO CI_DOCUMENTS ( id, parent_id, object_type_id, data_format_id, department_id, location, position ) VALUES ( DOC_SEQ.NEXTVAL, 1, 6, 18, 1, 'root',1);
INSERT INTO CI_CONTENT ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id ) VALUES ( CTT_SEQ.NEXTVAL, 1, 'root', 2, 2, 2, 2);
-- add site root "xims"
INSERT INTO CI_DOCUMENTS ( id, parent_id, object_type_id, data_format_id, department_id, location, position ) VALUES ( DOC_SEQ.NEXTVAL, 1, 19, 31, 2, 'xims', 1);
INSERT INTO CI_CONTENT ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id ) VALUES ( CTT_SEQ.NEXTVAL, 2, 'xims', 2, 2, 2, 2);

-- add default bookmarks
INSERT INTO CI_BOOKMARKS ( id, owner_id, content_id, stdhome) VALUES ( BMK_SEQ.NEXTVAL, 3, 2, 1 );
INSERT INTO CI_BOOKMARKS ( id, owner_id, content_id, stdhome) VALUES ( BMK_SEQ.NEXTVAL, 4, 1, 1 );

-- grants on object-types (for creation)
-- Document
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 2 );
-- Folder
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 1 );
-- File
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 4 );
-- URLLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 11 );
-- Image
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 3 );
-- DocBooxXML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 1, 2, 9 );


-- grants on the created folders should go here

INSERT INTO CI_OBJECT_PRIVS_GRANTED ( privilege_mask, grantee_id, grantor_id, content_id ) VALUES ( 1, 1, 2, 2 );

