-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\set ECHO          queries
\set ON_ERROR_STOP yes

\connect xims

SET SESSION AUTHORIZATION 'xims';

BEGIN WORK;

\echo creating table 'ci_contentaudit'
CREATE TABLE ci_contentaudit
 (
 id                  SERIAL                PRIMARY KEY
 ,content_id         INTEGER               REFERENCES ci_content     ( id ) ON DELETE SET NULL
 ,user_id            INTEGER               REFERENCES ci_users_roles ( id ) ON DELETE SET NULL
 ,action             VARCHAR(20) NOT NULL
 ,timestamp          TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL
 )
;

COMMENT ON COLUMN ci_contentaudit.action
        IS 'one of "CREATE", "UPDATE", "TRASHCAN", "UNDELETE"'
;

REVOKE ALL ON ci_contentaudit FROM PUBLIC;
GRANT ALL ON ci_contentaudit TO xims;
GRANT INSERT, SELECT, UPDATE ON ci_contentaudit TO ximsrun;
GRANT SELECT, UPDATE ON ci_contentaudit_id_seq TO ximsrun;


CREATE OR REPLACE FUNCTION contentaudit_insert() RETURNS TRIGGER AS '
BEGIN
    IF NEW.title <> ''.diff_to_second_last'' THEN
        INSERT INTO ci_contentaudit (content_id, user_id, action) VALUES (NEW.id, NEW.created_by_id, ''CREATE'');
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER contentaudit_insert AFTER INSERT ON ci_content
       FOR EACH ROW EXECUTE PROCEDURE contentaudit_insert();

CREATE OR REPLACE FUNCTION contentaudit_update() RETURNS TRIGGER AS '
BEGIN
    IF NEW.title <> ''.diff_to_second_last'' THEN
        IF OLD.marked_deleted IS NULL AND NEW.marked_deleted = 1 THEN
            INSERT INTO ci_contentaudit (content_id, action) VALUES (NEW.id, ''TRASHCAN'');
        ELSIF OLD.marked_deleted = 1 AND NEW.marked_deleted IS NULL THEN
            INSERT INTO ci_contentaudit (content_id, action) VALUES (NEW.id, ''UNDELETE'');
        ELSIF OLD.last_modification_timestamp <> NEW.last_modification_timestamp THEN
            INSERT INTO ci_contentaudit (content_id, user_id, action) VALUES (NEW.id, NEW.last_modified_by_id, ''UPDATE'');
        END IF;
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER contentaudit_update AFTER UPDATE ON ci_content
       FOR EACH ROW EXECUTE PROCEDURE contentaudit_update();


COMMIT;
