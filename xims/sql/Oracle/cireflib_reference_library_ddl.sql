-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- DELETE FROM ci_object_types WHERE name = 'ReferenceLibrary';
-- DELETE FROM ci_object_types WHERE name = 'ReferenceLibraryItem';
-- DELETE FROM ci_data_formats WHERE name = 'ReferenceLibrary';
-- DROP TABLE cireflib_reference_types CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_serials CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_references CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_authormap CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_reference_properties CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_ref_propertyvalues CASCADE CONSTRAINTS;
-- DROP TABLE cireflib_ref_type_propertymap CASCADE CONSTRAINTS;
-- DROP FUNCTION cireflib_reftypes_id_seq_nval;
-- DROP FUNCTION cireflib_serials_id_seq_nval;
-- DROP FUNCTION cireflib_ref_id_seq_nval;
-- DROP FUNCTION cireflib_authormap_id_seq_nval;
-- DROP FUNCTION cireflib_refprop_id_seq_nval;
-- DROP FUNCTION cireflib_rpv_id_seq_nval;
-- DROP FUNCTION cireflib_rtpm_id_seq_nval;


----
-- Tables
----

PROMPT Creating Table 'cireflib_reference_types'
CREATE TABLE cireflib_reference_types (
 ID                 NUMBER             NOT NULL
 ,NAME              VARCHAR2(128)      NOT NULL
 ,DESCRIPTION       VARCHAR2(256)
)
/

PROMPT Creating Table 'cireflib_serials'
CREATE TABLE cireflib_serials
 (
 id                 NUMBER             NOT NULL
 ,title             VARCHAR2(256)      NOT NULL
 ,isbn              VARCHAR2(30)
 ,issn              VARCHAR2(30)
 ,eissn             VARCHAR2(30)
 ,identifier        VARCHAR2(256)
 ,url               VARCHAR2(256)
 ,place             VARCHAR2(256)
 ,pub               VARCHAR2(256)
 ,stitle            VARCHAR2(30)
 )
/

PROMPT Creating Table 'cireflib_references'
CREATE TABLE cireflib_references
 (
 id                  NUMBER            NOT NULL
 ,reference_type_id  NUMBER            NOT NULL
 ,document_id        NUMBER            NOT NULL
 ,serial_id          NUMBER
 )
/

PROMPT Creating Table 'cireflib_authormap'
CREATE TABLE cireflib_authormap
 (
 id                  NUMBER            NOT NULL
 ,reference_id       NUMBER            NOT NULL
 ,author_id          NUMBER            NOT NULL
 ,role               NUMBER(1,0)       DEFAULT 0 NOT NULL
 ,position           NUMBER            DEFAULT 1
 )
/

COMMENT ON COLUMN cireflib_authormap.role IS '0 => author, 1 => editor'
/

PROMPT Creating Table 'cireflib_reference_properties'
CREATE TABLE cireflib_reference_properties
 (
 id                 NUMBER            NOT NULL
 ,name              VARCHAR2(128)     NOT NULL
 ,description       VARCHAR2(4000)
 ,position          NUMBER
  )
/

PROMPT Creating Table 'cireflib_ref_propertyvalues'
CREATE TABLE cireflib_ref_propertyvalues
 (
 id                  NUMBER            NOT NULL
 ,property_id        NUMBER            NOT NULL
 ,reference_id       NUMBER            NOT NULL
 ,value              VARCHAR2(2048)
 )
/

PROMPT Creating Table 'cireflib_ref_type_propertymap'
CREATE TABLE cireflib_ref_type_propertymap
 (
 id                  NUMBER            NOT NULL
 ,property_id        NUMBER            NOT NULL
 ,reference_type_id  NUMBER            NOT NULL
 )
/

----
-- Indices
----

PROMPT Creating Unique Index 'RFT_NAME_I'
CREATE UNIQUE INDEX RFT_NAME_I ON cireflib_reference_types
 (name)
/

PROMPT Creating Unique Index 'SER_TITLE_I'
CREATE UNIQUE INDEX SER_TITLE_I ON cireflib_serials
 (title)
/

PROMPT Creating Unique Index 'SER_ISBN_I'
CREATE UNIQUE INDEX SER_ISBN_I ON cireflib_serials
 (isbn)
/

