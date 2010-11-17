PROMPT Adding new object types
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, publish_gopublic, is_objectroot, is_davgetable, davprivval, is_mailable  )
  VALUES ( OBT_SEQ.NEXTVAL, 'Gallery',  1, 1, 0, null, 0, 0, 1, 1, 0  );
