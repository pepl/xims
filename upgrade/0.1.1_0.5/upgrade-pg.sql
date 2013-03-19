ALTER TABLE ci_object_types ADD COLUMN publish_gopublic SMALLINT;
ALTER TABLE ci_object_types ALTER COLUMN publish_gopublic SET DEFAULT 0;
UPDATE ci_object_types SET publish_gopublic = 0;
UPDATE ci_object_types SET publish_gopublic = 1 WHERE name = 'AnonDiscussionForum';
