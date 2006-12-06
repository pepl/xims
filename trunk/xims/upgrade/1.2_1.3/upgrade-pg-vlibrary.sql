-- Add the document_id of a VLibrary to the subject

ALTER TABLE cilib_subjects ADD COLUMN document_id int4;
ALTER TABLE cilib_subjects ALTER COLUMN id SET NOT NULL;
ALTER TABLE cilib_subjects ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_subjects ADD CONSTRAINT cilib_subjects_unique_key UNIQUE(document_id, name);

-- Extend Description
ALTER TABLE cilib_subjects ADD COLUMN t_description VARCHAR(4000);
UPDATE cilib_subjects SET t_description = description;
ALTER TABLE cilib_subjects DROP description;
ALTER TABLE cilib_subjects RENAME t_description TO description;




