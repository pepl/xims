PROMPT Adding LOCATION_PATH column on 'CI_DOCUMENTS'
ALTER TABLE CI_DOCUMENTS ADD (LOCATION_PATH VARCHAR2(4000))
/

-- Functions and triggers for location_path denormalization
@@../../sql/Oracle/ci_util_location_path.sql

-- write location_path values to existing data in ci_documents
DECLARE
 rv BOOLEAN;
BEGIN
 rv := ci_util.sync_location_path;
END;
/

PROMPT Adding PARENT_ID column on 'CI_OBJECT_TYPES'
ALTER TABLE CI_OBJECT_TYPES ADD (PARENT_ID NUMBER)
/

PROMPT Creating Foreign Key on 'CI_OBJECT_TYPES'
ALTER TABLE CI_OBJECT_TYPES ADD (CONSTRAINT
 OBT_OBT_PARENT_FK FOREIGN KEY
  (PARENT_ID) REFERENCES CI_OBJECT_TYPES
  (ID) ON DELETE CASCADE)
/

PROMPT Creating Index 'OBT_OBT_PARENT_FK_I'
CREATE INDEX OBT_OBT_PARENT_FK_I ON CI_OBJECT_TYPES
 (PARENT_ID)
/

PROMPT Inserting new object types
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic ) VALUES ( OBT_SEQ.NEXTVAL, 'VLibrary', 1, 1, 1, 0 )
/
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic ) VALUES ( OBT_SEQ.NEXTVAL, 'VLibraryItem', 0, 1, 1, 0 )
/
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id ) VALUES ( OBT_SEQ.NEXTVAL, 'DocBookXML', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ) )
/

PROMPT Inserting new data formats
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) VALUES ( DFM_SEQ.NEXTVAL, 'VLibrary', 'application/x-container' );