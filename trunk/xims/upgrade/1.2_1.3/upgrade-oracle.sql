PROMPT Extending cisimpledb_member_properties.regex column
ALTER TABLE cisimpledb_member_properties MODIFY (regex VARCHAR2(2048))
/

PROMPT Adding new attribute ci_content.status_checked_timestamp
ALTER TABLE CI_CONTENT ADD STATUS_CHECKED_TIMESTAMP DATE
/

PROMPT Adding new attribute ci_content.deletionmark_timestamp
ALTER TABLE CI_CONTENT ADD DELETIONMARK_TIMESTAMP DATE
/

PROMPT Adding Trigger on ci_sessions to remove stale locks
CREATE OR REPLACE TRIGGER "CI00"."REMOVE_STALE_LOCKS" 
  AFTER
    DELETE
  ON ci_sessions
BEGIN
    UPDATE ci_content c
    SET locked_by_id         = NULL
       ,locked_by_lastname   = NULL
       ,locked_by_middlename = NULL
       ,locked_by_firstname  = NULL
       ,locked_time          = NULL
    WHERE locked_by_id  IS NOT NULL      
      AND NOT EXISTS (SELECT 1 
                      FROM ci_sessions s 
                      WHERE s.user_id = c.locked_by_id);
END;
/

PROMPT Adding new attribute cilib_authors.image_url
ALTER TABLE CILIB_AUTHORS ADD IMAGE_URL VARCHAR2(250) DEFAULT ''
/

PROMPT Adding new attribute ci_object_types.is_mailable
ALTER TABLE CI_OBJECT_TYPES ADD IS_MAILABLE NUMBER(1,0) DEFAULT 0
/

PROMPT Adding new attribute ci_content.content_length
ALTER TABLE CI_CONTENT ADD CONTENT_LENGTH NUMBER
/

PROMPT Adding CLOB_BYTELENGTH function
@@../../sql/Oracle/function_clob_bytelength.sql

PROMPT Setting content_length accross ci_content (May take a while)
UPDATE CI_CONTENT SET CONTENT_LENGTH = DECODE(NVL(CLOB_BYTELENGTH (body), 0), 0, NVL(DBMS_LOB.getlength (binfile), 0), NVL(CLOB_BYTELENGTH (body), 0))
/

PROMPT Adding Trigger on ci_content to set content_length
CREATE OR REPLACE
TRIGGER update_content_length
  BEFORE UPDATE
  ON ci_content
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
    lv_return BOOLEAN;
BEGIN
    IF NOT UPDATING('CONTENT_LENGTH') THEN
        IF UPDATING('BODY') THEN
            :NEW.content_length := NVL(CLOB_BYTELENGTH(:NEW.body), 0);
        ELSIF UPDATING('BINFILE') THEN
            :NEW.content_length := NVL(DBMS_LOB.getlength(:NEW.binfile), 0);
        END IF;
    END IF;

    lv_return := TRUE;
END;
/

PROMPT Dropping view ci_content_loblength
DROP VIEW ci_content_loblength
/

PROMPT Updating functions and triggers for location_path denormalization
@@../../sql/Oracle/ci_util_location_path.sql

CREATE  INDEX doc_locationp_i
 ON ci_documents
  ( location_path  )
/

