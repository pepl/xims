-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\echo creating nested set functions, triggers and rule...

--          -
--  INSERT  -
--          -
CREATE OR REPLACE FUNCTION  ci_doc_lftrgt_bi() RETURNS TRIGGER AS '
DECLARE
     parent_rgt INTEGER;
BEGIN
    IF NEW.parent_id IS NULL THEN
        RAISE EXCEPTION ''parent_id cannot be NULL value'';
    END IF;

    SELECT INTO parent_rgt rgt FROM ci_documents WHERE id = NEW.parent_id;

    UPDATE ci_documents
      SET lft = CASE WHEN lft > parent_rgt
                     THEN lft + 2
                     ELSE lft END,
          rgt = CASE WHEN rgt >= parent_rgt
                     THEN rgt + 2
                     ELSE rgt END
    WHERE rgt >= parent_rgt;

    NEW.lft := parent_rgt;
    NEW.rgt := parent_rgt + 1;

    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER ci_doc_lftrgt_bi BEFORE INSERT ON ci_documents
       FOR EACH ROW EXECUTE PROCEDURE ci_doc_lftrgt_bi();


--          -
--  UPDATE  -
--          -
CREATE OR REPLACE FUNCTION ci_doc_move_tree(INTEGER, INTEGER, INTEGER) RETURNS BOOLEAN AS '
DECLARE
    clft  ALIAS FOR $1;
    crgt  ALIAS FOR $2;
    parid ALIAS FOR $3;
    parent_lft INTEGER;
    leftbound  INTEGER; rightbound INTEGER;
    treeshift  INTEGER; cwidth INTEGER;
    leftrange  INTEGER; rightrange INTEGER;
BEGIN
    SELECT INTO parent_lft lft FROM ci_documents WHERE id = parid;

    IF clft > parent_lft THEN 
        treeshift  := parent_lft - clft + 1;
        leftbound  := parent_lft + 1;
        rightbound := clft - 1;
        cwidth     := crgt - clft + 1;
        leftrange  := crgt;
        rightrange := parent_lft;
    ELSE
        treeshift  := parent_lft - crgt;
        leftbound  := crgt + 1;
        rightbound := parent_lft;
        cwidth     := clft - crgt - 1;
        leftrange  := parent_lft + 1;
        rightrange := clft;
    END IF;

    UPDATE ci_documents
      SET lft = CASE
                WHEN lft BETWEEN leftbound AND rightbound THEN lft + cwidth
                WHEN lft BETWEEN clft AND crgt THEN lft + treeshift
                ELSE lft END,
          rgt = CASE
                WHEN rgt BETWEEN leftbound AND rightbound THEN rgt + cwidth
                WHEN rgt BETWEEN clft AND crgt THEN rgt + treeshift
                ELSE rgt END
    WHERE lft < leftrange OR rgt > rightrange;

    RETURN TRUE;
END;
' LANGUAGE 'plpgsql';

--'
CREATE OR REPLACE RULE move_rule AS
       ON UPDATE TO ci_documents
       WHERE old.parent_id <> new.parent_id
       DO ( 
            SELECT ci_doc_move_tree(old.lft, old.rgt, new.parent_id); 
          );


--          -
--  DELETE  -
--          -
CREATE OR REPLACE FUNCTION ci_del_tree(INTEGER) RETURNS BOOLEAN AS '
DECLARE
    cid  ALIAS FOR $1;
    clft  INTEGER;
    crgt  INTEGER;
    gap   INTEGER;
BEGIN
    IF cid IS NULL THEN
        RAISE EXCEPTION ''id cannot be NULL value'';
    END IF;

    SELECT INTO clft lft FROM ci_documents WHERE id = cid;
    SELECT INTO crgt rgt FROM ci_documents WHERE id = cid;

    -- in case select fails (i.e. id nonexistant)
    IF clft IS NULL OR crgt IS NULL THEN
        RAISE EXCEPTION ''id cannot be NULL value'';
    END IF;

    DELETE FROM ci_documents WHERE lft BETWEEN clft AND crgt;
    
    gap := (crgt - clft + 1);
    UPDATE ci_documents
      SET lft = CASE WHEN lft > clft
                     THEN lft - gap 
                     ELSE lft END,
          rgt = CASE WHEN rgt > crgt
                     THEN rgt - gap
                     ELSE rgt END;
    RETURN FOUND;
END;
' LANGUAGE 'plpgsql';

