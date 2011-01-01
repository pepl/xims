-- Copyright (c) 2002-2011 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

\set ECHO          queries
\set ON_ERROR_STOP yes

\connect xims

SET SESSION AUTHORIZATION 'xims';

-- DELETE FROM ci_object_types WHERE name = 'VLibrary';
-- DELETE FROM ci_object_types WHERE name = 'VLibraryItem';
-- DELETE FROM ci_object_types WHERE name = 'DocBookXML' and parent_id > 1;
-- DELETE FROM ci_data_formats WHERE name = 'VLibrary';
-- DROP TABLE cilib_authors CASCADE;
-- DROP TABLE cilib_authormap CASCADE;
-- DROP TABLE cilib_keywords CASCADE;
-- DROP TABLE cilib_keywordmap CASCADE;
-- DROP TABLE cilib_subjects CASCADE;
-- DROP TABLE cilib_subjectmap CASCADE;
-- DROP TABLE cilib_publications CASCADE;
-- DROP TABLE cilib_publicationmap CASCADE;
-- DROP TABLE cilib_meta CASCADE;
-- DROP FUNCTION cilib_authors_id_seq_nval();
-- DROP FUNCTION cilib_authormap_id_seq_nval();
-- DROP FUNCTION cilib_keywords_id_seq_nval();
-- DROP FUNCTION cilib_keywordmap_id_seq_nval();
-- DROP FUNCTION cilib_subjects_id_seq_nval();
-- DROP FUNCTION cilib_subjectmap_id_seq_nval();
-- DROP FUNCTION cilib_publications_id_seq_nval();
-- DROP FUNCTION cilib_publicationmap_id_seq_nval();
-- DROP FUNCTION cilib_meta_id_seq_nval();


-- begin transaction
BEGIN WORK;


\echo creating table 'cilib_authors'
CREATE TABLE cilib_authors
 (
 id                 SERIAL            PRIMARY KEY
 ,lastname          VARCHAR(128)      NOT NULL
 ,middlename        VARCHAR(48)       DEFAULT ''
 ,firstname         VARCHAR(48)       DEFAULT ''
 ,object_type       SMALLINT          DEFAULT 0
 ,suffix            VARCHAR(24)       DEFAULT ''
 ,email             VARCHAR(80)       DEFAULT ''
 ,url               VARCHAR(250)      DEFAULT ''
 ,image_url         VARCHAR(250)      DEFAULT ''
 ,document_id       INTEGER           NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,UNIQUE (lastname, middlename, firstname, object_type, suffix, email, url, document_id)
 )
;

COMMENT ON COLUMN cilib_authors.object_type
        IS '0 => person, 1 => organization'
;

\echo creating table 'cilib_authormap'
CREATE TABLE cilib_authormap
 (
 id                  SERIAL            PRIMARY KEY
 ,document_id        INTEGER         NOT NULL REFERENCES ci_documents  ( id ) ON DELETE CASCADE
 ,author_id          INTEGER         NOT NULL REFERENCES cilib_authors ( id )
 ,UNIQUE (document_id ,author_id)
 )
;

\echo creating table 'cilib_keywords'
CREATE TABLE cilib_keywords
 (
 id                 SERIAL            PRIMARY KEY
 ,name              VARCHAR(64)       UNIQUE NOT NULL
 ,description       VARCHAR(256)
 ,document_id       INTEGER         NOT NULL REFERENCES ci_documents  ( id ) ON DELETE CASCADE
 ,UNIQUE(document_id, name)
 )
;

\echo creating table 'cilib_keywordmap'
CREATE TABLE cilib_keywordmap
 (
 id                 SERIAL            PRIMARY KEY
 ,document_id       INTEGER           NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,keyword_id        INTEGER           NOT NULL REFERENCES cilib_keywords (id)
 ,UNIQUE (document_id, keyword_id)
 )
;

\echo creating table 'cilib_subjects'
CREATE TABLE cilib_subjects
 (
 id                 SERIAL        PRIMARY KEY
 ,name              VARCHAR(128)
 ,description       VARCHAR(4000)
 ,document_id       INTEGER       NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,UNIQUE(document_id, name)
  )
;

\echo creating table 'cilib_subjectmap'
CREATE TABLE cilib_subjectmap
 (
 id                 SERIAL        PRIMARY KEY
 ,document_id       INTEGER         NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,subject_id        INTEGER         NOT NULL REFERENCES cilib_subjects (id)
 ,UNIQUE(document_id, subject_id)
 )
