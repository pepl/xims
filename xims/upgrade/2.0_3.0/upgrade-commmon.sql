INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
VALUES ( ci_data_formats_id_seq_nval(), 'Markdown', 'text/x-markdown', 'html' );

INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_mailable, menu_level, is_davgetable, davprivval )
       VALUES ( ci_object_types_id_seq_nval(), 'Markdown', 0, 1, 1, 0, 1, 2, 1, 2 );
