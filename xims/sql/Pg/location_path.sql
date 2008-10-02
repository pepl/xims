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

CREATE OR REPLACE RULE location_path_rule AS
       ON UPDATE TO ci_documents
       WHERE (OLD.location <> NEW.location OR OLD.parent_id <> NEW.parent_id)
       DO (
            SELECT location_path_update(NEW.parent_id, NEW.location, OLD.location_path);
          );

CREATE OR REPLACE FUNCTION location_path_insert() RETURNS TRIGGER AS '
BEGIN
    SELECT INTO NEW.location_path location_path_make(NEW.parent_id,NEW.location);
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER location_path_insert BEFORE INSERT ON ci_documents
       FOR EACH ROW EXECUTE PROCEDURE location_path_insert();


CREATE OR REPLACE FUNCTION sync_location_path() RETURNS BOOLEAN AS '
DECLARE
    tree_rec RECORD;
    curr_location TEXT;
BEGIN
    UPDATE ci_documents
        SET location_path = ''''
    WHERE id = 1;

    FOR tree_rec IN SELECT * FROM connectby(''ci_documents'',''id'',''parent_id'',''1'',0)
        AS t(id INTEGER, parent_id INTEGER, level INTEGER) LOOP
        IF tree_rec.id != 1 THEN
            SELECT INTO curr_location location FROM ci_documents WHERE id = tree_rec.id;
            UPDATE ci_documents
                SET location_path = (SELECT location_path||''/''||curr_location FROM ci_documents
                WHERE id = tree_rec.parent_id)
            WHERE id = tree_rec.id;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
' LANGUAGE plpgsql;
