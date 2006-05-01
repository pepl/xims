ALTER TABLE ci_object_types MODIFY (is_fs_container DEFAULT 0);
ALTER TABLE ci_object_types MODIFY (is_xims_data DEFAULT 0);
ALTER TABLE ci_object_types MODIFY (redir_to_self DEFAULT 1);
