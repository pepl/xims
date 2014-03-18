PROMPT Truncating and extending ci_sessions
TRUNCATE TABLE CI_SESSIONS;
ALTER TABLE CI_SESSIONS MODIFY session_id  VARCHAR2(60);
ALTER TABLE CI_SESSIONS MODIFY salt        VARCHAR2(40);
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
