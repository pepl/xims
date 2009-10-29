PROMPT Adding ReferenceLibrary objects
@@../../sql/Oracle/cireflib_reference_library_ddl.sql

PROMPT Adding ReferenceLibrary default data
@@../../sql/referencelibrary_defaultdata.sql

PROMPT Adding SimpleDB objects
@@../../sql/Oracle/cisimpledb_ddl.sql

PROMPT Adding new attributes to CILIB_META
ALTER TABLE CILIB_META ADD COVERAGE            VARCHAR2(256);
ALTER TABLE CILIB_META ADD PUBLISHER           VARCHAR2(256);
ALTER TABLE CILIB_META ADD AUDIENCE            VARCHAR2(256);
ALTER TABLE CILIB_META ADD DC_DATE             DATE;
ALTER TABLE CILIB_META ADD DATE_FROM_TIMESTAMP DATE;
ALTER TABLE CILIB_META ADD DATE_TO_TIMESTAMP   DATE;

PROMPT Adding new object types 
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id )
  VALUES ( OBT_SEQ.NEXTVAL, 'URLLink',  0, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id )
  VALUES ( OBT_SEQ.NEXTVAL, 'Document', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );

\echo Adding new attributes to CI_OBJECT_TYPES
ALTER TABLE ci_object_types ADD IS_DAVGETABLE NUMBER(1,0) DEFAULT 0;
ALTER TABLE ci_object_types ADD DAVPRIVVAL NUMBER(32,0);

PROMPT Adding new attribute to CI_USERS_ROLES
ALTER TABLE ci_users_roles ADD DAV_OTPRIVS_MASK NUMBER(32,0);

PROMPT Setting is_ci_object_types.davgetable
UPDATE ci_object_types SET is_davgetable = 0;
UPDATE ci_object_types SET is_davgetable = 1 WHERE id IN (SELECT id from ci_object_types WHERE name IN ('Annotation', 'AxPointPresentation', 'CSS', 'DepartmentRoot', 'DocBookXML', 'Document', 'File', 'Folder', 'Image', 'JavaScript', 'NewsItem', 'Portal', 'Portlet', 'Questionnaire', 'SQLReport', 'SiteRoot', 'Text', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML'));

PROMPT Setting ci_object_types.davprivval
UPDATE ci_object_types SET davprivval = 0;
-- Container and Binary types
UPDATE ci_object_types SET davprivval = 1 WHERE name IN ('DepartmentRoot', 'File', 'Folder', 'Image', 'SiteRoot');
-- Text based types
UPDATE ci_object_types SET davprivval = 2 WHERE name IN ('CSS', 'JavaScript', 'Text');
-- XML types
UPDATE ci_object_types SET davprivval = 4 WHERE name IN ('AxPointPresentation', 'DocBookXML', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML');

UPDATE ci_object_types SET davprivval = 8 WHERE name = 'Document';
UPDATE ci_object_types SET davprivval = 16 WHERE name = 'NewsItem';
UPDATE ci_object_types SET davprivval = 32 WHERE name = 'Questionnaire';
UPDATE ci_object_types SET davprivval = 64 WHERE name = 'SQLReport';
UPDATE ci_object_types SET davprivval = 128 WHERE name = 'Portlet';

PROMPT Setting ci_users_roles.dav_otprivs_mask;
-- Container, Binary, Text
UPDATE ci_users_roles SET dav_otprivs_mask = 3;
-- All types (0xFFFFFFFF bit bitmask) for admin
UPDATE ci_users_roles SET dav_otprivs_mask = 4294967295 WHERE admin = 1;

-- Clean that up
UPDATE ci_users_roles SET system_privs_mask = 4294967295 WHERE admin = 1;

COMMIT;

