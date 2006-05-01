BEGIN WORK;

\echo Making parent_id on 'CI_DOCUMENTS' nullable
ALTER TABLE ci_documents ALTER COLUMN parent_id DROP NOT NULL;
UPDATE ci_documents SET parent_id = NULL WHERE id = 1;

\echo Adding LOCATION_PATH column on 'CI_DOCUMENTS'
ALTER TABLE ci_documents ADD COLUMN location_path TEXT;

-- Functions and triggers for location_path denormalization
\i ../../sql/Pg/location_path.sql

-- write location_path values to existing data in ci_documents
SELECT sync_location_path();

\echo Adding VLibrary Tables
\i ../../sql/Pg/create_library.sql

\echo Adding PARENT_ID column on 'CI_OBJECT_TYPES'
ALTER TABLE ci_object_types ADD COLUMN parent_id INTEGER  REFERENCES ci_object_types ( id ) ON DELETE CASCADE;

\echo Inserting new object types
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibrary', 1, 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibraryItem', 0, 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id )
       VALUES ( nextval('ci_object_types_id_seq'), 'DocBookXML', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'DocBookXML', 0, 0, 1, 0 );

\echo Inserting new data formats
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'VLibrary', 'application/x-container' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'DocBookXML', 'text/xml', 'dbk' );

\echo Inserting new mime type aliases
INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 14, 'application/x-msdos-program' );


COMMIT;