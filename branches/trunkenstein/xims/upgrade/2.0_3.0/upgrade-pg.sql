\echo Extending password field
ALTER TABLE CI_USERS_ROLES ALTER password SET DATA TYPE VARCHAR(60);
\echo Truncating and extending ci_sessions
TRUNCATE TABLE CI_SESSIONS;
ALTER TABLE CI_SESSIONS ALTER session_id  SET DATA TYPE VARCHAR(60);
ALTER TABLE CI_SESSIONS ALTER salt        SET DATA TYPE VARCHAR(40);
ALTER TABLE CI_SESSIONS ALTER token       SET DATA TYPE VARCHAR(40);
ALTER TABLE CI_SESSIONS ADD   auth_module VARCHAR(50);
ALTER TABLE CI_SESSIONS ALTER COLUMN auth_module SET NOT NULL;
\echo Adding check parent_id != id on ci_documents
ALTER TABLE CI_DOCUMENTS ADD CONSTRAINT DOC_PARENT_ISNT_DOC CHECK (parent_id != id);