PROMPT Creating Unique Index 'SER_ISSN_I'
CREATE UNIQUE INDEX SER_ISSN_I ON cireflib_serials
 (issn)
/

PROMPT Creating Unique Index 'SER_EISSN_I'
CREATE UNIQUE INDEX SER_EISSN_I ON cireflib_serials
 (eissn)
/

PROMPT Creating Unique Index 'SER_IDENTIFIER_I'
CREATE UNIQUE INDEX SER_IDENTIFIER_I ON cireflib_serials
 (identifier)
/

PROMPT Creating Unique Index 'SER_STITLE_I'
CREATE UNIQUE INDEX SER_STITLE_I ON cireflib_serials
 (stitle)
/

PROMPT Creating Unique Index 'REF_DOCID_I'
CREATE UNIQUE INDEX REF_DOCID_I ON cireflib_references
 (document_id)
/

PROMPT Creating Unique Index 'RATM_REFAUTROLE_I'
CREATE UNIQUE INDEX RATM_REFAUTROLE_I ON cireflib_authormap
 (reference_id, author_id, role)
/

PROMPT Creating Unique Index 'RTPM_PROPRFT_I'
CREATE UNIQUE INDEX RTPM_PROPRFT_I ON cireflib_ref_type_propertymap
 (property_id, reference_type_id)
/


----
-- Constraints
----

