\echo adding new VLibrary ObjectTypes
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, publish_gopublic, is_objectroot, is_davgetable, davprivval, is_mailable)
       VALUES ( nextval('ci_object_types_id_seq'), 'Gallery',  1, 1, 0, null, 0, 0, 1, 1, 0  );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix  )
  VALUES ( 49, 'Gallery',  'application/x-container', null  );
