CREATE OR REPLACE FUNCTION update_cilib_subjects() RETURNS BOOLEAN AS $$
DECLARE
    this_subject_id INTEGER;
    new_subject_id  INTEGER;
    lv_found_c1     INTEGER := 0;
    lv_found_c2     INTEGER := 0;

    subject_rec RECORD;
    map_rec RECORD;

    subject_cur CURSOR (subject_id_in INTEGER)
    IS
      SELECT name,description
      FROM cilib_subjects
      WHERE id = subject_id_in;

    mapped_subject_cur CURSOR (map_id_in INTEGER)
    IS
      SELECT  subject_id
        FROM  cilib_subjectmap
        WHERE id = map_id_in;

    c1 CURSOR (subject_id_in INTEGER, document_id_in INTEGER)
    IS
      SELECT 1
      FROM cilib_subjects s
      WHERE s.id = subject_id_in
        AND s.document_id = document_id_in;

    c2 CURSOR (subject_id_in INTEGER)
    IS
      SELECT 1
      FROM cilib_subjects s
      WHERE s.id = subject_id_in
        AND s.document_id IS NULL;

  BEGIN
    FOR map_rec IN SELECT m.id, d.parent_id as document_id FROM cilib_subjectmap m JOIN ci_documents d on d.id = m.document_id LOOP
      OPEN mapped_subject_cur(map_rec.id);
      FETCH mapped_subject_cur INTO this_subject_id;
      CLOSE mapped_subject_cur;

      OPEN c1 (this_subject_id, map_rec.document_id);
      FETCH c1 INTO lv_found_c1;
      CLOSE c1;

      OPEN c2 (this_subject_id);
      FETCH c2 INTO lv_found_c2;
      CLOSE c2;

     IF lv_found_c1 = 1
     -- existing entry w/ correct document_id
     THEN
       -- do nothing, next tuple
       NULL;

     ELSIF lv_found_c2 = 1
     -- existing entry with document_id NULL
     THEN
        -- update subject, fill in correct document_id
        UPDATE cilib_subjects
          SET document_id = map_rec.document_id
          WHERE ID = this_subject_id;

     ELSE
        -- no usable entry, so clone it; then update the mappings
        SELECT cilib_subjects_id_seq_nval() INTO new_subject_id;

        OPEN subject_cur (this_subject_id);
        FETCH subject_cur INTO subject_rec;
        CLOSE subject_cur;

        INSERT INTO cilib_subjects
          VALUES (new_subject_id
                 ,subject_rec.name
                 ,subject_rec.description
                 ,map_rec.document_id);

        -- Update all mappings of that reference
        -- documents with that parent_id to the
        -- newly created subject
        UPDATE cilib_subjectmap
          SET   subject_id =  new_subject_id
          WHERE subject_id = this_subject_id
            AND document_id IN (SELECT id
                                    FROM ci_documents
                                    WHERE parent_id = map_rec.document_id);

      END IF;

      lv_found_c1 := 0;
      lv_found_c2 := 0;

    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION update_cilib_authors() RETURNS BOOLEAN AS $$
DECLARE
    this_author_id INTEGER;
    new_author_id  INTEGER;
    lv_found_c1    INTEGER := 0;
    lv_found_c2    INTEGER := 0;

    author_rec RECORD;
    map_rec RECORD;

    author_cur CURSOR (author_id_in INTEGER)
    IS
      SELECT lastname
            ,middlename
            ,firstname
            ,object_type
            ,suffix
            ,email
            ,url
      FROM cilib_authors
      WHERE id = author_id_in;

    vlib_map_aut_cur CURSOR (map_id_in INTEGER)
    IS
      SELECT  author_id
        FROM  cilib_authormap
        WHERE id = map_id_in;

    refl_map_aut_cur CURSOR (map_id_in INTEGER)
    IS
      SELECT  author_id
        FROM  cireflib_authormap
        WHERE id = map_id_in;

    c1 CURSOR (author_id_in INTEGER, document_id_in INTEGER)
    IS
      SELECT 1
      FROM cilib_authors a
      WHERE a.id = author_id_in
        AND a.document_id = document_id_in;

    c2 CURSOR (author_id_in INTEGER)
    IS
      SELECT 1
      FROM cilib_authors a
      WHERE a.id = author_id_in
        AND a.document_id IS NULL;

