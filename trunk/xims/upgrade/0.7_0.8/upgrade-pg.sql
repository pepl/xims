\echo Adding PARENT_ID column on 'CI_OBJECT_TYPES'
ALTER TABLE ci_object_types ADD COLUMN publish_gopublic parent_id INTEGER  REFERENCES ci_object_types ( id ) ON DELETE CASCADE;

\echo Inserting new object types
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibrary', 1, 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'VLibraryItem', 0, 1, 1, 0 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id )
       VALUES ( nextval('ci_object_types_id_seq'), 'sDocBookXML', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) );

\echo Inserting new data formats
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'VLibrary', 'application/x-container' );
