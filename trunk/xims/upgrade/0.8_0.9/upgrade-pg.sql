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