BEGIN
    FOR map_rec IN SELECT m.id, d.parent_id as document_id, m.author_id FROM cilib_authormap m JOIN ci_documents d on d.id = m.document_id LOOP
      OPEN vlib_map_aut_cur(map_rec.id);
      FETCH vlib_map_aut_cur INTO this_author_id;
      CLOSE vlib_map_aut_cur;

      OPEN c1 (this_author_id, map_rec.document_id);
      FETCH c1 INTO lv_found_c1;
      CLOSE c1;

      OPEN c2 (this_author_id);
      FETCH c2 INTO lv_found_c2;
      CLOSE c2;

      IF lv_found_c1 = 1

      THEN
        -- existing entry with correct document_id:
        -- do nothing, next tuple
        NULL;

      ELSIF lv_found_c2 = 1

      THEN
        -- existing entry with document_id NULL:
        -- update w/ correct document_id */
        UPDATE cilib_authors
          SET document_id = map_rec.document_id
          WHERE ID = this_author_id;

     ELSE
        -- no usable entry, so clone it; then update the mappings
        SELECT cilib_authors_id_seq_nval() INTO new_author_id;

        OPEN author_cur (this_author_id);
        FETCH author_cur INTO author_rec;
        CLOSE author_cur;

        INSERT INTO cilib_authors
          VALUES (new_author_id
                 ,author_rec.lastname
                 ,author_rec.middlename
                 ,author_rec.firstname
                 ,author_rec.object_type
                 ,author_rec.suffix
                 ,author_rec.email
                 ,author_rec.url
                 ,map_rec.document_id);

        -- Update all mappings of that reference
        -- documents with that parent_id to the
        -- newly created author

        UPDATE cilib_authormap
          SET author_id = new_author_id
          WHERE author_id = this_author_id
            AND document_id IN (SELECT id FROM ci_documents
                                   WHERE parent_id = map_rec.document_id);

      END IF;

      lv_found_c1 := 0;
      lv_found_c2 := 0;

    END LOOP;

    FOR map_rec IN SELECT m.id, d.parent_id as document_id, m.author_id FROM  cireflib_authormap m JOIN cireflib_references r on m.reference_id = r.id JOIN ci_documents d on d.id = r.document_id LOOP
      OPEN refl_map_aut_cur(map_rec.id);
      FETCH refl_map_aut_cur INTO this_author_id;
      CLOSE refl_map_aut_cur;

      OPEN c1 (this_author_id, map_rec.document_id);
      FETCH c1 INTO lv_found_c1;
      CLOSE c1;

      OPEN c2 (this_author_id);
      FETCH c2 INTO lv_found_c2;
      CLOSE c2;

     IF lv_found_c1 = 1

     THEN
       -- existing entry w/ correct document_id
       -- do nothing, next tuple
       NULL;

     ELSIF lv_found_c2 = 1
     THEN

       -- existing entry w/ document_id NULL
       -- update tuple w/ correct document_id
       UPDATE cilib_authors
         SET document_id = map_rec.document_id
         WHERE ID = this_author_id;

     ELSE
       -- no usable entry, so clone it; then update the mappings
        SELECT cilib_authors_id_seq_nval() INTO new_author_id;

        OPEN author_cur (this_author_id);
        FETCH author_cur INTO author_rec;
        CLOSE author_cur;

        INSERT INTO cilib_authors
          VALUES (new_author_id
                 ,author_rec.lastname
                 ,author_rec.middlename
                 ,author_rec.firstname
                 ,author_rec.object_type
                 ,author_rec.suffix
                 ,author_rec.email
                 ,author_rec.url
                 ,map_rec.document_id);

        -- Update all mappings of that reference
        -- documents with that parent_id
        UPDATE cireflib_authormap
          SET author_id = new_author_id
          WHERE author_id = this_author_id
            AND reference_id IN
             (SELECT r.id
                FROM ci_documents d
                JOIN cireflib_references r ON r.document_id = d.id
                WHERE d.parent_id = map_rec.document_id);
      END IF;

      lv_found_c1 := 0;
      lv_found_c2 := 0;

    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

