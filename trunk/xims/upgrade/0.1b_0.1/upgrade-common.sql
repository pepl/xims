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
