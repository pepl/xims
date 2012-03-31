\echo adding new VLibrary ObjectTypes
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, publish_gopublic, is_objectroot, is_davgetable, davprivval, is_mailable)
       VALUES ( nextval('ci_object_types_id_seq'), 'Gallery',  1, 1, 0, null, 0, 0, 1, 1, 0  );

\echo setting marked_deleted from NULL to 0
update ci_content set marked_deleted = 0 where marked_deleted is null;
alter table ci_content alter column marked_deleted set default 0;

\echo creating table  'ci_user_prefs'
CREATE TABLE CI_USER_PREFS
(
  ID SERIAL PRIMARY KEY
, PROFILE_TYPE VARCHAR(20) DEFAULT 'standard' NOT NULL
, SKIN VARCHAR(20) DEFAULT 'default' NOT NULL
, PUBLISH_AT_SAVE SMALLINT DEFAULT 0 NOT NULL
, CONTAINERVIEW_SHOW VARCHAR(20) DEFAULT 'title' NOT NULL
)
;

GRANT SELECT
   ON ci_user_prefs
   TO ximsrun
;

GRANT UPDATE
   ON ci_user_prefs
   TO ximsrun
;


GRANT INSERT, UPDATE, DELETE
   ON ci_user_prefs
   TO ximsrun
;
