\echo Inserting new object type SQLReport
INSERT INTO ci_object_types ( id, name, is_fs_container, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'SQLReport', 0, 1, 1 );

\echo Adding SCHEMA_ID column to CI_CONTENT
ALTER TABLE ci_content ADD COLUMN schema_id INTEGER REFERENCES ci_content ( id );

\echo Dropping Foreign Key 'STYLE_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$2";

\echo Dropping Foreign Key 'SCRIPT_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$3";

\echo Dropping Foreign Key 'CSS_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$8";

\echo Dropping Foreign Key 'IMAGE_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$9";

\echo Creating Foreign Key 'CTT_CTT_STYLE_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_STYLE_FK FOREIGN KEY (STYLE_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_CSS_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_CSS_FK FOREIGN KEY (CSS_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_IMAGE_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_IMAGE_FK FOREIGN KEY (IMAGE_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_SCRIPT_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_SCRIPT_FK FOREIGN KEY (SCRIPT_ID) REFERENCES CI_CONTENT (ID);

\echo Renaming ci_documents.status to ci_documents.document_status
ALTER TABLE ci_documents RENAME COLUMN status TO document_status;
