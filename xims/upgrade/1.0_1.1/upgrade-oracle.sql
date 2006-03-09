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

COMMIT;

