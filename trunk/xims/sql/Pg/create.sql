-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\set ECHO          queries

-- drop an possibly existing db

\set ON_ERROR_STOP yes

-- connect to the newly created ximsdb

\connect xims

SET SESSION AUTHORIZATION 'xims';

-- begin transaction
BEGIN WORK;


\echo creating table 'ci_data_formats'
CREATE TABLE ci_data_formats
 (mime_type  VARCHAR(100) NOT NULL
 ,id         SERIAL       PRIMARY KEY
 ,name       VARCHAR(40)  NOT NULL
 ,suffix     VARCHAR(5)
 )
;


\echo creating table 'ci_languages'
CREATE TABLE ci_languages
 (id       SERIAL      PRIMARY KEY
 ,code     VARCHAR(6)  NOT NULL
 ,fullname VARCHAR(40) NOT NULL
 )
;


COMMENT ON COLUMN ci_languages.code
        IS 'values: iana-codes'
;


\echo creating table 'ci_object_types'
CREATE TABLE ci_object_types
 (id               SERIAL      PRIMARY KEY
 ,name             VARCHAR(40) NOT NULL
 ,is_fs_container  SMALLINT DEFAULT 0
 ,is_xims_data     SMALLINT DEFAULT 0
 ,redir_to_self    SMALLINT DEFAULT 1
 ,publish_gopublic SMALLINT DEFAULT 0
 ,parent_id        INTEGER  REFERENCES ci_object_types ( id )
                            ON DELETE CASCADE
 ,is_objectroot    SMALLINT DEFAULT 0
 ,is_davgetable    SMALLINT DEFAULT 0
 ,davprivval       NUMERIC(32,0)
 ,is_mailable      SMALLINT DEFAULT 0
 ,menu_level       SMALLINT DEFAULT 0
 )
;

\echo creating table 'ci_users_roles'
CREATE TABLE ci_users_roles
 (password            VARCHAR(60)
 ,enabled             SMALLINT
 ,admin               SMALLINT
 ,id                  SERIAL        PRIMARY KEY
 ,system_privs_mask   NUMERIC(32,0) NOT NULL
 ,name                VARCHAR(30)   UNIQUE NOT NULL
 ,lastname            VARCHAR(90)   NOT NULL
 ,middlename          VARCHAR(30)
 ,firstname           VARCHAR(90)
 ,email               VARCHAR(80)
 ,url                 VARCHAR(250)
 ,object_type         SMALLINT      NOT NULL
 ,dav_otprivs_mask    NUMERIC(32,0)
 )
;


COMMENT ON COLUMN ci_users_roles.object_type
        IS '0 => user, 1 => role'
;

\echo creating table  'ci_user_prefs'
CREATE TABLE CI_USER_PREFS 
(
  ID SERIAL PRIMARY KEY
, PROFILE_TYPE VARCHAR(20) DEFAULT 'standard' NOT NULL 
, SKIN VARCHAR(20) DEFAULT 'default' NOT NULL 
, PUBLISH_AT_SAVE INTEGER DEFAULT 0 NOT NULL 
, CONTAINERVIEW_SHOW VARCHAR(20) DEFAULT 'title' NOT NULL 
)
; 


\echo creating table 'ci_roles_granted'
CREATE TABLE ci_roles_granted
 (id           INTEGER          REFERENCES ci_users_roles ( id )
 ,grantor_id   INTEGER NOT NULL REFERENCES ci_users_roles ( id )
 ,grantee_id   INTEGER NOT NULL REFERENCES ci_users_roles ( id )
 ,role_master  SMALLINT DEFAULT 0
 ,default_role SMALLINT DEFAULT 0
 )
;

\echo creating index ci_roles_granted_grantee_idx...
CREATE INDEX ci_roles_granted_grantee_idx
       ON ci_roles_granted ( grantee_id )
;

COMMENT ON COLUMN ci_roles_granted.role_master
        IS 'if 1, grantee has the right to manage role-membership of this role'
;

COMMENT ON COLUMN ci_roles_granted.default_role
        IS 'will be used to specify the roles granted which are granted view priv in setdefaultgrants'
;


\echo creating table 'ci_object_type_privs'
CREATE TABLE ci_object_type_privs
 (grantee_id     INTEGER NOT NULL REFERENCES ci_users_roles ( id )
 ,grantor_id     INTEGER NOT NULL REFERENCES ci_users_roles ( id )
 ,object_type_id INTEGER NOT NULL REFERENCES ci_object_types( id )
                                  ON DELETE CASCADE
 ,userselection  SMALLINT
 )
