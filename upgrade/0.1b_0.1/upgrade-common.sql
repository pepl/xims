-- grant to role 'everyone' instead of user 'xgu'
UPDATE CI_OBJECT_TYPE_PRIVS SET grantee_id = 5 WHERE grantee_id = 1;

-- add new object type privileges
-- AxPointPresentation
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 8 );
-- XML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 5 );
-- XSLStylesheet
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 7 );
-- SymbolicLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 12 );
-- AnonDiscussionForum
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 13 );
-- Text
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 20 );
-- CSS
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 5, 2, 21 );

-- grant /xims to role 'guest' instead of user 'xgu'
UPDATE CI_OBJECT_PRIVS_GRANTED SET grantee_id = 3 WHERE privilege_mask=1 AND grantee_id=1 AND grantor_id=2 AND content_id=2;

-- fix redir_to_self for XML
UPDATE CI_OBJECT_TYPES SET redir_to_self = 1, is_xims_data = 1 WHERE name = 'XML';

-- user 'xgu' should not be able to change his password
UPDATE CI_USERS_ROLES SET system_privs_mask = 0 WHERE name = 'xgu';

-- add new object types
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Text', 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'CSS', 0, 1, 1 );

