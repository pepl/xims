-- grant to 'role guest' instead of 'user xgu'
UPDATE CI_OBJECT_TYPE_PRIVS SET grantee_id = 3 where grantee_id = 1 AND object_type_id IN (2, 1, 4, 11, 3, 9);

-- add new object type privileges
-- AxPointPresentation
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 3, 2, 8 );
-- XML
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 3, 2, 5 );
-- XSLStylesheet
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 3, 2, 7 );
-- SymbolicLink
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 3, 2, 12 );
-- AnonDiscussionForum
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id ) VALUES ( 3, 2, 13 );

-- grant /xims to 'role guest' instead of 'user xgu'
UPDATE ci_object_privs_granted SET grantee_id = 3 WHERE privilege_mask=1 and grantee_id=1 and grantor_id=2 and content_id=2;

-- fix redir_to_self for XML
UPDATE CI_OBJECT_TYPES set redir_to_self = 1, is_xims_data = 1 where name = 'XML';

-- add new object types
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'Text', 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self ) VALUES ( OBT_SEQ.NEXTVAL, 'CSS', 0, 1, 1 );