-- backup tables:
CREATE TABLE bak$cilib_subjects AS SELECT * FROM cilib_subjects;
CREATE TABLE bak$cilib_subjectmap AS SELECT * FROM cilib_subjectmap;
CREATE TABLE bak$cilib_authors AS SELECT * FROM cilib_authors;
CREATE TABLE bak$cilib_authormap AS SELECT * FROM cilib_authormap;
CREATE TABLE bak$cireflib_authormap AS SELECT * FROM cireflib_authormap;

ALTER TABLE cilib_authors ADD COLUMN image_url VARCHAR(250);

-- Add the document_id of the respective VLibrary to the author
ALTER TABLE cilib_authors ADD COLUMN document_id integer;
ALTER TABLE cilib_authors ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_authors ADD CONSTRAINT cilib_authors_unique_key
      UNIQUE (lastname, middlename, firstname, object_type, suffix, email, url, document_id);


-- Add the document_id of the respective VLibrary to the keyword
ALTER TABLE cilib_keywords ADD COLUMN document_id integer;
ALTER TABLE cilib_keywords ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_keywords ADD CONSTRAINT cilib_keywords_unique_key
      UNIQUE (name, document_id);

ALTER TABLE cilib_publications ADD COLUMN url VARCHAR(250);
ALTER TABLE cilib_publications ADD COLUMN image_url VARCHAR(250);

-- Add the document_id of the respective VLibrary to the publication
ALTER TABLE cilib_publications ADD COLUMN document_id integer;
ALTER TABLE cilib_publications ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_publications ADD CONSTRAINT cilib_publications_unique_key
      UNIQUE (name, volume, document_id);


-- Add the document_id of the respective VLibrary to the subject

ALTER TABLE cilib_subjects ADD COLUMN document_id int4;
ALTER TABLE cilib_subjects ADD FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
ALTER TABLE cilib_subjects DROP CONSTRAINT cilib_subjects_unique_key;
ALTER TABLE cilib_subjects ADD CONSTRAINT cilib_subjects_unique_key UNIQUE(document_id, name);

-- Extend Description
ALTER TABLE cilib_subjects ADD COLUMN t_description VARCHAR(4000);
UPDATE cilib_subjects SET t_description = description;
ALTER TABLE cilib_subjects DROP description;
ALTER TABLE cilib_subjects RENAME t_description TO description;

select update_cilib_subjects();
select update_cilib_authors();
--TODO
--select update_cilib_keywords();
--select update_cilib_publications();

DELETE FROM cilib_authors
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cireflib_authormap m WHERE cilib_authors.id = m.author_id)
    AND NOT EXISTS (SELECT 1 FROM cilib_authormap m WHERE cilib_authors.id = m.author_id);

DELETE FROM cilib_subjects
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cilib_subjectmap m WHERE cilib_subjects.id = m.subject_id);

ALTER TABLE cilib_authors ALTER COLUMN document_id SET NOT NULL;
ALTER TABLE cilib_subjects ALTER COLUMN document_id SET NOT NULL;
ALTER TABLE cilib_keywords ALTER COLUMN document_id SET NOT NULL;
ALTER TABLE cilib_publications ALTER COLUMN document_id SET NOT NULL;


