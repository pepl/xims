-- Copyright (c) 2002-2006 The XIMS Project.
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
 (mime_type  VARCHAR(40) NOT NULL
 ,id         SERIAL      PRIMARY KEY
 ,name       VARCHAR(40) NOT NULL
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
 )
;

\echo creating table 'ci_users_roles'
CREATE TABLE ci_users_roles
 (password            VARCHAR(32)
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
 ,session_id            VARCHAR(32)  NOT NULL UNIQUE
 ,user_id               INTEGER      REFERENCES ci_users_roles ( id )
 ,attributes            VARCHAR(200)
 ,host                  VARCHAR(90)  NOT NULL
 ,last_access_timestamp TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL
 ,salt                  INTEGER
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


\echo creating indices on ci_documents
-- found some queries with 'in( parent_id,  )' conditions
-- thence default btree
CREATE INDEX ci_documents_par_id_idx
       ON ci_documents ( parent_id )
;

\echo creating table 'ci_content'
CREATE TABLE ci_content
 (binfile                       BYTEA
 ,last_modification_timestamp   TIMESTAMP(0)  WITHOUT TIME ZONE  DEFAULT now() NOT NULL
 ,notes                         VARCHAR(1000)
 ,marked_new                    SMALLINT
 ,id                            SERIAL        PRIMARY KEY
 ,locked_time                   TIMESTAMP(0)  WITHOUT TIME ZONE     -- should be locked_timestamp !!!
 ,abstract                      VARCHAR(2000)
 ,body                          TEXT
 ,title                         VARCHAR(400)  NOT NULL
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
 ,document_id                   INTEGER       NOT NULL REFERENCES ci_documents(id) ON DELETE CASCADE
 ,published                     SMALLINT
 ,last_publication_timestamp    TIMESTAMP(0)  WITHOUT TIME ZONE
 ,last_published_by_id          INTEGER       REFERENCES ci_users_roles( id )
 ,marked_deleted                SMALLINT
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
 )
;


COMMENT ON COLUMN ci_content.keywords
        IS 'values ";"-separated'
;


\echo creating index on ci_content...
CREATE INDEX ci_content_doc_id_idx
       ON ci_content ( document_id )
;

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

\echo creating view ci_content_loblength...
CREATE VIEW ci_content_loblength (
            binfile
           ,last_modification_timestamp
           ,notes
           ,marked_new
           ,id
           ,locked_time
           ,abstract
           ,body
           ,title
           ,keywords
           ,status
           ,creation_timestamp
           ,attributes
           ,locked_by_id
           ,style_id
           ,script_id
           ,language_id
           ,last_modified_by_id
           ,owned_by_id
           ,created_by_id
           ,css_id
           ,image_id
           ,document_id
           ,published
           ,locked_by_lastname
           ,locked_by_middlename
           ,locked_by_firstname
           ,last_modified_by_lastname
           ,last_modified_by_middlename
           ,last_modified_by_firstname
           ,owned_by_lastname
           ,owned_by_middlename
           ,owned_by_firstname
           ,created_by_lastname
           ,created_by_middlename
           ,created_by_firstname
           ,data_format_name
           ,lob_length
           ,last_publication_timestamp
           ,last_published_by_id
           ,last_published_by_lastname
           ,last_published_by_middlename
           ,last_published_by_firstname
           ,marked_deleted
)
AS
SELECT  c.binfile
       ,c.last_modification_timestamp
       ,c.notes
       ,c.marked_new
       ,c.id
       ,c.locked_time
       ,c.abstract
       ,c.body
       ,c.title
       ,c.keywords
       ,c.status
       ,c.creation_timestamp
       ,c.attributes
       ,c.locked_by_id
       ,c.style_id
       ,c.script_id
       ,c.language_id
       ,c.last_modified_by_id
       ,c.owned_by_id
       ,c.created_by_id
       ,c.css_id
       ,c.image_id
       ,c.document_id
       ,c.published
       ,c.locked_by_lastname
       ,c.locked_by_middlename
       ,c.locked_by_firstname
       ,c.last_modified_by_lastname
       ,c.last_modified_by_middlename
       ,c.last_modified_by_firstname
       ,c.owned_by_lastname
       ,c.owned_by_middlename
       ,c.owned_by_firstname
       ,c.created_by_lastname
       ,c.created_by_middlename
       ,c.created_by_firstname
       ,c.data_format_name
       ,COALESCE( octet_length(c.body), octet_length(c.binfile), 0 )
       AS lob_length
       ,c.last_publication_timestamp
       ,c.last_published_by_id
       ,c.last_published_by_lastname
       ,c.last_published_by_middlename
       ,c.last_published_by_firstname
       ,c.marked_deleted
  FROM ci_content AS c
;


--functions as compatability-wrappers for Oracles vs. PostgreSQL
--one for each sequence :-/
\echo creating functions....
CREATE FUNCTION ci_bookmarks_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_bookmarks_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_content_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_content_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_data_formats_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_data_formats_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_documents_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_documents_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_languages_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_languages_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_object_types_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_object_types_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_sessions_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_sessions_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


CREATE FUNCTION ci_users_roles_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_users_roles_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE FUNCTION ci_mime_aliases_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'ci_mime_type_aliases_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE FUNCTION ci_quest_results_id_seq_nval() RETURNS INTEGER
    AS 'BEGIN
          RETURN nextval(\'ci_questionnaire_results_id_seq\');
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
      ,ci_content_loblength
      ,ci_questionnaire_results_id_seq
   TO ximsrun
;


GRANT UPDATE
   ON  ci_bookmarks_id_seq
      ,ci_content_id_seq
      ,ci_documents_id_seq
      ,ci_sessions_id_seq
      ,ci_users_roles_id_seq
      ,ci_questionnaire_results_id_seq
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
   TO ximsrun
;


-- commit
END WORK;