;


\echo creating index ci_obj_type_privs_grantee_idx...
CREATE INDEX ci_obj_type_privs_grantee_idx
       ON ci_object_type_privs ( grantee_id )
;

\echo creating table 'ci_sessions'
CREATE TABLE ci_sessions
 (id                    SERIAL       PRIMARY KEY
 ,session_id            VARCHAR(60)  NOT NULL UNIQUE
 ,user_id               INTEGER      REFERENCES ci_users_roles ( id )
 ,attributes            VARCHAR(200)
 ,host                  VARCHAR(90)  NOT NULL
 ,last_access_timestamp TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL
 ,creation_timestamp    TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL
 ,salt                  VARCHAR(40)
 ,token                 VARCHAR(40)
 ,auth_module           VARCHAR(50)  NOT NULL
 )
;


\echo creating table 'ci_documents'
CREATE TABLE ci_documents
 (location          VARCHAR(256)
 ,document_status   VARCHAR(100)
 ,id                SERIAL       PRIMARY KEY
 ,parent_id         INTEGER      REFERENCES ci_documents ( id )
                                 ON DELETE CASCADE
 ,object_type_id    INTEGER      NOT NULL
                                 REFERENCES ci_object_types ( id )
 ,department_id     INTEGER      NOT NULL
                                 REFERENCES ci_documents( id )
                                 ON DELETE NO ACTION
                                 DEFERRABLE
                                 INITIALLY DEFERRED
 ,data_format_id    INTEGER      NOT NULL
                                 REFERENCES ci_data_formats ( id )
 ,symname_to_doc_id INTEGER      REFERENCES ci_documents( id )
                                 ON DELETE cascade
 ,position          INTEGER
 ,location_path     TEXT
 )
;


COMMENT ON COLUMN ci_documents.position
        IS 'for positioning in the parent_id container-context'
;

\echo Adding check constraint parent_id != id on ci_documents
ALTER TABLE ci_documents 
      ADD CONSTRAINT DOC_PARENT_ISNT_DOC 
      CHECK (parent_id != id);

\echo creating indices on ci_documents
-- found some queries with 'in( parent_id,  )' conditions
-- thence default btree
CREATE INDEX ci_documents_par_id_idx
       ON ci_documents ( parent_id )
;

CREATE INDEX ci_doc_locp_idx ON ci_documents ( location_path );

\echo creating table 'ci_content'
CREATE TABLE ci_content
 (binfile                       BYTEA
 ,last_modification_timestamp   TIMESTAMP(0)  WITHOUT TIME ZONE  DEFAULT now() NOT NULL
 ,notes                         VARCHAR(1000)
 ,marked_new                    SMALLINT      DEFAULT 0 NOT NULL
 ,id                            SERIAL        PRIMARY KEY
 ,locked_time                   TIMESTAMP(0)  WITHOUT TIME ZONE     -- should be locked_timestamp !!!
 ,abstract                      VARCHAR(2000)
 ,body                          TEXT
 ,title                         VARCHAR(400)  NOT NULL
 ,nav_title                     VARCHAR(60)
 ,nav_hide                      SMALLINT      DEFAULT 0 NOT NULL
 ,keywords                      VARCHAR(200)
 ,status                        VARCHAR(100)
 ,status_checked_timestamp      TIMESTAMP(0)  WITHOUT TIME ZONE
 ,creation_timestamp            TIMESTAMP(0)  WITHOUT TIME ZONE  DEFAULT now() NOT NULL
 ,valid_from_timestamp          TIMESTAMP(0)  WITHOUT TIME ZONE  DEFAULT now()
 ,valid_to_timestamp            TIMESTAMP(0)  WITHOUT TIME ZONE
 ,attributes                    VARCHAR(256)
 ,locked_by_id                  INTEGER       REFERENCES ci_users_roles( id )
 ,style_id                      INTEGER       REFERENCES ci_content( id )
 ,script_id                     INTEGER       REFERENCES ci_content( id )
 ,schema_id                     INTEGER       REFERENCES ci_content( id )
 ,language_id                   INTEGER       REFERENCES ci_languages( id )
 ,last_modified_by_id           INTEGER       NOT NULL REFERENCES ci_users_roles( id )
 ,owned_by_id                   INTEGER       NOT NULL REFERENCES ci_users_roles( id )
 ,created_by_id                 INTEGER       NOT NULL REFERENCES ci_users_roles( id )
 ,css_id                        INTEGER       REFERENCES ci_content( id )
 ,image_id                      INTEGER       REFERENCES ci_content( id )
 ,feed_id                       INTEGER       REFERENCES ci_content( id )
 ,document_id                   INTEGER       NOT NULL REFERENCES ci_documents(id) ON DELETE CASCADE
 ,published                     SMALLINT      DEFAULT 0 NOT NULL
 ,last_publication_timestamp    TIMESTAMP(0)  WITHOUT TIME ZONE
 ,last_published_by_id          INTEGER       REFERENCES ci_users_roles( id )
 ,marked_deleted                SMALLINT      DEFAULT 0 NOT NULL
 ,deletionmark_timestamp        TIMESTAMP(0)  WITHOUT TIME ZONE
 ,locked_by_lastname            VARCHAR(90)
 ,locked_by_middlename          VARCHAR(30)
 ,locked_by_firstname           VARCHAR(90)
 ,last_modified_by_lastname     VARCHAR(90)
 ,last_modified_by_middlename   VARCHAR(30)
 ,last_modified_by_firstname    VARCHAR(90)
 ,owned_by_lastname             VARCHAR(90)
 ,owned_by_middlename           VARCHAR(30)
 ,owned_by_firstname            VARCHAR(90)
 ,created_by_lastname           VARCHAR(90)
 ,created_by_middlename         VARCHAR(30)
 ,created_by_firstname          VARCHAR(90)
 ,last_published_by_lastname    VARCHAR(90)
 ,last_published_by_middlename  VARCHAR(30)
 ,last_published_by_firstname   VARCHAR(90)
 ,data_format_name              VARCHAR(40)
 ,content_length                INTEGER       DEFAULT 0
 )
