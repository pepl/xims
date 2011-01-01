-- Copyright (c) 2002-2011 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\set ECHO          queries
\set ON_ERROR_STOP yes

\connect xims

SET SESSION AUTHORIZATION 'xims';

-- DELETE FROM ci_object_types WHERE name = 'ReferenceLibrary';
-- DELETE FROM ci_object_types WHERE name = 'ReferenceLibraryItem';
-- DELETE FROM ci_data_formats WHERE name = 'ReferenceLibrary';
-- DROP TABLE cireflib_reference_types CASCADE;
-- DROP TABLE cireflib_serials CASCADE;
-- DROP TABLE cireflib_references CASCADE;
-- DROP TABLE cireflib_authormap CASCADE;
-- DROP TABLE cireflib_reference_properties CASCADE;
-- DROP TABLE cireflib_ref_propertyvalues CASCADE;
-- DROP TABLE cireflib_ref_type_propertymap CASCADE;
-- DROP FUNCTION cireflib_reftypes_id_seq_nval();
-- DROP FUNCTION cireflib_serials_id_seq_nval();
-- DROP FUNCTION cireflib_ref_id_seq_nval();
-- DROP FUNCTION cireflib_authormap_id_seq_nval();
-- DROP FUNCTION cireflib_refprop_id_seq_nval();
-- DROP FUNCTION cireflib_rpv_id_seq_nval();
-- DROP FUNCTION cireflib_rtpm_id_seq_nval();

-- begin transaction
BEGIN WORK;

\echo creating table 'cireflib_reference_types'
CREATE TABLE cireflib_reference_types
 (
 id                 SERIAL           PRIMARY KEY
 ,name              VARCHAR(128)     UNIQUE NOT NULL
 ,description       VARCHAR(256)
  )
;

\echo creating table 'cireflib_serials'
CREATE TABLE cireflib_serials
 (
 id                 SERIAL            PRIMARY KEY
 ,title             VARCHAR(256)      UNIQUE NOT NULL
 ,isbn              VARCHAR(30)       UNIQUE
 ,issn              VARCHAR(30)       UNIQUE
 ,eissn             VARCHAR(30)       UNIQUE
 ,identifier        VARCHAR(256)      UNIQUE
 ,url               VARCHAR(256)
 ,place             VARCHAR(256)
 ,pub               VARCHAR(256)
 ,stitle            VARCHAR(30)       UNIQUE
 )
;

\echo creating table 'cireflib_references'
CREATE TABLE cireflib_references
 (
 id                  SERIAL            PRIMARY KEY
 ,reference_type_id  INTEGER           NOT NULL REFERENCES cireflib_reference_types  ( id ) ON DELETE CASCADE
 ,document_id        INTEGER           UNIQUE NOT NULL REFERENCES ci_documents  ( id ) ON DELETE CASCADE
 ,serial_id          INTEGER           REFERENCES cireflib_serials  ( id ) ON DELETE CASCADE
 )
;

\echo creating table 'cireflib_authormap'
CREATE TABLE cireflib_authormap
 (
 id                  SERIAL            PRIMARY KEY
 ,reference_id       INTEGER           NOT NULL REFERENCES cireflib_references  ( id ) ON DELETE CASCADE
 ,author_id          INTEGER           NOT NULL REFERENCES cilib_authors  ( id )
 ,role               INTEGER           NOT NULL DEFAULT 0
 ,position           INTEGER           DEFAULT 1
 ,UNIQUE (reference_id, author_id, role)
 )
;

COMMENT ON COLUMN cireflib_authormap.role
        IS '0 => author, 1 => editor'
;

\echo creating table 'cireflib_reference_properties'
CREATE TABLE cireflib_reference_properties
 (
 id                 SERIAL           PRIMARY KEY
 ,name              VARCHAR(128)     NOT NULL
 ,description       VARCHAR(4096)
 ,position          INTEGER
  )
;

\echo creating table 'cireflib_ref_propertyvalues'
CREATE TABLE cireflib_ref_propertyvalues
 (
 id                  SERIAL            PRIMARY KEY
 ,property_id        INTEGER           NOT NULL REFERENCES cireflib_reference_properties  ( id ) ON DELETE CASCADE
 ,reference_id       INTEGER           NOT NULL REFERENCES cireflib_references  ( id ) ON DELETE CASCADE
 ,value              VARCHAR(2048)
 )
;

\echo creating table 'cireflib_ref_type_propertymap'
CREATE TABLE cireflib_ref_type_propertymap
 (
 id                  SERIAL            PRIMARY KEY
 ,property_id        INTEGER           NOT NULL REFERENCES cireflib_reference_properties  ( id ) ON DELETE CASCADE
 ,reference_type_id  INTEGER           NOT NULL REFERENCES cireflib_reference_types  ( id ) ON DELETE CASCADE
 ,UNIQUE (property_id, reference_type_id)
 )
;

CREATE OR REPLACE FUNCTION cireflib_reftypes_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_reference_types_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_serials_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_serials_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_ref_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_references_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_authormap_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_authormap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_refprop_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_reference_properties_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_rpv_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_ref_propertyvalues_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cireflib_rtpm_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cireflib_ref_type_propertymap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


REVOKE ALL
    ON  cireflib_reference_types
        ,cireflib_serials
        ,cireflib_references
        ,cireflib_authormap
        ,cireflib_reference_properties
        ,cireflib_ref_propertyvalues
        ,cireflib_ref_type_propertymap
        ,cireflib_reference_types_id_seq
        ,cireflib_serials_id_seq
        ,cireflib_references_id_seq
        ,cireflib_authormap_id_seq
        ,cireflib_reference_properties_id_seq
        ,cireflib_ref_propertyvalues_id_seq
        ,cireflib_ref_type_propertymap_id_seq
    FROM PUBLIC;

GRANT ALL
    ON  cireflib_reference_types
        ,cireflib_serials
        ,cireflib_references
        ,cireflib_authormap
        ,cireflib_reference_properties
        ,cireflib_ref_propertyvalues
        ,cireflib_ref_type_propertymap
        ,cireflib_reference_types_id_seq
        ,cireflib_serials_id_seq
        ,cireflib_references_id_seq
        ,cireflib_authormap_id_seq
        ,cireflib_reference_properties_id_seq
        ,cireflib_ref_propertyvalues_id_seq
        ,cireflib_ref_type_propertymap_id_seq
    TO xims;

GRANT INSERT, SELECT, UPDATE, DELETE
    ON  cireflib_reference_types
        ,cireflib_serials
        ,cireflib_references
        ,cireflib_authormap
        ,cireflib_reference_properties
        ,cireflib_ref_propertyvalues
        ,cireflib_ref_type_propertymap
    TO ximsrun;

GRANT SELECT, UPDATE
    ON  cireflib_reference_types_id_seq
        ,cireflib_serials_id_seq
        ,cireflib_references_id_seq
        ,cireflib_authormap_id_seq
        ,cireflib_reference_properties_id_seq
        ,cireflib_ref_propertyvalues_id_seq
        ,cireflib_ref_type_propertymap_id_seq
    TO ximsrun;

INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot )
       VALUES ( nextval('ci_object_types_id_seq'), 'ReferenceLibrary', 1, 1, 1, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'ReferenceLibraryItem', 0, 1, 1, 1 );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'ReferenceLibrary', 'application/x-container' );


COMMIT;
