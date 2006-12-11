PROMPT Extending cisimpledb_member_properties.regex column
ALTER TABLE cisimpledb_member_properties MODIFY (regex VARCHAR2(2048))
/

PROMPT Adding new attribute ci_content.status_checked_timestamp
ALTER TABLE CI_CONTENT ADD STATUS_CHECKED_TIMESTAMP DATE
/

