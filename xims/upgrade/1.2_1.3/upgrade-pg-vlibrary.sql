-- Add the document_id of a VLibrary to the subject
 
ALTER TABLE cilib_subjects ADD COLUMN document_id int4;
ALTER TABLE cilib_subjects ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_subjects ADD CONSTRAINT cilib_subjects_unique_key UNIQUE(document_id, name);