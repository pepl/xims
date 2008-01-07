ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';
CREATE OR REPLACE PACKAGE tmp_update_xims_vlibrary IS
--
-- $Id:$
-- Update VLibrary in XIMS-Database from version 1.2 to 1.3

PROCEDURE update_cilib_subjects;
PROCEDURE update_cilib_authors;
PROCEDURE update_cilib_keywords;
PROCEDURE update_cilib_publications;

END tmp_update_xims_vlibrary;
/

CREATE OR REPLACE
PACKAGE BODY tmp_update_xims_vlibrary IS

  PROCEDURE update_cilib_subjects IS
  
    this_subject_id NUMBER;
    new_subject_id  NUMBER;
    lv_found_c1     NUMBER := 0;
    lv_found_c2     NUMBER := 0;
    
    CURSOR map_cur
    IS
      SELECT m.id, d.parent_id as document_id 
        FROM cilib_subjectmap m
        JOIN ci_documents d on d.id = m.document_id;
  
    CURSOR subject_cur (subject_id_in IN NUMBER) 
    IS
      SELECT name
            ,description 
      FROM cilib_subjects
      WHERE id = subject_id_in;
      
    subject_rec subject_cur%ROWTYPE;
  
    CURSOR mapped_subject_cur (map_id_in IN NUMBER) 
    IS
      SELECT  subject_id 
        INTO  this_subject_id 
        FROM  cilib_subjectmap 
        WHERE id = map_id_in;      
  
    CURSOR c1 (subject_id_in IN NUMBER, document_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_subjects s
      WHERE s.id = subject_id_in  
        AND s.document_id = document_id_in;
  
    CURSOR c2 (subject_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_subjects s
      WHERE s.id = subject_id_in 
        AND s.document_id IS NULL;
        
  BEGIN
  
    FOR map_rec IN map_cur
    LOOP  
    
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
        UPDATE cilib_subjects s
          SET s.document_id = map_rec.document_id
          WHERE s.ID = this_subject_id;
  
     ELSE
        -- no usable entry, so clone it; then update the mappings 
        SELECT sub_seq.NEXTVAL INTO new_subject_id FROM dual;
          
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
        UPDATE cilib_subjectmap m
          SET   m.subject_id =  new_subject_id 
          WHERE m.subject_id = this_subject_id
            AND m.document_id IN (SELECT id 
                                    FROM ci_documents 
                                    WHERE parent_id = map_rec.document_id);
             
      END IF;
      
      lv_found_c1 := 0;
      lv_found_c2 := 0;
      
    END LOOP;
    COMMIT;
      
    EXCEPTION 
    WHEN OTHERS 
      THEN 
      ROLLBACK; 
        
  END update_cilib_subjects;
  
  PROCEDURE update_cilib_authors IS
  
    this_author_id NUMBER;
    new_author_id  NUMBER;
    lv_found_c1    NUMBER := 0;
    lv_found_c2    NUMBER := 0;
    
    CURSOR vlib_map_cur
    IS
      SELECT m.id, d.parent_id as document_id, m.author_id 
        FROM cilib_authormap m
        JOIN ci_documents d on d.id = m.document_id;
        
    CURSOR refl_map_cur
    IS
      SELECT m.id, d.parent_id as document_id, m.author_id 
       FROM  cireflib_authormap m
        JOIN cireflib_references r on m.reference_id = r.id
        JOIN ci_documents d on d.id = r.document_id;
        
    CURSOR author_cur (author_id_in IN NUMBER) 
    IS
      SELECT lastname
            ,middlename
            ,firstname
            ,object_type
            ,suffix
            ,email
            ,url
            ,image_url 
      FROM cilib_authors
      WHERE id = author_id_in;
      
    author_rec author_cur%ROWTYPE;
  
    CURSOR vlib_map_aut_cur (map_id_in IN NUMBER) 
    IS
      SELECT  author_id 
        INTO  this_author_id 
        FROM  cilib_authormap 
        WHERE id = map_id_in;      
  
    CURSOR refl_map_aut_cur (map_id_in IN NUMBER) 
    IS
      SELECT  author_id 
        INTO  this_author_id 
        FROM  cireflib_authormap 
        WHERE id = map_id_in;      
  
    CURSOR c1 (author_id_in IN NUMBER, document_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_authors a
      WHERE a.id = author_id_in  
        AND a.document_id = document_id_in;
  
    CURSOR c2 (author_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_authors a
      WHERE a.id = author_id_in 
        AND a.document_id IS NULL;
        
  BEGIN
  
    FOR map_rec IN vlib_map_cur
    LOOP  
    
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
        UPDATE cilib_authors a
          SET a.document_id = map_rec.document_id
          WHERE a.ID = this_author_id;
  
     ELSE
        -- no usable entry, so clone it; then update the mappings 
        SELECT aut_seq.NEXTVAL INTO new_author_id FROM dual;
          
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
                 ,author_rec.image_url 
                 ,map_rec.document_id);
         
        -- Update all mappings of that reference 
        -- documents with that parent_id to the
        -- newly created author 
           
        UPDATE cilib_authormap m
          SET m.author_id = new_author_id 
          WHERE m.author_id = this_author_id
            AND m.document_id IN (SELECT id FROM ci_documents
                                   WHERE parent_id = map_rec.document_id);
             
      END IF;
      
      lv_found_c1 := 0;
      lv_found_c2 := 0;
      
    END LOOP;
    
    FOR map_rec IN refl_map_cur
    LOOP  
    
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
       UPDATE cilib_authors a
         SET a.document_id = map_rec.document_id
         WHERE a.ID = this_author_id;
  
     ELSE
       -- no usable entry, so clone it; then update the mappings 
        SELECT aut_seq.NEXTVAL INTO new_author_id FROM dual;
          
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
                 ,author_rec.image_url
                 ,map_rec.document_id);
         
        -- Update all mappings of that reference 
        -- documents with that parent_id   
        UPDATE cireflib_authormap m
          SET author_id = new_author_id 
          WHERE m.author_id = this_author_id
            AND m.reference_id IN 
             (SELECT r.id 
                FROM ci_documents d
                JOIN cireflib_references r ON r.document_id = d.id
                WHERE d.parent_id = map_rec.document_id);
      END IF;
      
      lv_found_c1 := 0;
      lv_found_c2 := 0;
      
    END LOOP;
    COMMIT;
    
    EXCEPTION 
    WHEN OTHERS 
      THEN 
      ROLLBACK; 
    
  END update_cilib_authors;

  PROCEDURE update_cilib_keywords IS
  
    this_keyword_id NUMBER;
    new_keyword_id  NUMBER;
    lv_found_c1     NUMBER := 0;
    lv_found_c2     NUMBER := 0;
    
    CURSOR map_cur
    IS
      SELECT m.id, d.parent_id as document_id 
        FROM cilib_keywordmap m
        JOIN ci_documents d on d.id = m.document_id;
  
    CURSOR keyword_cur (keyword_id_in IN NUMBER) 
    IS
      SELECT name
           , description 
      FROM cilib_keywords
      WHERE id = keyword_id_in;
      
    keyword_rec keyword_cur%ROWTYPE;
  
    CURSOR mapped_keyword_cur (map_id_in IN NUMBER) 
    IS
      SELECT  keyword_id 
        INTO  this_keyword_id 
        FROM  cilib_keywordmap 
        WHERE id = map_id_in;      
  
    CURSOR c1 (keyword_id_in IN NUMBER, document_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_keywords k
      WHERE k.id = keyword_id_in  
        AND k.document_id = document_id_in;
  
    CURSOR c2 (keyword_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_keywords k
      WHERE k.id = keyword_id_in 
        AND k.document_id IS NULL;
        
  BEGIN
  
    FOR map_rec IN map_cur
    LOOP  
    
      OPEN mapped_keyword_cur(map_rec.id);
      FETCH mapped_keyword_cur INTO this_keyword_id;
      CLOSE mapped_keyword_cur;
     
      OPEN c1 (this_keyword_id, map_rec.document_id);
      FETCH c1 INTO lv_found_c1;
      CLOSE c1;
      
      OPEN c2 (this_keyword_id);
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
        -- update keyword, fill in correct document_id
        UPDATE cilib_keywords k
          SET k.document_id = map_rec.document_id
          WHERE k.ID = this_keyword_id;
  
     ELSE
        -- no usable entry, so clone it; then update the mappings 
        SELECT kwr_seq.NEXTVAL INTO new_keyword_id FROM dual;
          
        OPEN keyword_cur (this_keyword_id);
        FETCH keyword_cur INTO keyword_rec;
        CLOSE keyword_cur;
          
        INSERT INTO cilib_keywords 
          VALUES (new_keyword_id
                 ,keyword_rec.name
                 ,keyword_rec.description     
                 ,map_rec.document_id);
         
        -- Update all mappings of that reference 
        -- documents with that parent_id to the
        -- newly created keyword            
        UPDATE cilib_keywordmap m
          SET   m.keyword_id =  new_keyword_id 
          WHERE m.keyword_id = this_keyword_id
            AND m.document_id IN (SELECT id 
                                    FROM ci_documents 
                                    WHERE parent_id = map_rec.document_id);
             
      END IF;
      
      lv_found_c1 := 0;
      lv_found_c2 := 0;
      
    END LOOP;
    COMMIT;
      
    EXCEPTION 
    WHEN OTHERS 
      THEN 
      ROLLBACK; 
        
  END update_cilib_keywords;
  

  PROCEDURE update_cilib_publications IS
  
    this_publication_id NUMBER;
    new_publication_id  NUMBER;
    lv_found_c1         NUMBER := 0;
    lv_found_c2         NUMBER := 0;
    
    CURSOR map_cur
    IS
      SELECT m.id, d.parent_id as document_id 
        FROM cilib_publicationmap m
        JOIN ci_documents d on d.id = m.document_id;
  
    CURSOR publication_cur (publication_id_in IN NUMBER) 
    IS
      SELECT name
            ,isbn
            ,issn
            ,volume
            ,url
            ,image_url
      FROM cilib_publications
      WHERE id = publication_id_in;
      
    publication_rec publication_cur%ROWTYPE;
  
    CURSOR mapped_publication_cur (map_id_in IN NUMBER) 
    IS
      SELECT  publication_id 
        INTO  this_publication_id 
        FROM  cilib_publicationmap 
        WHERE id = map_id_in;      
  
    CURSOR c1 (publication_id_in IN NUMBER, document_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_publications p
      WHERE p.id = publication_id_in  
        AND p.document_id = document_id_in;
  
    CURSOR c2 (publication_id_in IN NUMBER)
    IS 
      SELECT 1
      FROM cilib_publications p
      WHERE p.id = publication_id_in 
        AND p.document_id IS NULL;
        
  BEGIN
  
    FOR map_rec IN map_cur
    LOOP  
    
      OPEN mapped_publication_cur(map_rec.id);
      FETCH mapped_publication_cur INTO this_publication_id;
      CLOSE mapped_publication_cur;
     
      OPEN c1 (this_publication_id, map_rec.document_id);
      FETCH c1 INTO lv_found_c1;
      CLOSE c1;
      
      OPEN c2 (this_publication_id);
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
        -- update publication, fill in correct document_id
        UPDATE cilib_publications p
          SET p.document_id = map_rec.document_id
          WHERE p.ID = this_publication_id;
  
     ELSE
        -- no usable entry, so clone it; then update the mappings 
        SELECT pub_seq.NEXTVAL INTO new_publication_id FROM dual;
          
        OPEN publication_cur (this_publication_id);
        FETCH publication_cur INTO publication_rec;
        CLOSE publication_cur;
          
        INSERT INTO cilib_publications (id
                                      , name
                                      , isbn
                                      , issn
                                      , volume
                                      , url
                                      , image_url
                                      , document_id)
          VALUES (new_publication_id
                 ,publication_rec.name
                 ,publication_rec.isbn
                 ,publication_rec.issn
                 ,publication_rec.volume
                 ,publication_rec.url
                 ,publication_rec.image_url     
                 ,map_rec.document_id);
         
        -- Update all mappings of that reference 
        -- documents with that parent_id to the
        -- newly created publication            
        UPDATE cilib_publicationmap m
          SET   m.publication_id = new_publication_id 
          WHERE m.publication_id = this_publication_id
            AND m.document_id IN (SELECT id 
                                    FROM ci_documents 
                                    WHERE parent_id = map_rec.document_id);
             
      END IF;
      
      lv_found_c1 := 0;
      lv_found_c2 := 0;
      
    END LOOP;
    COMMIT;
      
    EXCEPTION 
    WHEN OTHERS 
      THEN 
      ROLLBACK; 
        
  END update_cilib_publications;
  
END tmp_update_xims_vlibrary;
/

-- backup tables:
CREATE TABLE bak$cilib_subjects AS SELECT * FROM cilib_subjects
/
CREATE TABLE bak$cilib_subjectmap AS SELECT * FROM cilib_subjectmap
/
CREATE TABLE bak$cilib_authors AS SELECT * FROM cilib_authors
/
CREATE TABLE bak$cilib_authormap AS SELECT * FROM cilib_authormap
/
CREATE TABLE bak$cireflib_authormap AS SELECT * FROM cireflib_authormap
/
CREATE TABLE bak$cilib_keywords AS SELECT * FROM cilib_keywords
/
CREATE TABLE bak$cilib_keywordmap AS SELECT * FROM cilib_keywordmap
/
CREATE TABLE bak$cilib_publications AS SELECT * FROM cilib_publications
/
CREATE TABLE bak$cilib_publicationmap AS SELECT * FROM cilib_publicationmap
/

-- Extend cilib_subjects.description
ALTER TABLE cilib_subjects MODIFY  (description  VARCHAR2(4000));

-- Add the document_id of a VLibrary to the subject
ALTER TABLE cilib_subjects ADD     (document_id NUMBER)
/

ALTER TABLE cilib_authors ADD      (image_url   VARCHAR2(250) DEFAULT '');
ALTER TABLE cilib_authors ADD      (document_id NUMBER)
/

ALTER TABLE cilib_keywords ADD     (document_id NUMBER)
/

ALTER TABLE cilib_publications ADD (url         VARCHAR2(250) DEFAULT '');
ALTER TABLE cilib_publications ADD (image_url   VARCHAR2(250) DEFAULT '');
ALTER TABLE cilib_publications ADD (document_id NUMBER)
/

-- Altering Unique Constraint to include document_id
ALTER TABLE cilib_subjects DROP CONSTRAINT sub_nam_unq;
ALTER TABLE cilib_subjects
 ADD (CONSTRAINT sub_nam_unq UNIQUE
  (document_id, name))
/

ALTER TABLE cilib_authors DROP CONSTRAINT aut_nam_unq; 
ALTER TABLE cilib_authors
 ADD (CONSTRAINT aut_nam_unq UNIQUE
  (lastname, middlename, firstname, object_type, suffix, email, url, document_id))
/

ALTER TABLE cilib_keywords DROP CONSTRAINT kwr_nam_unq;
ALTER TABLE cilib_keywords
 ADD (CONSTRAINT kwr_nam_unq UNIQUE
  (document_id, name))
/

ALTER TABLE cilib_publications DROP CONSTRAINT pub_nam_vol_unq;
ALTER TABLE cilib_publications
 ADD (CONSTRAINT pub_nam_vol_unq UNIQUE
  (document_id, name, volume, url))
/

ALTER TABLE cilib_publications DROP CONSTRAINT pub_isbn_unq;
-- ALTER TABLE cilib_publications
--  ADD (CONSTRAINT pub_isbn_unq UNIQUE
--   (document_id, isbn))
/

ALTER TABLE cilib_publications DROP CONSTRAINT pub_issn_unq;
-- ALTER TABLE cilib_publications
--  ADD (CONSTRAINT pub_issn_unq UNIQUE
--   (document_id, issn))
/

ALTER PACKAGE tmp_update_xims_vlibrary COMPILE
/

BEGIN

  tmp_update_xims_vlibrary.update_cilib_authors();
  tmp_update_xims_vlibrary.update_cilib_subjects();  
  tmp_update_xims_vlibrary.update_cilib_keywords();
  tmp_update_xims_vlibrary.update_cilib_publications();  

END;
/

DELETE FROM cilib_authors a
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cireflib_authormap m WHERE a.id = m.author_id)
    AND NOT EXISTS (SELECT 1 FROM cilib_authormap m WHERE a.id = m.author_id); 

DELETE FROM cilib_subjects s
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cilib_subjectmap m WHERE s.id = m.subject_id);

DELETE FROM cilib_keywords k
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cilib_keywordmap m WHERE k.id = m.keyword_id);

DELETE FROM cilib_publications p
  WHERE document_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM cilib_publicationmap m WHERE p.id = m.publication_id);

COMMIT;
/

ALTER TABLE cilib_subjects
 ADD (CONSTRAINT sub_doc_id_fk FOREIGN KEY
       (document_id) REFERENCES ci_documents(id) ON DELETE CASCADE
);

ALTER TABLE cilib_authors
 ADD (CONSTRAINT aut_doc_id_fk FOREIGN KEY
       (document_id) REFERENCES ci_documents(id) ON DELETE CASCADE
);

ALTER TABLE cilib_keywords
 ADD (CONSTRAINT kwd_doc_id_fk FOREIGN KEY
       (document_id) REFERENCES ci_documents(id) ON DELETE CASCADE
);

ALTER TABLE cilib_publications
 ADD (CONSTRAINT pub_doc_id_fk FOREIGN KEY
       (document_id) REFERENCES ci_documents(id) ON DELETE CASCADE
);

ALTER TABLE cilib_subjects MODIFY  (document_id  NOT NULL);

ALTER TABLE cilib_authors  MODIFY  (document_id  NOT NULL);

ALTER TABLE cilib_keywords  MODIFY  (document_id  NOT NULL);

ALTER TABLE cilib_publications  MODIFY  (document_id  NOT NULL)

/

