\connect xims

-- Add two new object types: Questionnaire and TAN_List
INSERT INTO ci_object_types VALUES ('Questionnaire',0,0,1,1);
INSERT INTO ci_object_types VALUES ('TAN_List',0,0,1,0);


-- Add table for the questionnaire results
CREATE TABLE ci_questionnaire_results (
  document_id		INTEGER		NOT NULL, 
  tan			VARCHAR(50)	NOT NULL, 
  question_id		VARCHAR(50) 	NOT NULL, 
  answer		TEXT, 
  answer_timestamp	TIMESTAMP	DEFAULT now()	NOT NULL, 
  id			SERIAL		PRIMARY KEY, 
  CONSTRAINT fk_document_id FOREIGN KEY (document_id) REFERENCES ci_documents (id) ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE INITIALLY IMMEDIATE
);
REVOKE ALL ON TABLE ci_questionnaire_results FROM PUBLIC;
GRANT ALL ON TABLE ci_questionnaire_results TO xims;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE ci_questionnaire_results TO ximsrun;

--functions as compatability-wrappers for Oracles vs. PostgreSQL
CREATE FUNCTION ci_questionnaire_results_id_seq_nval() RETURNS INTEGER
	AS 'BEGIN
	      RETURN nextval(''ci_questionnaire_results_id_seq'');
	    END;'
	LANGUAGE 'plpgsql';