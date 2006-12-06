\echo Extending cisimpledb_member_properties.regex column
ALTER TABLE cisimpledb_member_properties ADD nregex VARCHAR(2048);
UPDATE cisimpledb_member_properties SET nregex = CAST(regex AS VARCHAR(2048));
ALTER TABLE cisimpledb_member_properties DROP regex;
ALTER TABLE cisimpledb_member_properties RENAME nregex TO regex;

\echo Adding ci_content.status_checked_timestamp
ALTER TABLE ci_content ADD status_checked_timestamp TIMESTAMP(0) WITHOUT TIME ZONE;