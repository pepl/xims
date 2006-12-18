-- Add the document_id of the respective VLibrary to the author

ALTER TABLE cilib_authors ADD COLUMN document_id integer;
ALTER TABLE cilib_authors ALTER COLUMN document_id SET NOT NULL;
ALTER TABLE cilib_authors ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_authors ADD CONSTRAINT cilib_authors_unique_key 
      UNIQUE (lastname, middlename, firstname, object_type, suffix, email, url, document_id);

-- Add the document_id of the respective VLibrary to the subject

ALTER TABLE cilib_subjects ADD COLUMN document_id int4;
ALTER TABLE cilib_subjects ALTER COLUMN document_id SET NOT NULL;
ALTER TABLE cilib_subjects ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_subjects DROP CONSTRAINT cilib_subjects_unique_key;
ALTER TABLE cilib_subjects ADD CONSTRAINT cilib_subjects_unique_key UNIQUE(document_id, name);

-- Extend Description
ALTER TABLE cilib_subjects ADD COLUMN t_description VARCHAR(4000);
UPDATE cilib_subjects SET t_description = description;
ALTER TABLE cilib_subjects DROP description;
ALTER TABLE cilib_subjects RENAME t_description TO description;




