PROMPT Inserting new object type SQLReport
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, redir_to_self, publish_gopublic ) VALUES ( OBT_SEQ.NEXTVAL, 'SQLReport', 0, 1, 1 )
/

PROMPT Adding SCHEMA_ID column on 'CI_CONTENT'
ALTER TABLE ci_content ADD (SCHEMA_ID NUMBER)
/

PROMPT Creating Foreign Key on 'CI_CONTENT'
ALTER TABLE CI_CONTENT ADD (CONSTRAINT
 CTT_CTT_SCHEMA_FK FOREIGN KEY
  (SCHEMA_ID) REFERENCES CI_CONTENT
  (ID))
/

PROMPT Renaming ci_documents.status to ci_documents.document_status 
ALTER TABLE ci_documents RENAME COLUMN status TO document_status
/

PROMPT Extending ci_content.title
ALTER TABLE ci_content MODIFY (title VARCHAR2(400) NOT NULL)
/

PROMPT Extending lastname and firstname columns
ALTER TABLE ci_content MODIFY (last_published_by_firstname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (created_by_firstname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (owned_by_firstname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (last_modified_by_firstname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (locked_by_firstname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (last_published_by_lastname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (created_by_lastname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (owned_by_lastname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (last_modified_by_lastname VARCHAR2(90))
/
ALTER TABLE ci_content MODIFY (locked_by_lastname VARCHAR2(90))
/
ALTER TABLE ci_users_roles MODIFY (firstname VARCHAR2(90))
/
ALTER TABLE ci_users_roles MODIFY (lastname VARCHAR2(90))
/
