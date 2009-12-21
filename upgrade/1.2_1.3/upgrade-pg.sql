\echo Extending cisimpledb_member_properties.regex column
ALTER TABLE cisimpledb_member_properties ADD nregex VARCHAR(2048);
UPDATE cisimpledb_member_properties SET nregex = CAST(regex AS VARCHAR(2048));
ALTER TABLE cisimpledb_member_properties DROP regex;
ALTER TABLE cisimpledb_member_properties RENAME nregex TO regex;

\echo Adding ci_content.status_checked_timestamp
ALTER TABLE ci_content ADD status_checked_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;

\echo Adding ci_content.deletionmark_timestamp
ALTER TABLE ci_content ADD deletionmark_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;

\echo Adding ci_content.feed_id 
ALTER TABLE ci_content ADD feed_id INTEGER REFERENCES ci_content( id );

DELETE FROM ci_object_privs_granted WHERE content_id NOT IN (select id from ci_content);
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_USR_GRANTEE_FK FOREIGN KEY (GRANTEE_ID) REFERENCES CI_USERS_ROLES (ID) ON DELETE CASCADE;
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_USR_GRANTOR_FK FOREIGN KEY (GRANTOR_ID) REFERENCES CI_USERS_ROLES (ID) ON DELETE CASCADE;
ALTER TABLE ci_object_privs_granted ADD CONSTRAINT OPG_CTT_CONTENT_FK FOREIGN KEY (CONTENT_ID) REFERENCES CI_CONTENT (ID) ON DELETE CASCADE;
CREATE INDEX ci_obj_privs_grantee_idx ON ci_object_privs_granted ( grantee_id );
CREATE INDEX ci_obj_privs_content_idx ON ci_object_privs_granted ( content_id );
CREATE INDEX ci_obj_privs_pmask_idx ON ci_object_privs_granted ( privilege_mask );

\echo creating trigger remove_stale_locks...
CREATE OR REPLACE FUNCTION remove_stale_locks() RETURNS TRIGGER AS '
BEGIN
    UPDATE ci_content
    SET locked_by_id         = NULL
       ,locked_by_lastname   = NULL
       ,locked_by_middlename = NULL
       ,locked_by_firstname  = NULL
       ,locked_time          = NULL
    WHERE locked_by_id  IS NOT NULL
      AND NOT EXISTS (SELECT 1
                      FROM ci_sessions
                      WHERE user_id = locked_by_id);
    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER remove_stale_locks AFTER DELETE ON ci_sessions
       EXECUTE PROCEDURE remove_stale_locks();

ALTER TABLE cilib_authors ADD  image_url VARCHAR(250);
ALTER TABLE cilib_authors alter column image_url SET DEFAULT '';

ALTER TABLE ci_object_types ADD is_mailable SMALLINT;
ALTER TABLE ci_object_types alter column is_mailable SET DEFAULT 0;

\echo Adding ci_objects.content_length column
ALTER TABLE ci_content ADD content_length INTEGER;

\echo Setting content_length across ci_content (May take a while)
UPDATE ci_content set content_length = COALESCE( octet_length(body), octet_length(binfile), 0 );

\echo creating trigger update_content_length...
CREATE OR REPLACE FUNCTION update_content_length() RETURNS TRIGGER AS '
BEGIN
    IF NEW.content_length ISNULL OR NEW.content_length = OLD.content_length THEN
        NEW.content_length := COALESCE( octet_length(NEW.body), octet_length(NEW.binfile), 0 );
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER update_content_length BEFORE UPDATE ON ci_content
       FOR EACH ROW EXECUTE PROCEDURE update_content_length();

\echo Dropping view ci_content_loblength
DROP VIEW ci_content_loblength;

\echo updating trigger location_path_update...
CREATE OR REPLACE FUNCTION location_path_update(INTEGER, TEXT, TEXT) RETURNS BOOLEAN AS '
DECLARE
    parent_id_in ALIAS FOR $1;
    new_location_in ALIAS FOR $2;
    old_location_path_in ALIAS FOR $3;

    new_location_path TEXT;

BEGIN
    SELECT INTO new_location_path location_path_make(parent_id_in,new_location_in);

    UPDATE ci_documents
        SET location_path =
            REPLACE (location_path, old_location_path_in, new_location_path)
    WHERE location_path = old_location_path_in
          OR location_path LIKE old_location_path_in || ''/%'';

    RETURN TRUE;

END;
' LANGUAGE plpgsql;

\echo creating additional indexes for ci_documents and ci_content
CREATE INDEX ci_doc_locp_idx ON ci_documents ( location_path );
CREATE INDEX ci_ctt_lmts_idx ON ci_content ( last_modification_timestamp );
CREATE INDEX ci_ctt_cts_idx ON ci_content ( creation_timestamp );

\echo some audio/video data formats
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MP3', 'audio/mpeg', 'mp3' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'M4A', 'audio/x-m4a', 'm4a' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MP4', 'video/mp4', 'mp4' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'M4V', 'video/x-m4v', 'm4v' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix ) 
       VALUES ( nextval('ci_data_formats_id_seq'), 'MOV', 'video/quicktime', 'mov' );
