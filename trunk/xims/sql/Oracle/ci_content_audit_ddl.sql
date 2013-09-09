-- Copyright (c) 2002-2013 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

--DROP TABLE CI_CONTENTAUDIT;

----
-- Tables
----

PROMPT Creating Table 'CI_CONTENTAUDIT'
CREATE TABLE CI_CONTENTAUDIT(
 ID                 NUMBER          NOT NULL
 ,CONTENT_ID        NUMBER
 ,USER_ID           NUMBER
 ,ACTION            VARCHAR2(20)    NOT NULL
 ,TIMESTAMP DATE DEFAULT SYSDATE    NOT NULL
)
/

COMMENT ON COLUMN ci_contentaudit.action IS 'one of "CREATE", "UPDATE", "TRASHCAN", "UNDELETE"'
/

----
-- Indices
----

PROMPT Creating Index 'CAU_CTT_FK_I'
CREATE INDEX CAU_CTT_FK_I ON CI_CONTENTAUDIT
 (CONTENT_ID)
/

PROMPT Creating Index 'CAU_USR_FK_I'
CREATE INDEX CAU_USR_FK_I ON CI_CONTENTAUDIT
 (USER_ID)
/


----
-- Constraints
----

PROMPT Creating Primary Key on 'CI_CONTENTAUDIT'
ALTER TABLE CI_CONTENTAUDIT
 ADD (CONSTRAINT CAU_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Foreign Key on 'CI_CONTENTAUDIT'
ALTER TABLE CI_CONTENTAUDIT
 ADD (CONSTRAINT CAU_CTT_ID_FK FOREIGN KEY
       (CONTENT_ID) REFERENCES CI_CONTENT (ID) ON DELETE SET NULL
)
/

PROMPT Creating Foreign Key on 'CI_CONTENTAUDIT'
ALTER TABLE CI_CONTENTAUDIT
 ADD (CONSTRAINT CAU_USR_ID_FK FOREIGN KEY
       (USER_ID) REFERENCES CI_USER_ROLES (ID) ON DELETE SET NULL
)
/

----
-- Sequences
----

PROMPT Creating Sequence 'CAU_SEQ'
-- DROP SEQUENCE CAU_SEQ;
CREATE SEQUENCE CAU_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

----
-- Triggers
----

CREATE OR REPLACE TRIGGER contentaudit_insert
 AFTER
   INSERT
 ON ci_content
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    IF :NEW.title <> '.diff_to_second_last' THEN
        INSERT INTO ci_contentaudit (id, content_id, user_id, action) VALUES (cau_seq.nextval, :NEW.id, :NEW.created_by_id, 'CREATE');
    END IF;
    lv_return := TRUE;
END;
/


CREATE OR REPLACE TRIGGER contentaudit_update
 AFTER
   UPDATE
 ON ci_content
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    IF :NEW.title <> '.diff_to_second_last' THEN
        IF :OLD.marked_deleted = 0 AND :NEW.marked_deleted = 1 THEN
            INSERT INTO ci_contentaudit (id, content_id, action) VALUES (cau_seq.nextval, :NEW.id, 'TRASHCAN');
        ELSIF :OLD.marked_deleted = 1 AND :NEW.marked_deleted = 0 THEN
            INSERT INTO ci_contentaudit (id, content_id, action) VALUES (cau_seq.nextval, :NEW.id, 'UNDELETE');
        ELSIF :OLD.published = 0 AND :NEW.published = 1 THEN
            INSERT INTO ci_contentaudit (id, content_id, user_id, action) VALUES (cau_seq.nextval, :NEW.id, :NEW.last_published_by_id, 'PUBLISH');
        ELSIF :OLD.published = 1 AND :NEW.published = 0 THEN
            INSERT INTO ci_contentaudit (id, content_id, user_id, action) VALUES (cau_seq.nextval, :NEW.id, :NEW.last_published_by_id, 'UNPUBLISH');
        ELSIF :OLD.last_modification_timestamp <> :NEW.last_modification_timestamp THEN
            INSERT INTO ci_contentaudit (id, content_id, user_id, action) VALUES (cau_seq.nextval, :NEW.id, :NEW.last_modified_by_id, 'UPDATE');
        END IF;
    END IF;
    lv_return := TRUE;
END;
/

