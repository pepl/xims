-- Copyright (c) 2002-2009 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- DELETE FROM ci_object_types WHERE name = 'VLibrary';
-- DELETE FROM ci_object_types WHERE name = 'VLibraryItem';
-- DELETE FROM ci_object_types WHERE name = 'DocBookXML' and parent_id > 1;
-- DELETE FROM ci_data_formats WHERE name = 'VLibrary';
-- DROP TABLE CILIB_AUTHORS CASCADE CONSTRAINTS;
-- DROP TABLE CILIB_AUTHORMAP;
-- DROP TABLE CILIB_KEYWORDS CASCADE CONSTRAINTS;
-- DROP TABLE CILIB_KEYWORDMAP;
-- DROP TABLE CILIB_SUBJECTS CASCADE CONSTRAINTS;
-- DROP TABLE CILIB_SUBJECTMAP;
-- DROP TABLE CILIB_PUBLICATIONS CASCADE CONSTRAINTS;
-- DROP TABLE CILIB_PUBLICATIONMAP;
-- DROP TABLE CILIB_META;
-- DROP FUNCTION cilib_authors_id_seq_nval;
-- DROP FUNCTION cilib_authormap_id_seq_nval;
-- DROP FUNCTION cilib_keywords_id_seq_nval;
-- DROP FUNCTION cilib_keywordmap_id_seq_nval;
-- DROP FUNCTION cilib_subjects_id_seq_nval;
-- DROP FUNCTION cilib_subjectmap_id_seq_nval;
-- DROP FUNCTION cilib_publications_id_seq_nval;
-- DROP FUNCTION cilib_publicationmap_id_seq_nval;
-- DROP FUNCTION cilib_meta_id_seq_nval;

----
-- Tables
----

PROMPT Creating Table 'CILIB_AUTHORS'
CREATE TABLE CILIB_AUTHORS (
 ID                 NUMBER          NOT NULL
 ,LASTNAME          VARCHAR2(128)   NOT NULL
 ,MIDDLENAME        VARCHAR2(48)    DEFAULT ''
 ,FIRSTNAME         VARCHAR2(48)    DEFAULT ''
 ,OBJECT_TYPE       NUMBER(1,0)     DEFAULT 0
 ,SUFFIX            VARCHAR2(24)    DEFAULT ''
 ,EMAIL             VARCHAR2(80)    DEFAULT ''
 ,URL               VARCHAR2(250)   DEFAULT ''
 ,IMAGE_URL         VARCHAR2(250)   DEFAULT ''
 ,DOCUMENT_ID       NUMBER NOT NULL
)
/

COMMENT ON COLUMN CILIB_AUTHORS.OBJECT_TYPE IS '0 => person, 1 => organization'
/

PROMPT Creating Table 'CILIB_AUTHORMAP'
CREATE TABLE CILIB_AUTHORMAP
 (
 ID                 NUMBER NOT NULL
 ,DOCUMENT_ID       NUMBER NOT NULL
 ,AUTHOR_ID         NUMBER NOT NULL
 )
/

PROMPT Creating Table 'CILIB_KEYWORDS'
CREATE TABLE CILIB_KEYWORDS
 (
 ID                 NUMBER NOT NULL
 ,NAME              VARCHAR2(64) NOT NULL
 ,DESCRIPTION       VARCHAR2(256)
 ,DOCUMENT_ID       NUMBER NOT NULL
 )
/

PROMPT Creating Table 'CILIB_KEYWORDMAP'
CREATE TABLE CILIB_KEYWORDMAP
 (
 ID                 NUMBER NOT NULL
 ,DOCUMENT_ID       NUMBER NOT NULL
 ,KEYWORD_ID        NUMBER NOT NULL
 )
/

PROMPT Creating Table 'CILIB_SUBJECTS'
CREATE TABLE CILIB_SUBJECTS
 (
 ID                 NUMBER NOT NULL
 ,NAME              VARCHAR2(128) NOT NULL
 ,DESCRIPTION       VARCHAR2(256)
 ,DOCUMENT_ID       NUMBER NOT NULL
  )
/

PROMPT Creating Table 'CILIB_SUBJECTMAP'
CREATE TABLE CILIB_SUBJECTMAP
 (
 ID                 NUMBER NOT NULL
 ,DOCUMENT_ID       NUMBER NOT NULL
 ,SUBJECT_ID        NUMBER NOT NULL
 )
/

