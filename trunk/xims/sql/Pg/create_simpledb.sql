-- Copyright (c) 2002-2013 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\set ECHO          queries
\set ON_ERROR_STOP yes

\connect xims

SET SESSION AUTHORIZATION 'xims';

-- DELETE FROM ci_object_types WHERE name = 'SimpleDB';
-- DELETE FROM ci_object_types WHERE name = 'SimpleDBItem';
-- DELETE FROM ci_data_formats WHERE name = 'SimpleDB';
-- DROP TABLE cisimpledb_members CASCADE;
-- DROP TABLE cisimpledb_member_properties CASCADE;
-- DROP TABLE cisimpledb_mempropertyvalues CASCADE;
-- DROP TABLE cisimpledb_mempropertymap CASCADE;
-- DROP FUNCTION cisimpledb_members_id_seq_nval();
-- DROP FUNCTION cisimpledb_memprop_id_seq_nval();
-- DROP FUNCTION cisimpledb_mpropva_id_seq_nval();
-- DROP FUNCTION cisimpledb_mpropma_id_seq_nval();

-- begin transaction
BEGIN WORK;

\echo creating table 'cisimpledb_members'
CREATE TABLE cisimpledb_members
 (
 id                  SERIAL           PRIMARY KEY
 ,document_id        INTEGER          UNIQUE NOT NULL REFERENCES ci_documents  ( id ) ON DELETE CASCADE
 )
;

\echo creating table 'cisimpledb_member_properties'
CREATE TABLE cisimpledb_member_properties
 (
 id                 SERIAL            PRIMARY KEY
 ,name				VARCHAR(128)      NOT NULL
 ,type				VARCHAR(128)      DEFAULT 'string' CHECK (type in ('string', 'stringoptions', 'textarea', 'boolean', 'integer', 'datetime', 'float'))
 ,regex             VARCHAR(2048)
 ,description       VARCHAR(4096)
 ,position          INTEGER
 ,mandatory         SMALLINT          DEFAULT 0
 ,part_of_title     SMALLINT          DEFAULT 0
 ,gopublic          SMALLINT          DEFAULT 1
  )
;

\echo creating table 'cisimpledb_mempropertyvalues'
CREATE TABLE cisimpledb_mempropertyvalues
 (
 id                  SERIAL            PRIMARY KEY
 ,property_id        INTEGER           NOT NULL REFERENCES cisimpledb_member_properties  ( id ) ON DELETE CASCADE
 ,member_id          INTEGER           NOT NULL REFERENCES cisimpledb_members  ( id ) ON DELETE CASCADE
 ,value              VARCHAR(2048)
 )
;

\echo creating table 'cisimpledb_mempropertymap'
CREATE TABLE cisimpledb_mempropertymap
 (
 id                  SERIAL            PRIMARY KEY
 ,property_id        INTEGER           NOT NULL REFERENCES cisimpledb_member_properties  ( id ) ON DELETE CASCADE
 ,document_id        INTEGER           NOT NULL REFERENCES ci_documents  ( id ) ON DELETE CASCADE
 ,UNIQUE (property_id, document_id)
 )
;


CREATE OR REPLACE FUNCTION cisimpledb_members_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''cisimpledb_members_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cisimpledb_memprop_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''cisimpledb_member_properties_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cisimpledb_mpropva_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''cisimpledb_mempropertyvalues_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cisimpledb_mpropma_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(''cisimpledb_mempropertymap_id_seq'');
           END;'
       LANGUAGE 'plpgsql'
;


REVOKE ALL
    ON  cisimpledb_members
        ,cisimpledb_member_properties
        ,cisimpledb_mempropertyvalues
        ,cisimpledb_mempropertymap
        ,cisimpledb_members_id_seq
        ,cisimpledb_member_properties_id_seq
        ,cisimpledb_mempropertyvalues_id_seq
        ,cisimpledb_mempropertymap_id_seq
    FROM PUBLIC;

GRANT ALL
    ON  cisimpledb_members
        ,cisimpledb_member_properties
        ,cisimpledb_mempropertyvalues
        ,cisimpledb_mempropertymap
        ,cisimpledb_members_id_seq
        ,cisimpledb_member_properties_id_seq
        ,cisimpledb_mempropertyvalues_id_seq
        ,cisimpledb_mempropertymap_id_seq
    TO xims;

GRANT INSERT, SELECT, UPDATE, DELETE
    ON  cisimpledb_members
        ,cisimpledb_member_properties
        ,cisimpledb_mempropertyvalues
        ,cisimpledb_mempropertymap
    TO ximsrun;

GRANT SELECT, UPDATE
    ON  cisimpledb_members_id_seq
        ,cisimpledb_member_properties_id_seq
        ,cisimpledb_mempropertyvalues_id_seq
        ,cisimpledb_mempropertymap_id_seq
    TO ximsrun;

INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot )
       VALUES ( nextval('ci_object_types_id_seq'), 'SimpleDB', 1, 1, 1, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
      VALUES ( nextval('ci_object_types_id_seq'), 'SimpleDBItem', 0, 1, 1, 1 );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'SimpleDB', 'application/x-container' );


COMMIT;
