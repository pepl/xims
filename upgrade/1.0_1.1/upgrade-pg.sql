-- From: http://www.postgresql.org/docs/7.4/interactive/indexes-types.html
-- Note:  Testing has shown PostgreSQL's hash indexes to perform no better than B-tree indexes,
-- and the index size and build time for hash indexes is much worse. For these reasons,
-- hash index use is presently discouraged.
\echo Recreating HASH indexes as B-TREE indexes
DROP index ci_content_doc_id_idx;
CREATE INDEX ci_content_doc_id_idx ON ci_content ( document_id );

DROP index ci_roles_granted_grantee_idx;
CREATE INDEX ci_roles_granted_grantee_idx ON ci_roles_granted ( grantee_id );

DROP index ci_obj_type_privs_grantee_idx;
CREATE INDEX ci_obj_type_privs_grantee_idx ON ci_object_type_privs ( grantee_id );

\echo Adding new attributes to CILIB_META
ALTER TABLE cilib_meta ADD COLUMN coverage            VARCHAR(256);
ALTER TABLE cilib_meta ADD COLUMN publisher           VARCHAR(256);
ALTER TABLE cilib_meta ADD COLUMN audience            VARCHAR(256);
ALTER TABLE cilib_meta ADD COLUMN dc_date             TIMESTAMP(0) WITHOUT TIME ZONE;
ALTER TABLE cilib_meta ADD COLUMN date_from_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;
ALTER TABLE cilib_meta ADD COLUMN date_to_timestamp   TIMESTAMP(0) WITHOUT TIME ZONE;

\echo adding new VLibrary ObjectTypes
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id )
       VALUES ( nextval('ci_object_types_id_seq'), 'URLLink', 0, 1, 0, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id )
       VALUES ( nextval('ci_object_types_id_seq'), 'Document', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );

\echo Adding ReferenceLibrary objects
\i ../../sql/Pg/create_referencelibrary.sql

\echo Adding ReferenceLibrary default data
\i ../../sql/referencelibrary_defaultdata.sql

\echo Adding SimpleDB objects
\i ../../sql/Pg/create_simpledb.sql

\echo Adding new attributes to CI_OBJECT_TYPES
ALTER TABLE ci_object_types ADD COLUMN is_davgetable    SMALLINT;
ALTER TABLE ci_object_types ALTER is_davgetable SET DEFAULT 0;
ALTER TABLE ci_object_types ADD COLUMN davprivval       NUMERIC(32,0);

\echo Adding new attribute to CI_USERS_ROLES
ALTER TABLE ci_users_roles ADD COLUMN dav_otprivs_mask    NUMERIC(32,0);

\echo Setting is_ci_object_types.davgetable
UPDATE ci_object_types SET is_davgetable = 0;
UPDATE ci_object_types SET is_davgetable = 1 WHERE id IN (SELECT id from ci_object_types WHERE name IN ('Annotation', 'AxPointPresentation', 'CSS', 'DepartmentRoot', 'DocBookXML', 'Document', 'File', 'Folder', 'Image', 'JavaScript', 'NewsItem', 'Portal', 'Portlet', 'Questionnaire', 'SQLReport', 'SiteRoot', 'Text', 'XML', 'XSLStylesheet', 'XSPScript', 'sDocBookXML'));

\echo Setting ci_object_types.davprivval
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

\echo Setting ci_users_roles.dav_otprivs_mask;
-- Container, Binary, Text
UPDATE ci_users_roles SET dav_otprivs_mask = 3;
-- All types (0xFFFFFFFF bit bitmask) for admin
UPDATE ci_users_roles SET dav_otprivs_mask = 4294967295 WHERE admin = 1;

-- Clean that up
UPDATE ci_users_roles SET system_privs_mask = 4294967295 WHERE admin = 1;


