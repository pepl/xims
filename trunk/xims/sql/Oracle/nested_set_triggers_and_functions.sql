-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

CREATE OR REPLACE
PACKAGE ci_util IS
    FUNCTION insert_into_tree(id_in IN NUMBER, lft_out OUT NUMBER, rgt_out OUT NUMBER) RETURN BOOLEAN;
    FUNCTION move_tree(clft_in IN NUMBER, crgt_in IN NUMBER, parid_in IN NUMBER, clft_out OUT NUMBER, crgt_out OUT NUMBER) RETURN BOOLEAN;
    FUNCTION close_gap(lft_in IN NUMBER, rgt_in IN NUMBER) RETURN BOOLEAN;
END ci_util;
/

CREATE OR REPLACE
PACKAGE BODY ci_util IS
    FUNCTION insert_into_tree(id_in IN NUMBER, lft_out OUT NUMBER, rgt_out OUT NUMBER) RETURN BOOLEAN IS
       CURSOR tree_cur IS
         SELECT rgt
         FROM ci_documents
         WHERE id = id_in;
    tree_rec tree_cur%ROWTYPE;
    BEGIN
        OPEN tree_cur;
          FETCH tree_cur INTO tree_rec;
            UPDATE ci_documents
              SET lft = CASE WHEN lft > tree_rec.rgt
                             THEN lft + 2
                             ELSE lft END,
                  rgt = CASE WHEN rgt >= tree_rec.rgt
                             THEN rgt + 2
                             ELSE rgt END
            WHERE rgt >= tree_rec.rgt;
            lft_out := tree_rec.rgt;
            rgt_out := tree_rec.rgt + 1;
        CLOSE tree_cur;
        RETURN TRUE;
    END;

    FUNCTION move_tree(clft_in IN NUMBER, crgt_in IN NUMBER, parid_in IN NUMBER, clft_out OUT NUMBER, crgt_out OUT NUMBER) RETURN BOOLEAN IS
    PRAGMA AUTONOMOUS_TRANSACTION;
     CURSOR lft_cur IS
         SELECT lft
         FROM ci_documents
         WHERE id = parid_in;
     parent_lft NUMBER;
     leftbound NUMBER; rightbound NUMBER;
     treeshift NUMBER; cwidth NUMBER;
     leftrange NUMBER; rightrange NUMBER;
    BEGIN
        OPEN lft_cur;
           FETCH lft_cur INTO parent_lft;
        CLOSE lft_cur;

        -- Parent cannot be underneath the child
        IF parent_lft BETWEEN clft_in AND crgt_in THEN
          RETURN FALSE;
        END IF;

        -- Child may already be in the proper place
        IF clft_in = parent_lft+1 THEN
          RETURN FALSE;
        END IF;

        IF clft_in > parent_lft THEN
            treeshift  := parent_lft - clft_in + 1;
            leftbound  := parent_lft + 1;
            rightbound := clft_in - 1;
            cwidth     := crgt_in - clft_in + 1;
            leftrange  := crgt_in;
            rightrange := parent_lft;
        ELSE
            treeshift  := parent_lft - crgt_in;
            leftbound  := crgt_in + 1;
            rightbound := parent_lft;
            cwidth     := clft_in - crgt_in - 1;
            leftrange  := parent_lft + 1;
            rightrange := clft_in;
        END IF;

        UPDATE ci_documents
          SET lft = CASE
                    WHEN lft BETWEEN leftbound AND rightbound THEN lft + cwidth
                    WHEN lft BETWEEN clft_in AND crgt_in THEN lft + treeshift
                    ELSE lft END,
              rgt = CASE
                    WHEN rgt BETWEEN leftbound AND rightbound THEN rgt + cwidth
                    WHEN rgt BETWEEN clft_in AND crgt_in THEN rgt + treeshift
                    ELSE rgt END
        WHERE lft <> clft_in AND rgt <> crgt_in AND (lft < leftrange OR rgt > rightrange);

        COMMIT;

        IF clft_in BETWEEN leftbound AND rightbound THEN
           clft_out := clft_in + cwidth;
        ELSE
           clft_out := clft_in + treeshift;
        END IF;
        IF crgt_in BETWEEN leftbound AND rightbound THEN
           crgt_out := crgt_in + cwidth;
        ELSE
           crgt_out := crgt_in + treeshift;
        END IF;

        RETURN TRUE;
    END;

    FUNCTION close_gap(lft_in IN NUMBER, rgt_in IN NUMBER) RETURN BOOLEAN IS
    BEGIN
        UPDATE ci_documents
          SET lft = CASE WHEN lft > lft_in
                         THEN lft - (rgt_in - lft_in + 1)
                         ELSE lft END,
              rgt = CASE WHEN rgt > rgt_in
                         THEN rgt - (rgt_in - lft_in + 1 )
                         ELSE rgt END;
        RETURN TRUE;
    END;

END ci_util;
/

CREATE OR REPLACE TRIGGER ci_doc_lftrgt_ins
BEFORE INSERT
ON ci_documents
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    lv_return := ci_util.insert_into_tree(:NEW.parent_id,
                                          :NEW.lft,
                                          :NEW.rgt
                                         );
END;
/

CREATE OR REPLACE TRIGGER ci_doc_lftrgt_upd
BEFORE UPDATE
OF parent_id
ON ci_documents
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    lv_return := ci_util.move_tree(:OLD.lft, :OLD.rgt, :NEW.parent_id, :NEW.lft, :NEW.rgt);
END;
/

DROP TABLE ci_documents_del_tmp;
CREATE GLOBAL TEMPORARY TABLE ci_documents_del_tmp (
    lft    number,
    rgt    number)
ON COMMIT DELETE ROWS;
/

CREATE OR REPLACE TRIGGER ci_doc_lftrgt_before_del
BEFORE DELETE
ON ci_documents
REFERENCING OLD AS OLD
FOR EACH ROW
BEGIN
    INSERT INTO ci_documents_del_tmp (lft,rgt)
    VALUES (:OLD.lft,:OLD.rgt);
END;
/

CREATE OR REPLACE TRIGGER ci_doc_lftrgt_after_del
AFTER DELETE
ON ci_documents
DECLARE
    CURSOR tree_cur IS
        SELECT min(lft) lft, max(rgt) rgt
        FROM ci_documents_del_tmp;
    tree_rec tree_cur%ROWTYPE;
    lv_return BOOLEAN;
BEGIN
    OPEN tree_cur;
        FETCH tree_cur INTO tree_rec;
        lv_return := ci_util.close_gap(tree_rec.lft,
                                       tree_rec.rgt
                                      );
    CLOSE tree_cur;
END;
/

