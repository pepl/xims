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