;


COMMENT ON COLUMN ci_content.keywords
        IS 'values ";"-separated'
;


\echo creating index on ci_content...
CREATE INDEX ci_content_doc_id_idx
       ON ci_content ( document_id )
;

\echo creating index on ci_content...
CREATE INDEX ci_content_image_id_idx
       ON ci_content ( image_id )
;

CREATE INDEX ci_ctt_lmts_idx ON ci_content ( last_modification_timestamp );
CREATE INDEX ci_ctt_cts_idx ON ci_content ( creation_timestamp );

\echo creating trigger remove_stale_locks...
CREATE OR REPLACE FUNCTION remove_stale_locks() RETURNS TRIGGER AS '
BEGIN
    UPDATE ci_content
    SET locked_by_id         = NULL
       ,locked_by_lastname   = NULL
       ,locked_by_middlename = NULL
       ,locked_by_firstname  = NULL
       ,locked_time          = NULL
    WHERE locked_by_id  IS NOT NULL
      AND NOT EXISTS (SELECT 1
                      FROM ci_sessions
                      WHERE user_id = locked_by_id);
    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER remove_stale_locks AFTER DELETE ON ci_sessions
       EXECUTE PROCEDURE remove_stale_locks();


\echo creating trigger update_content_length...
CREATE OR REPLACE FUNCTION update_content_length() RETURNS TRIGGER AS '
BEGIN
    IF NEW.content_length ISNULL OR NEW.content_length = OLD.content_length THEN
        NEW.content_length := COALESCE( octet_length(NEW.body), octet_length(NEW.binfile), 0 );
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER update_content_length BEFORE UPDATE ON ci_content
       FOR EACH ROW EXECUTE PROCEDURE update_content_length();


\echo creating table 'ci_object_privs_granted'
CREATE TABLE ci_object_privs_granted
 (privilege_mask NUMERIC(32,0) NOT NULL
 ,grantee_id     INTEGER       NOT NULL REFERENCES ci_users_roles(id)     ON DELETE CASCADE
 ,grantor_id     INTEGER       NOT NULL REFERENCES ci_users_roles(id)     ON DELETE CASCADE
 ,content_id     INTEGER       NOT NULL REFERENCES ci_content(id)     ON DELETE CASCADE
 )
;

\echo creating indices on 'ci_object_privs_granted'
CREATE INDEX ci_obj_privs_grantee_idx ON ci_object_privs_granted ( grantee_id );
CREATE INDEX ci_obj_privs_content_idx ON ci_object_privs_granted ( content_id );
CREATE INDEX ci_obj_privs_pmask_idx ON ci_object_privs_granted ( privilege_mask );

\echo creating table 'ci_bookmarks'
CREATE TABLE ci_bookmarks
 (id         SERIAL   PRIMARY KEY
 ,content_id INTEGER  NOT NULL REFERENCES ci_content(id)     ON DELETE CASCADE
 ,owner_id   INTEGER  NOT NULL REFERENCES ci_users_roles(id) ON DELETE CASCADE
 ,stdhome    SMALLINT DEFAULT 0
 )
