\connect xims

-- Add two new object types: Questionnaire and TAN_List
\echo inserting into ci_object_types...
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'Questionnaire', 0, 0, 1, 1 );
INSERT INTO ci_object_types ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'TAN_List', 0, 0, 1, 0 );

-- Add two new data formats: Questionnaire and TAN_List
\echo inserting into ci_data_formats...
INSERT INTO ci_data_formats ( id, name, mime_type )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Questionnaire', 'text/xml' );
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'TAN_List', 'text/plain', 'tls' );


-- Add table for the questionnaire results
\echo creating table 'ci_questionnaire_results'
CREATE TABLE ci_questionnaire_results
  (document_id      INTEGER      NOT NULL
                                 REFERENCES ci_documents ( id )
                                 ON DELETE RESTRICT
                                 ON UPDATE RESTRICT
                                 NOT DEFERRABLE
                                 INITIALLY IMMEDIATE

  ,tan              VARCHAR(50)  NOT NULL
  ,question_id      VARCHAR(50)  NOT NULL
  ,answer           TEXT
  ,answer_timestamp TIMESTAMP    DEFAULT now()    NOT NULL
  ,id               SERIAL       PRIMARY KEY
);
REVOKE ALL ON TABLE ci_questionnaire_results FROM PUBLIC;
GRANT ALL ON TABLE ci_questionnaire_results TO xims;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE ci_questionnaire_results TO ximsrun;

--functions as compatability-wrappers for Oracles vs. PostgreSQL
CREATE FUNCTION ci_quest_results_id_seq_nval() RETURNS INTEGER
    AS 'BEGIN
          RETURN nextval(\'ci_questionnaire_results_id_seq\');
        END;'
    LANGUAGE 'plpgsql'
;

-- ximsrun is the user XIMS connects as at runtime,
-- least possible privileges here.
GRANT SELECT, UPDATE
   ON
      ci_questionnaire_results_id_seq
   TO ximsrun
;

