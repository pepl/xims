CREATE OR REPLACE
PACKAGE ci_util IS
    FUNCTION location_path_update(parent_id_in IN NUMBER, new_location_in IN VARCHAR2, old_location_path_in IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION location_path_insert(parent_id_in IN NUMBER, new_location_in IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION sync_location_path RETURN BOOLEAN;
END ci_util;
/

CREATE OR REPLACE
PACKAGE BODY ci_util IS
    FUNCTION location_path_update(parent_id_in IN NUMBER, new_location_in IN VARCHAR2, old_location_path_in IN VARCHAR2) RETURN VARCHAR2 IS
       PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR parent_cur IS
        SELECT location_path
        FROM ci_documents
        WHERE id = parent_id_in;
    parent_location_path VARCHAR2(4000);
    new_location_path VARCHAR2(4000);
    BEGIN
      OPEN parent_cur;
          FETCH parent_cur INTO parent_location_path;
      CLOSE parent_cur;

      new_location_path := parent_location_path || '/' || new_location_in;

      UPDATE ci_documents
         SET location_path =
                  REPLACE (location_path, old_location_path_in, new_location_path)
      WHERE location_path != old_location_path_in AND location_path LIKE old_location_path_in || '/%';
      COMMIT;

      RETURN new_location_path;
    END;

    FUNCTION location_path_insert(parent_id_in IN NUMBER, new_location_in IN VARCHAR2) RETURN VARCHAR2 IS
       PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR parent_cur IS
        SELECT location_path
        FROM ci_documents
        WHERE id = parent_id_in;
    parent_location_path VARCHAR2(4000);
    new_location_path VARCHAR2(4000);
    BEGIN
      OPEN parent_cur;
          FETCH parent_cur INTO parent_location_path;
      CLOSE parent_cur;

      new_location_path := parent_location_path || '/' || new_location_in;

      RETURN new_location_path;
    END;

    FUNCTION sync_location_path RETURN BOOLEAN IS
       CURSOR tree_cur IS
        SELECT id, location, parent_id
        FROM ci_documents
        CONNECT BY PRIOR id=parent_id and id != 1
        START WITH id = 1;
    tree_rec tree_cur%ROWTYPE;
    BEGIN

      UPDATE ci_documents
          SET location_path = ''
      WHERE id = 1;

      FOR tree_rec IN tree_cur LOOP
          IF tree_rec.id != 1 THEN
              UPDATE ci_documents
                  SET location_path = (SELECT location_path||'/'||tree_rec.location FROM ci_documents WHERE id = tree_rec.parent_id)
              WHERE id = tree_rec.id;
          END IF;
      END LOOP;
      RETURN TRUE;
    END;

END ci_util;
/

CREATE OR REPLACE TRIGGER ci_doc_location_path_update
 BEFORE
   UPDATE OF location, parent_id
 ON ci_documents
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
 WHEN (new.location <> old.location or new.parent_id <> old.parent_id)
DECLARE
    lv_return BOOLEAN;
BEGIN
    :NEW.location_path := ci_util.location_path_update(:NEW.parent_id, :NEW.location, :OLD.location_path);
    lv_return := TRUE;
END;
/

CREATE OR REPLACE TRIGGER ci_doc_location_path_insert
 BEFORE
   INSERT
 ON ci_documents
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    :NEW.location_path := ci_util.location_path_insert(:NEW.parent_id, :NEW.location);
    lv_return := TRUE;
END;
/
