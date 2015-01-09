-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- DELETE FROM ci_object_types WHERE name = 'SimpleDB';
-- DELETE FROM ci_object_types WHERE name = 'SimpleDBItem';
-- DELETE FROM ci_data_formats WHERE name = 'SimpleDB';
-- DROP TABLE cisimpledb_members CASCADE CONSTRAINTS;
-- DROP TABLE cisimpledb_member_properties CASCADE CONSTRAINTS;
-- DROP TABLE cisimpledb_mempropertyvalues CASCADE CONSTRAINTS;
-- DROP TABLE cisimpledb_mempropertymap CASCADE CONSTRAINTS;
-- DROP FUNCTION cisimpledb_members_id_seq_nval;
-- DROP FUNCTION cisimpledb_memprop_id_seq_nval;
-- DROP FUNCTION cisimpledb_mpropva_id_seq_nval;
-- DROP FUNCTION cisimpledb_mpropma_id_seq_nval;


----
-- Tables
----

PROMPT Creating Table 'cisimpledb_members'
CREATE TABLE cisimpledb_members
 (
 id                  NUMBER            NOT NULL
 ,document_id        NUMBER            NOT NULL
 )
/

PROMPT Creating Table 'cisimpledb_member_properties'
CREATE TABLE cisimpledb_member_properties
 (
 id                 NUMBER            NOT NULL
 ,name              VARCHAR2(128)     NOT NULL
 ,type              VARCHAR2(128)     DEFAULT 'string'
 ,regex             VARCHAR2(2048)
 ,description       VARCHAR2(4000)
 ,position          NUMBER
 ,mandatory         NUMBER(1,0)       DEFAULT 0
 ,part_of_title     NUMBER(1,0)       DEFAULT 0
 ,gopublic          NUMBER(1,0)       DEFAULT 1
 )
/

PROMPT Creating table 'cisimpledb_mempropertyvalues'
CREATE TABLE cisimpledb_mempropertyvalues
 (
 id                  NUMBER            NOT NULL
 ,property_id        NUMBER            NOT NULL
 ,member_id          NUMBER            NOT NULL
 ,value              VARCHAR2(2048)
 )
/

PROMPT Creating table 'cisimpledb_mempropertymap'
CREATE TABLE cisimpledb_mempropertymap
 (
 id                  NUMBER            NOT NULL
 ,property_id        NUMBER            NOT NULL
 ,document_id        NUMBER            NOT NULL
 )
/

----
-- Indices
----


PROMPT Creating Unique Index 'MEM_DOCID_I'
CREATE UNIQUE INDEX MEM_DOCID_I ON cisimpledb_members
 (document_id)
/

----
-- Constraints
----

PROMPT Creating Primary Key on 'cisimpledb_members'
ALTER TABLE cisimpledb_members
 ADD (CONSTRAINT MEM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cisimpledb_member_properties'
ALTER TABLE cisimpledb_member_properties
 ADD (CONSTRAINT PRO_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cisimpledb_mempropertyvalues'
ALTER TABLE cisimpledb_mempropertyvalues
 ADD (CONSTRAINT PRV_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Primary Key on 'cisimpledb_mempropertymap'
ALTER TABLE cisimpledb_mempropertymap
 ADD (CONSTRAINT PRM_PK PRIMARY KEY
  (ID))
/

PROMPT Creating Unique Constraint on 'cisimpledb_members' 'document_id'
ALTER TABLE cisimpledb_members
 ADD (CONSTRAINT MEM_DOC_UNQ UNIQUE
  (DOCUMENT_ID))
/

PROMPT Creating Foreign Key on 'cisimpledb_members'
ALTER TABLE cisimpledb_members
 ADD (CONSTRAINT MEM_DOC_ID_FK FOREIGN KEY
       (document_id) REFERENCES ci_documents (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cisimpledb_mempropertyvalues'
ALTER TABLE cisimpledb_mempropertyvalues
 ADD (CONSTRAINT PRV_PRO_ID_FK FOREIGN KEY
       (property_id) REFERENCES cisimpledb_member_properties (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cisimpledb_mempropertyvalues'
ALTER TABLE cisimpledb_mempropertyvalues
 ADD (CONSTRAINT PRV_MEM_ID_FK FOREIGN KEY
       (member_id) REFERENCES cisimpledb_members (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cisimpledb_mempropertymap'
ALTER TABLE cisimpledb_mempropertymap
 ADD (CONSTRAINT PRM_PRO_ID_FK FOREIGN KEY
       (property_id) REFERENCES cisimpledb_member_properties (ID) ON DELETE CASCADE
)
/

PROMPT Creating Foreign Key on 'cisimpledb_mempropertymap'
ALTER TABLE cisimpledb_mempropertymap
 ADD (CONSTRAINT PRM_DOC_ID_FK FOREIGN KEY
       (document_id) REFERENCES ci_documents (ID) ON DELETE CASCADE
)
/

PROMPT Creating check constraint on 'cisimpledb_member_properties' 'type'
ALTER TABLE cisimpledb_member_properties
 ADD (CONSTRAINT PRO_TYPE CHECK
  (TYPE IN ('string', 'stringoptions', 'textarea', 'boolean', 'integer', 'datetime', 'float')))
/


----
-- Sequences
----

PROMPT Creating Sequence 'MEM_SEQ'
-- DROP SEQUENCE MEM_SEQ;
CREATE SEQUENCE MEM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'PRO_SEQ'
-- DROP SEQUENCE PRO_SEQ;
CREATE SEQUENCE PRO_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'PRV_SEQ'
-- DROP SEQUENCE PRV_SEQ;
CREATE SEQUENCE PRV_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

PROMPT Creating Sequence 'PRM_SEQ'
-- DROP SEQUENCE PRM_SEQ;
CREATE SEQUENCE PRM_SEQ
 NOMAXVALUE
 NOMINVALUE
 NOCYCLE
 NOCACHE
/

----
-- Sequence function wrappers
----

CREATE OR REPLACE FUNCTION cisimpledb_members_id_seq_nval RETURN INTEGER IS
newid cisimpledb_members.id%TYPE;
 BEGIN
  SELECT mem_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cisimpledb_memprop_id_seq_nval RETURN INTEGER IS
newid cisimpledb_member_properties.id%TYPE;
 BEGIN
  SELECT pro_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cisimpledb_mpropva_id_seq_nval RETURN INTEGER IS
newid cisimpledb_mempropertyvalues.id%TYPE;
 BEGIN
  SELECT prv_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION cisimpledb_mpropma_id_seq_nval RETURN INTEGER IS
newid cisimpledb_mempropertymap.id%TYPE;
 BEGIN
  SELECT prm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_objectroot )
       VALUES ( OBT_SEQ.NEXTVAL, 'SimpleDB', 1, 1, 1, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
      VALUES ( OBT_SEQ.NEXTVAL, 'SimpleDBItem', 0, 1, 1, 1 );
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( DFM_SEQ.NEXTVAL, 'SimpleDB', 'application/x-container' );

PROMPT Create some additional foreign key indexes
CREATE INDEX prv_mem_id_i  ON cisimpledb_mempropertyvalues (member_id);
CREATE INDEX prm_doc_id_i  ON cisimpledb_mempropertymap    (document_id);
CREATE INDEX prm_pro_id_i  ON cisimpledb_mempropertymap    (property_id)
/