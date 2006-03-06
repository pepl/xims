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

\echo Adding Timestamps for Chronicle
ALTER TABLE cilib_meta ADD COLUMN date_from_timestamp timestamp;
ALTER TABLE cilib_meta ADD COLUMN date_to_timestamp timestamp;

\echo Adding ReferenceLibrary objects
\i ../../sql/Pg/create_referencelibrary.sql

\echo Adding ReferenceLibrary default data
\i ../../sql/referencelibrary_defaultdata.sql

\echo Adding SimpleDB objects
\i ../../sql/Pg/create_simpledb.sql
