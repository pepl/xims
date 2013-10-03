\echo Extending ci_sessions
ALTER TABLE CI_SESSIONS ADD AUTH_MODULE VARCHAR(50);
UPDATE CI_SESSIONS SET auth_module = 'dummy_value';
ALTER TABLE CI_SESSIONS ALTER COLUMN auth_module SET NOT NULL;
\echo Adding check parent_id != id on ci_documents
ALTER TABLE CI_DOCUMENTS ADD CONSTRAINT DOC_PARENT_ISNT_DOC CHECK (parent_id != id);
