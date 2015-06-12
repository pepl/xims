PROMPT Extending password field
ALTER TABLE CI_USERS_ROLES MODIFY password VARCHAR2(60);
PROMPT Truncating and extending ci_sessions
TRUNCATE TABLE CI_SESSIONS;
ALTER TABLE CI_SESSIONS MODIFY session_id  VARCHAR2(60);
ALTER TABLE CI_SESSIONS MODIFY salt        VARCHAR2(40);
ALTER TABLE CI_SESSIONS ADD    token       VARCHAR2(40);
ALTER TABLE CI_SESSIONS ADD    creation_timestamp DATE DEFAULT SYSDATE NOT NULL;
ALTER TABLE CI_SESSIONS ADD    auth_module VARCHAR2(50);
ALTER TABLE CI_SESSIONS MODIFY auth_module NOT NULL
PROMPT Rebuild index 'DOC_DOC_PARENT_FK_I' to include ID
DROP INDEX DOC_DOC_PARENT_FK_I;
CREATE INDEX DOC_DOC_PARENT_FK_I ON CI_DOCUMENTS 
(PARENT_ID, ID);
/
PROMPT add check ci_documents.parent_id != ci_documents.id 
ALTER TABLE CI_DOCUMENTS ADD CONSTRAINT 
    DOC_PARENT_ISNT_DOC CHECK (PARENT_ID != ID)
/
PROMPT Create OPG_GPC_COMBINED_I
CREATE INDEX OPG_GPC_COMBINED_I ON CI_OBJECT_PRIVS_GRANTED 
(GRANTEE_ID, PRIVILEGE_MASK, CONTENT_ID)
/
PROMPT Create objecttype Document2 and update suffix
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, menu_level ) 
  VALUES ( OBT_SEQ.NEXTVAL, 'Document2', 0, 1, 1, 0, 1 );
UPDATE CI_DATA_FORMATS SET SUFFIX = 'html' WHERE NAME = 'XHTML5';
/
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, parent_id, menu_level )
       VALUES ( nextval('ci_object_types_id_seq'), 'NewsItem', 0, 1, 1, 0, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 )
/ 