PROMPT Creating Table 'CILIB_PUBLICATIONS'
CREATE TABLE CILIB_PUBLICATIONS
 (
 ID                 NUMBER NOT NULL
 ,NAME              VARCHAR2(256) NOT NULL
 ,ISBN              VARCHAR2(30)
 ,ISSN              VARCHAR2(30)
 ,VOLUME            VARCHAR(30)
 ,URL               VARCHAR2(250) DEFAULT ''
 ,IMAGE_URL         VARCHAR2(250) DEFAULT ''
 ,DOCUMENT_ID       NUMBER NOT NULL
  )
/

PROMPT Creating Table 'CILIB_PUBLICATIONMAP'
CREATE TABLE CILIB_PUBLICATIONMAP
 (
 ID                 NUMBER NOT NULL
 ,DOCUMENT_ID       NUMBER NOT NULL
 ,PUBLICATION_ID    NUMBER NOT NULL
 )
/

PROMPT Creating Table 'CILIB_META'
CREATE TABLE CILIB_META (
 ID                 NUMBER          NOT NULL
 ,DOCUMENT_ID       NUMBER NOT NULL
 ,SUBTITLE          VARCHAR2(128)
 ,LEGALNOTICE       VARCHAR2(128)
 ,BIBLIOSOURCE      VARCHAR2(2048)
 ,MEDIATYPE         VARCHAR2(128)
 ,COVERAGE          VARCHAR2(256)
 ,PUBLISHER         VARCHAR2(256)
 ,AUDIENCE          VARCHAR2(256)
 ,DC_DATE           DATE
 ,DATE_FROM_TIMESTAMP         DATE
 ,DATE_TO_TIMESTAMP           DATE
 )
/

----
-- Indices
----

PROMPT Creating Unique Index 'AUT_DOC_ID_I'
CREATE UNIQUE INDEX AUT_DOC_ID_I ON CILIB_AUTHORMAP
 (DOCUMENT_ID, AUTHOR_ID)
/

PROMPT Creating Unique Index 'KWR_NAM_ID_I'
CREATE INDEX KWR_NAM_ID_I ON CILIB_KEYWORDS
 (NAME)
/

PROMPT Creating Unique Index 'KWR_DOC_ID_I'
CREATE INDEX KWR_DOC_ID_I ON CILIB_KEYWORDMAP
 (DOCUMENT_ID, KEYWORD_ID)
/

PROMPT Creating Unique Index 'SUB_NAM_ID_I'
CREATE INDEX SUB_NAM_ID_I ON CILIB_SUBJECTS
 (DOCUMENT_ID, NAME)
/

PROMPT Creating Unique Index 'SUB_DOC_ID_I'
CREATE INDEX SUB_DOC_ID_I ON CILIB_SUBJECTMAP
 (DOCUMENT_ID, SUBJECT_ID)
/

PROMPT Creating Unique Index 'PUB_NAM_VOL_I'
CREATE INDEX PUB_NAM_VOL_I ON CILIB_PUBLICATIONS
 (NAME, VOLUME)
/

PROMPT Creating Unique Index 'PUB_ISBN_I'
CREATE INDEX PUB_ISBN_I ON CILIB_PUBLICATIONS
 (ISBN)
/

PROMPT Creating Unique Index 'PUB_ISSN_I'
CREATE INDEX PUB_ISSN_I ON CILIB_PUBLICATIONS
 (ISSN)
/

PROMPT Creating Unique Index 'PUB_DOC_ID_I'
CREATE INDEX PUB_DOC_ID_I ON CILIB_PUBLICATIONMAP
 (DOCUMENT_ID, PUBLICATION_ID)
/

PROMPT Creating Unique Index 'MET_DOC_ID_I'
CREATE INDEX MET_DOC_ID_I ON CILIB_META
 (DOCUMENT_ID)
/

----
-- Constraints
----