;


\echo creating table ci_mime_type_aliases
CREATE TABLE ci_mime_type_aliases
 (id             SERIAL PRIMARY KEY
 ,data_format_id INTEGER     REFERENCES ci_data_formats ( id )
                             ON DELETE CASCADE
 ,mime_type      VARCHAR(40) NOT NULL UNIQUE
 )
;


COMMENT ON COLUMN ci_object_types.is_fs_container
        IS 'is_fs_container indicates whether this object-type should be exported as folder to te filesystem'
;


COMMENT ON column ci_object_types.redir_to_self
        IS 'redir_to_self indicates whether redirection after editing should go to the object self or to the parent object'
;

COMMENT ON COLUMN ci_object_types.davprivval
        IS 'davprivval is used to determine the dav object type privileges for users (dav_otprivs_mask)'
;

-- Add table for the questionnaire results
\echo creating table 'ci_questionnaire_results'
CREATE TABLE ci_questionnaire_results
  (document_id      INTEGER      NOT NULL
                                 REFERENCES ci_documents ( id )
                                 ON DELETE RESTRICT
                                 ON UPDATE RESTRICT
                                 NOT DEFERRABLE
                                 INITIALLY IMMEDIATE

  ,tan              VARCHAR(50)  NOT NULL
  ,question_id      VARCHAR(50)  NOT NULL
  ,answer           TEXT
  ,answer_timestamp TIMESTAMP    DEFAULT now()    NOT NULL
  ,id               SERIAL       PRIMARY KEY
);
REVOKE ALL ON TABLE ci_questionnaire_results FROM PUBLIC;
GRANT ALL ON TABLE ci_questionnaire_results TO xims;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE ci_questionnaire_results TO ximsrun;


--functions as compatability-wrappers for Oracles vs. PostgreSQL
--one for each sequence :-/
\echo creating functions....
CREATE FUNCTION ci_bookmarks_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_bookmarks_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_content_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_content_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_data_formats_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_data_formats_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_documents_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_documents_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_languages_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_languages_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_object_types_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_object_types_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_sessions_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_sessions_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_users_roles_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_users_roles_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE FUNCTION ci_mime_aliases_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''ci_mime_type_aliases_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE FUNCTION ci_quest_results_id_seq_nval() RETURNS INTEGER
    AS 'BEGIN
          RETURN nextval(''ci_questionnaire_results_id_seq'');
        END;'
    LANGUAGE 'plpgsql'
;

CREATE FUNCTION ci_user_prefs_id_seq_nval() RETURNS INTEGER
    AS 'BEGIN
          RETURN nextval(''ci_user_prefs_id_seq'');
        END;'
    LANGUAGE 'plpgsql'
;

-- we have a user 'xims' who OWNS the db and its
-- objects, having full control over them.
-- ximsrun is the user XIMS connects as at runtime,
-- least possible privileges here.
GRANT SELECT
   ON  ci_bookmarks
      ,ci_bookmarks_id_seq
      ,ci_content
      ,ci_content_id_seq
      ,ci_data_formats
      ,ci_data_formats_id_seq
      ,ci_documents
      ,ci_documents_id_seq
      ,ci_languages
      ,ci_languages_id_seq
      ,ci_mime_type_aliases
      ,ci_mime_type_aliases_id_seq
      ,ci_object_privs_granted
      ,ci_object_type_privs
      ,ci_object_types
      ,ci_object_types_id_seq
      ,ci_roles_granted
      ,ci_sessions
      ,ci_sessions_id_seq
      ,ci_users_roles
      ,ci_users_roles_id_seq
      ,ci_questionnaire_results_id_seq
      ,ci_user_prefs
   TO ximsrun
;


GRANT UPDATE
   ON  ci_bookmarks_id_seq
      ,ci_content_id_seq
      ,ci_documents_id_seq
      ,ci_sessions_id_seq
      ,ci_users_roles_id_seq
      ,ci_questionnaire_results_id_seq
      ,ci_user_prefs
   TO ximsrun
;


GRANT INSERT, UPDATE, DELETE
   ON  ci_bookmarks
      ,ci_content
      ,ci_documents
      ,ci_object_privs_granted
      ,ci_object_type_privs
      ,ci_object_types
      ,ci_roles_granted
      ,ci_sessions
      ,ci_users_roles
      ,ci_user_prefs
   TO ximsrun
;


-- commit
END WORK;
