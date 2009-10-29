ALTER TABLE ci_object_types ADD (publish_gopublic NUMBER(1,0) DEFAULT 0);
UPDATE ci_object_types SET publish_gopublic = 0;
UPDATE ci_object_types SET publish_gopublic = 1 WHERE name = 'AnonDiscussionForum';
