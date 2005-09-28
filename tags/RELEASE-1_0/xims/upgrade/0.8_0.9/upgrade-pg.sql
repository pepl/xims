\echo Adding IS_OBJECTROOT column on 'CI_OBJECT_TYPES'
ALTER TABLE ci_object_types ADD COLUMN IS_OBJECTROOT SMALLINT;
ALTER TABLE ci_object_types ALTER COLUMN IS_OBJECTROOT SET DEFAULT 0;

\echo Inserting new object type JavaScript
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'JavaScript', 0, 1, 1, 0 );

INSERT INTO ci_mime_type_aliases ( id, data_format_id, mime_type )
       VALUES ( nextval('ci_mime_type_aliases_id_seq'), 16, 'application/zip' );

-- location_path functions, triggers,  and rules
CREATE OR REPLACE FUNCTION location_path_make(INTEGER, TEXT) RETURNS TEXT AS '
DECLARE
    parent_id_in ALIAS FOR $1;
    new_location_in ALIAS FOR $2;

    parent_location_path TEXT;
    new_location_path TEXT;

BEGIN
    -- catch /root, otherwise parent_location_path would be NULL and concatenation would not work
    IF parent_id_in = 1 THEN
        parent_location_path := '''';
    ELSE
        -- do we have one and only one parent_id, hope so ...
        SELECT INTO parent_location_path location_path FROM ci_documents
            WHERE id = parent_id_in;
    END IF;

    new_location_path := parent_location_path || ''/'' || new_location_in;

    RETURN new_location_path;
END;
' LANGUAGE plpgsql;

-- write location_path values to existing data in ci_documents
SELECT sync_location_path();