PROMPT Creating Primary Key on 'CILIB_AUTHORS'
ALTER TABLE CILIB_AUTHORS
 ADD (CONSTRAINT AUT_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'CILIB_AUTHORS'
ALTER TABLE CILIB_AUTHORS
 ADD (CONSTRAINT AUT_NAM_UNQ UNIQUE
  (LASTNAME, MIDDLENAME, FIRSTNAME, OBJECT_TYPE, SUFFIX, EMAIL, URL, DOCUMENT_ID))
;

PROMPT Creating Primary Key on 'CILIB_AUTHORMAP'
ALTER TABLE CILIB_AUTHORMAP
 ADD (CONSTRAINT ATM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'CILIB_KEYWORDS'
ALTER TABLE CILIB_KEYWORDS
 ADD (CONSTRAINT KWR_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'CILIB_KEYWORDS' 'name'
ALTER TABLE CILIB_KEYWORDS
 ADD (CONSTRAINT KWR_NAM_UNQ UNIQUE
  (DOCUMENT_ID, NAME))
/

PROMPT Creating Primary Key on 'CILIB_KEYWORDMAP'
ALTER TABLE CILIB_KEYWORDMAP
 ADD (CONSTRAINT KWM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'CILIB_SUBJECTS'
ALTER TABLE CILIB_SUBJECTS
 ADD (CONSTRAINT SUB_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'CILIB_SUBJECTS'
ALTER TABLE CILIB_SUBJECTS
 ADD (CONSTRAINT SUB_NAM_UNQ UNIQUE
  (DOCUMENT_ID, NAME))
/

PROMPT Creating Primary Key on 'CILIB_SUBJECTMAP'
ALTER TABLE CILIB_SUBJECTMAP
 ADD (CONSTRAINT SUM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'CILIB_PUBLICATIONS'
ALTER TABLE CILIB_PUBLICATIONS
 ADD (CONSTRAINT PUB_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'CILIB_PUBLICATIONS' 'name', 'volume', 'url'
ALTER TABLE CILIB_PUBLICATIONS
 ADD (CONSTRAINT PUB_NAM_VOL_UNQ UNIQUE
  (DOCUMENT_ID, NAME, VOLUME, URL))
/

-- PROMPT Creating Unique Constraint on 'CILIB_PUBLICATIONS' 'isbn'
-- ALTER TABLE CILIB_PUBLICATIONS
--  ADD (CONSTRAINT PUB_ISBN_UNQ UNIQUE
--   (ISBN))
-- /

-- PROMPT Creating Unique Constraint on 'CILIB_PUBLICATIONS' 'issn'
-- ALTER TABLE CILIB_PUBLICATIONS
--  ADD (CONSTRAINT PUB_ISSN_UNQ UNIQUE
--   (ISSN))
-- /

PROMPT Creating Primary Key on 'CILIB_PUBLICATIONMAP'
ALTER TABLE CILIB_PUBLICATIONMAP
 ADD (CONSTRAINT PBM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'CILIB_META'
ALTER TABLE CILIB_META
 ADD (CONSTRAINT MET_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'CILIB_META' 'document_id'
ALTER TABLE CILIB_META
 ADD (CONSTRAINT MET_DOC_UNQ UNIQUE
  (DOCUMENT_ID))
/

PROMPT Creating Foreign Key on 'CILIB_SUBJECTS'
ALTER TABLE CILIB_AUTHORS
 ADD (CONSTRAINT AUT_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_AUTHORMAP'
ALTER TABLE CILIB_AUTHORMAP
 ADD (CONSTRAINT ATM_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_AUTHORMAP'
ALTER TABLE CILIB_AUTHORMAP
 ADD (CONSTRAINT ATM_AUT_ID_FK FOREIGN KEY
       (AUTHOR_ID) REFERENCES CILIB_AUTHORS (ID)
)
/

PROMPT Creating Unique Constraint on 'CILIB_AUTHORMAP'
ALTER TABLE CILIB_AUTHORMAP
   ADD CONSTRAINT ATM_UNQ UNIQUE (DOCUMENT_ID, AUTHOR_ID)
/

PROMPT Creating Foreign Key on 'CILIB_KEYWORDMAP'
ALTER TABLE CILIB_KEYWORDMAP
 ADD (CONSTRAINT KWM_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_KEYWORDMAP'
ALTER TABLE CILIB_KEYWORDMAP
 ADD (CONSTRAINT KWM_KWR_ID_FK FOREIGN KEY
       (KEYWORD_ID) REFERENCES CILIB_KEYWORDS (ID)
)
/

PROMPT Creating Unique Constraint on 'CILIB_KEYWORDMAP'
ALTER TABLE CILIB_KEYWORDMAP
   ADD CONSTRAINT KWM_UNQ UNIQUE (DOCUMENT_ID, KEYWORD_ID)
/

PROMPT Creating Foreign Key on 'CILIB_SUBJECTS'
ALTER TABLE CILIB_SUBJECTS
 ADD (CONSTRAINT SUB_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_SUBJECTMAP'
ALTER TABLE CILIB_SUBJECTMAP
 ADD (CONSTRAINT SUM_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_SUBJECTMAP'
ALTER TABLE CILIB_SUBJECTMAP
 ADD (CONSTRAINT SUM_SUB_ID_FK FOREIGN KEY
       (SUBJECT_ID) REFERENCES CILIB_SUBJECTS (ID)
)
/

PROMPT Creating Unique Constraint on 'CILIB_SUBJECTMAP'
ALTER TABLE CILIB_SUBJECTMAP
   ADD CONSTRAINT SUM_UNQ UNIQUE (DOCUMENT_ID, SUBJECT_ID)
/

PROMPT Creating Foreign Key on 'CILIB_PUBLICATIONMAP'
ALTER TABLE CILIB_PUBLICATIONMAP
 ADD (CONSTRAINT PBM_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'CILIB_PUBLICATIONMAP'
ALTER TABLE CILIB_PUBLICATIONMAP
 ADD (CONSTRAINT PBM_PUB_ID_FK FOREIGN KEY
       (PUBLICATION_ID) REFERENCES CILIB_PUBLICATIONS (ID)
)
/

PROMPT Creating Unique Constraint on 'CILIB_PUBLICATIONMAP'
ALTER TABLE CILIB_PUBLICATIONMAP
   ADD CONSTRAINT PBM_UNQ UNIQUE (DOCUMENT_ID, PUBLICATION_ID)
/

PROMPT Creating Foreign Key on 'CILIB_META'
ALTER TABLE CILIB_META
 ADD (CONSTRAINT MET_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
)
/

----
-- Sequences
----

PROMPT Creating Sequence 'AUT_SEQ'
-- DROP SEQUENCE AUT_SEQ;
CREATE SEQUENCE AUT_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'ATM_SEQ'
-- DROP SEQUENCE ATM_SEQ;
CREATE SEQUENCE ATM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'KWR_SEQ'
-- DROP SEQUENCE KWR_SEQ;
CREATE SEQUENCE KWR_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'KWM_SEQ'
-- DROP SEQUENCE KWM_SEQ;
CREATE SEQUENCE KWM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'SUB_SEQ'
-- DROP SEQUENCE SUB_SEQ;
CREATE SEQUENCE SUB_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'SUM_SEQ'
-- DROP SEQUENCE SUM_SEQ;
CREATE SEQUENCE SUM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'PUB_SEQ'
-- DROP SEQUENCE PUB_SEQ;
CREATE SEQUENCE PUB_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'PBM_SEQ'
-- DROP SEQUENCE PBM_SEQ;
CREATE SEQUENCE PBM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'MET_SEQ'
-- DROP SEQUENCE MET_SEQ;
CREATE SEQUENCE MET_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

----
-- Sequence function wrappers
----

CREATE OR REPLACE FUNCTION cilib_authors_id_seq_nval RETURN INTEGER IS
newid cilib_authors.id%TYPE;
 BEGIN
  SELECT aut_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_authormap_id_seq_nval RETURN INTEGER IS
newid cilib_authormap.id%TYPE;
 BEGIN
  SELECT atm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_keywords_id_seq_nval RETURN INTEGER IS
newid cilib_keywords.id%TYPE;
 BEGIN
  SELECT kwr_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_keywordmap_id_seq_nval RETURN INTEGER IS
newid cilib_keywordmap.id%TYPE;
 BEGIN
  SELECT kwm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_subjects_id_seq_nval RETURN INTEGER IS
newid cilib_subjects.id%TYPE;
 BEGIN
  SELECT sub_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_subjectmap_id_seq_nval RETURN INTEGER IS
newid cilib_subjectmap.id%TYPE;
 BEGIN
  SELECT sum_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_publications_id_seq_nval RETURN INTEGER IS
newid cilib_publications.id%TYPE;
 BEGIN
  SELECT pub_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_publmap_id_seq_nval RETURN INTEGER IS
newid cilib_publicationmap.id%TYPE;
 BEGIN
  SELECT pbm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cilib_meta_id_seq_nval RETURN INTEGER IS
newid cilib_meta.id%TYPE;
 BEGIN
  SELECT met_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

PROMPT Create some additional foreign key indexes
-- Vlibrary
CREATE INDEX sum_sub_id_i  ON cilib_subjectmap             (subject_id);
CREATE INDEX atm_aut_id_i  ON cilib_authormap              (author_id);
CREATE INDEX kwm_kwd_id_i  ON cilib_keywordmap             (keyword_id);
CREATE INDEX pbm_pub_id_i  ON cilib_publicationmap         (publication_id);

CREATE INDEX kwr_lib_fk_i  ON cilib_keywords               (document_id);
CREATE INDEX aut_lib_fk_i  ON cilib_authors                (document_id);
CREATE INDEX sub_lib_fk_i  ON cilib_subjects               (document_id);
CREATE INDEX pub_lib_fk_i  ON cilib_publications           (document_id)
/