PROMPT Creating Primary Key on 'cireflib_reference_types'
ALTER TABLE cireflib_reference_types
 ADD (CONSTRAINT RFT_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_serials'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_references'
ALTER TABLE cireflib_references
 ADD (CONSTRAINT REF_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_authormap'
ALTER TABLE cireflib_authormap
 ADD (CONSTRAINT RATM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_reference_properties'
ALTER TABLE cireflib_reference_properties
 ADD (CONSTRAINT REFPROP_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_ref_propertyvalues'
ALTER TABLE cireflib_ref_propertyvalues
 ADD (CONSTRAINT RPV_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cireflib_ref_type_propertymap'
ALTER TABLE cireflib_ref_type_propertymap
 ADD (CONSTRAINT RTPM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'cireflib_reference_types' 'name'
ALTER TABLE cireflib_reference_types
 ADD (CONSTRAINT RFT_NAM_UNQ UNIQUE
  (NAME))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'title'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_TIT_UNQ UNIQUE
  (title))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'isbn'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_ISBN_UNQ UNIQUE
  (isbn))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'issn'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_ISSN_UNQ UNIQUE
  (issn))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'eissn'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_EISSN_UNQ UNIQUE
  (eissn))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'identifier'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_IDENTIFIER_UNQ UNIQUE
  (identifier))
/

PROMPT Creating Unique Constraint on 'cireflib_serials' 'stitle'
ALTER TABLE cireflib_serials
 ADD (CONSTRAINT SER_STIT_UNQ UNIQUE
  (stitle))
/

PROMPT Creating Unique Constraint on 'cireflib_references' 'document_id'
ALTER TABLE cireflib_references
 ADD (CONSTRAINT REF_DOCID_UNQ UNIQUE
  (document_id))
/

PROMPT Creating Unique Constraint on 'cireflib_authormap' 'reference_id, author_id, role'
ALTER TABLE cireflib_authormap
 ADD (CONSTRAINT RATM_REFAUTROLE_UNQ UNIQUE
  (reference_id, author_id, role))
/

PROMPT Creating Unique Constraint on 'cireflib_ref_type_propertymap' 'property_id, reference_type_id'
ALTER TABLE cireflib_ref_type_propertymap
 ADD (CONSTRAINT RTPM_PROPRFT_UNQ UNIQUE
  (property_id, reference_type_id))
/

PROMPT Creating Foreign Key on 'cireflib_references'
ALTER TABLE cireflib_references
 ADD (CONSTRAINT REF_RFT_ID_FK FOREIGN KEY
       (reference_type_id) REFERENCES cireflib_reference_types (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_references'
ALTER TABLE cireflib_references
 ADD (CONSTRAINT REF_DOC_ID_FK FOREIGN KEY
       (document_id) REFERENCES ci_documents (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_references'
ALTER TABLE cireflib_references
 ADD (CONSTRAINT REF_SER_ID_FK FOREIGN KEY
       (serial_id) REFERENCES cireflib_serials (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_authormap'
ALTER TABLE cireflib_authormap
 ADD (CONSTRAINT RATM_REF_ID_FK FOREIGN KEY
       (reference_id) REFERENCES cireflib_references (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_authormap'
ALTER TABLE cireflib_authormap
 ADD (CONSTRAINT RATM_AUT_ID_FK FOREIGN KEY
       (author_id) REFERENCES cilib_authors (ID)
)
/

PROMPT Creating Foreign Key on 'cireflib_ref_propertyvalues'
ALTER TABLE cireflib_ref_propertyvalues
 ADD (CONSTRAINT RPV_RFP_ID_FK FOREIGN KEY
       (property_id) REFERENCES cireflib_reference_properties (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_ref_propertyvalues'
ALTER TABLE cireflib_ref_propertyvalues
 ADD (CONSTRAINT RPV_REF_ID_FK FOREIGN KEY
       (reference_id) REFERENCES cireflib_references (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_ref_type_propertymap'
ALTER TABLE cireflib_ref_type_propertymap
 ADD (CONSTRAINT RTPM_RFP_ID_FK FOREIGN KEY
       (property_id) REFERENCES cireflib_reference_properties (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cireflib_ref_type_propertymap'
ALTER TABLE cireflib_ref_type_propertymap
 ADD (CONSTRAINT RTPM_RFT_ID_FK FOREIGN KEY
       (reference_type_id) REFERENCES cireflib_reference_types (ID) ON DELETE CASCADE
)
/

----
-- Sequences
----

PROMPT Creating Sequence 'RFT_SEQ'
-- DROP SEQUENCE RFT_SEQ;
CREATE SEQUENCE RFT_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'SER_SEQ'
-- DROP SEQUENCE SER_SEQ;
CREATE SEQUENCE SER_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'REF_SEQ'
-- DROP SEQUENCE REF_SEQ;
CREATE SEQUENCE REF_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'RATM_SEQ'
-- DROP SEQUENCE RATM_SEQ;
CREATE SEQUENCE RATM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'RFP_SEQ'
-- DROP SEQUENCE RFP_SEQ;
CREATE SEQUENCE RFP_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'RPV_SEQ'
-- DROP SEQUENCE RPV_SEQ;
CREATE SEQUENCE RPV_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'RTPM_SEQ'
-- DROP SEQUENCE RTPM_SEQ;
CREATE SEQUENCE RTPM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

----
-- Sequence function wrappers
----

-- DROP FUNCTION cireflib_rtpm_id_seq_nval();


CREATE OR REPLACE FUNCTION cireflib_reftypes_id_seq_nval RETURN INTEGER IS
newid cireflib_reference_types.id%TYPE;
 BEGIN
  SELECT rft_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_serials_id_seq_nval RETURN INTEGER IS
newid cireflib_serials.id%TYPE;
 BEGIN
  SELECT ser_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_ref_id_seq_nval RETURN INTEGER IS
newid cireflib_references.id%TYPE;
 BEGIN
  SELECT ref_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_authormap_id_seq_nval RETURN INTEGER IS
newid cireflib_authormap.id%TYPE;
 BEGIN
  SELECT ratm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_refprop_id_seq_nval RETURN INTEGER IS
newid cireflib_reference_properties.id%TYPE;
 BEGIN
  SELECT rfp_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_rpv_id_seq_nval RETURN INTEGER IS
newid cireflib_ref_propertyvalues.id%TYPE;
 BEGIN
  SELECT rpv_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cireflib_rtpm_id_seq_nval RETURN INTEGER IS
newid cireflib_ref_type_propertymap.id%TYPE;
 BEGIN
  SELECT rtpm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot )
       VALUES ( OBT_SEQ.NEXTVAL, 'ReferenceLibrary', 1, 1, 1, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( OBT_SEQ.NEXTVAL, 'ReferenceLibraryItem', 0, 1, 1, 1 );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( DFM_SEQ.NEXTVAL, 'ReferenceLibrary', 'application/x-container' );

PROMPT Create some additional foreign key indexes
CREATE INDEX ref_rft_id_i  ON cireflib_references          (reference_type_id);
CREATE INDEX rpv_ref_id_i  ON cireflib_ref_propertyvalues  (reference_id);
CREATE INDEX ratm_aut_id_i ON cireflib_authormap           (author_id)
/