;

\echo creating table 'cilib_publications'
CREATE TABLE cilib_publications
 (
 id                 SERIAL            PRIMARY KEY
 ,name              VARCHAR(256)      NOT NULL
 ,isbn              VARCHAR(30)         UNIQUE
 ,issn              varchar(30)         UNIQUE
 ,volume            varchar(30)
 ,url               varchar(250)
 ,image_url         varchar(250)
 ,document_id       INTEGER       NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,UNIQUE(name, volume,document_id)
 )
;

\echo creating table 'cilib_publicationmap'
CREATE TABLE cilib_publicationmap
 (
 id                 SERIAL        PRIMARY KEY
 ,document_id       INTEGER         NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,publication_id    INTEGER         NOT NULL REFERENCES cilib_publications (id)
 ,UNIQUE(document_id, publication_id)
 )
;


\echo creating table 'cilib_meta'
CREATE TABLE cilib_meta
 (
 id                 SERIAL        PRIMARY KEY
 ,document_id       INTEGER         NOT NULL REFERENCES ci_documents (id) ON DELETE CASCADE
 ,subtitle          VARCHAR(128)
 ,legalnotice       VARCHAR(128)
 ,bibliosource      VARCHAR(2048)
 ,mediatype         VARCHAR(128)
 ,coverage          VARCHAR(256)
 ,publisher         VARCHAR(256)
 ,audience          VARCHAR(256)
 ,dc_date           TIMESTAMP(0) WITHOUT TIME ZONE
 ,date_from_timestamp         TIMESTAMP(0)  WITHOUT TIME ZONE
 ,date_to_timestamp           TIMESTAMP(0)  WITHOUT TIME ZONE
 )
;

CREATE OR REPLACE FUNCTION cilib_authors_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_authors_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_authormap_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_authormap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_keywords_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_keywords_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_keywordmap_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_keywordmap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_subjects_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_subjects_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_subjectmap_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_subjectmap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_publications_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_publications_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_publmap_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_publicationmap_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;

CREATE OR REPLACE FUNCTION cilib_meta_id_seq_nval() RETURNS INTEGER
       AS 'BEGIN
            RETURN nextval(\'cilib_meta_id_seq\');
           END;'
       LANGUAGE 'plpgsql'
;


REVOKE ALL
    ON       cilib_authors
        ,cilib_authors_id_seq
        ,cilib_authormap
        ,cilib_authormap_id_seq
        ,cilib_keywords
        ,cilib_keywords_id_seq
        ,cilib_keywordmap
        ,cilib_keywordmap_id_seq
        ,cilib_subjects
        ,cilib_subjects_id_seq
        ,cilib_subjectmap
        ,cilib_subjectmap_id_seq
        ,cilib_publications
        ,cilib_publications_id_seq
        ,cilib_publicationmap
        ,cilib_publicationmap_id_seq
        ,cilib_meta
        ,cilib_meta_id_seq
    FROM PUBLIC;

GRANT ALL
    ON       cilib_authors
        ,cilib_authors_id_seq
        ,cilib_authormap
        ,cilib_authormap_id_seq
        ,cilib_keywords
        ,cilib_keywords_id_seq
        ,cilib_keywordmap
        ,cilib_keywordmap_id_seq
        ,cilib_subjects
        ,cilib_subjects_id_seq
        ,cilib_subjectmap
        ,cilib_subjectmap_id_seq
        ,cilib_publications
        ,cilib_publications_id_seq
        ,cilib_publicationmap
        ,cilib_publicationmap_id_seq
        ,cilib_meta
        ,cilib_meta_id_seq
    TO xims;

GRANT INSERT, SELECT, UPDATE, DELETE
    ON       cilib_authors
        ,cilib_authormap
        ,cilib_keywords
        ,cilib_keywordmap
        ,cilib_subjects
        ,cilib_subjectmap
        ,cilib_publications
        ,cilib_publicationmap
        ,cilib_meta
    TO ximsrun;

GRANT SELECT, UPDATE
    ON      cilib_authors_id_seq
        ,cilib_authormap_id_seq
        ,cilib_keywords_id_seq
        ,cilib_keywordmap_id_seq
        ,cilib_subjects_id_seq
        ,cilib_subjectmap_id_seq
        ,cilib_publications_id_seq
        ,cilib_publicationmap_id_seq
        ,cilib_meta_id_seq
    TO ximsrun;


COMMIT;
