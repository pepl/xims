-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\echo creating nested set functions, triggers and rule...

CREATE OR REPLACE FUNCTION insert_into_tree() RETURNS TRIGGER AS '
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

CREATE TRIGGER ci_doc_lftrgt_ins BEFORE INSERT ON ci_documents
    FOR EACH ROW EXECUTE PROCEDURE insert_into_tree();

CREATE OR REPLACE FUNCTION close_gap() RETURNS TRIGGER AS '
DECLARE
    maxrgt INTEGER;
BEGIN
    SELECT INTO maxrgt max(rgt)+2 FROM ci_documents;
    UPDATE ci_documents 
      SET lft = CASE WHEN lft > OLD.lft
                     THEN lft - (OLD.rgt - OLD.lft + 1) + maxrgt
                     ELSE lft END,
          rgt = CASE WHEN rgt > OLD.rgt
                     THEN rgt - (OLD.rgt - OLD.lft + 1 )
                     ELSE rgt END;
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER ci_doc_lftrgt_del AFTER DELETE ON ci_documents
    FOR EACH ROW EXECUTE PROCEDURE close_gap();

CREATE OR REPLACE FUNCTION move_tree(INTEGER, INTEGER, INTEGER) RETURNS BOOLEAN AS '
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

CREATE OR REPLACE RULE move_rule AS  
  ON UPDATE TO ci_documents
     WHERE old.parent_id <> new.parent_id
  DO
( SELECT move_tree(old.lft, old.rgt, new.parent_id);
);

