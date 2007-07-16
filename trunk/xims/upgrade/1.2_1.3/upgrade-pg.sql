\echo Extending cisimpledb_member_properties.regex column
ALTER TABLE cisimpledb_member_properties ADD nregex VARCHAR(2048);
UPDATE cisimpledb_member_properties SET nregex = CAST(regex AS VARCHAR(2048));
ALTER TABLE cisimpledb_member_properties DROP regex;
ALTER TABLE cisimpledb_member_properties RENAME nregex TO regex;

\echo Adding ci_content.status_checked_timestamp
ALTER TABLE ci_content ADD status_checked_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;

\echo Adding ci_content.deletionmark_timestamp
ALTER TABLE ci_content ADD deletionmark_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;

DELETE FROM ci_object_privs_granted WHERE content_id NOT IN (select id from ci_content);
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_USR_GRANTEE_FK FOREIGN KEY (GRANTEE_ID) REFERENCES CI_USERS_ROLES (ID) ON DELETE CASCADE;
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_USR_GRANTOR_FK FOREIGN KEY (GRANTOR_ID) REFERENCES CI_USERS_ROLES (ID) ON DELETE CASCADE;
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_CTT_CONTENT_FK FOREIGN KEY (CONTENT_ID) REFERENCES CI_CONTENT (ID) ON DELETE CASCADE;
CREATE INDEX ci_obj_privs_grantee_idx ON ci_object_privs_granted ( grantee_id );
CREATE INDEX ci_obj_privs_content_idx ON ci_object_privs_granted ( content_id );

