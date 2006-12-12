-- Extend cilib_subjects.description
ALTER TABLE CILIB_SUBJECTS MODIFY  (description  VARCHAR2(4000));

-- Add the document_id of a VLibrary to the subject
ALTER TABLE CILIB_SUBJECTS ADD     (document_id NUMBER);
ALTER TABLE CILIB_AUTHORS ADD     (document_id NUMBER);

-----------------------------------------------------------------
--                                                             --
--          Insert "update-existing-data-fu" here...           --
--                                                             --
-----------------------------------------------------------------

-- Altering Unique Constraint to include document_id
ALTER TABLE CILIB_SUBJECTS DROP CONSTRAINT SUB_NAM_UNQ;
ALTER TABLE CILIB_SUBJECTS
 ADD (CONSTRAINT SUB_NAM_UNQ UNIQUE
  (DOCUMENT_ID, NAME))
;

ALTER TABLE CILIB_AUTHORS
 ADD (CONSTRAINT AUT_NAM_UNQ UNIQUE
  (LASTNAME, MIDDLENAME, FIRSTNAME, OBJECT_TYPE, SUFFIX, EMAIL, URL, DOCUMENT_ID))
;

ALTER TABLE CILIB_SUBJECTS
 ADD (CONSTRAINT SUB_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
);

ALTER TABLE CILIB_AUTHORS
 ADD (CONSTRAINT AUT_DOC_ID_FK FOREIGN KEY
       (DOCUMENT_ID) REFERENCES CI_DOCUMENTS (ID) ON DELETE CASCADE
);

ALTER TABLE CILIB_SUBJECTS MODIFY  (document_id  NOT NULL);

ALTER TABLE CILIB_AUTHORS  MODIFY  (document_id  NOT NULL)
/

