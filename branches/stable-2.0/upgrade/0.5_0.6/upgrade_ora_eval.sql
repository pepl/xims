-- Copyright (c) 2002-2006 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- Add two new object types: Questionnaire and TAN_List
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic ) 
            VALUES ( OBT_SEQ.NEXTVAL, 'Questionnaire', 0, 0, 1, 1 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic ) 
            VALUES ( OBT_SEQ.NEXTVAL, 'TAN_List', 0, 0, 1, 0 );
/
-- Add two new data formats: Questionnaire and TAN_List
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type ) 
            VALUES ( DFM_SEQ.NEXTVAL, 'Questionnaire', 'text/xml' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) 
            VALUES ( DFM_SEQ.NEXTVAL, 'TAN_List', 'text/plain', 'tls' );
/
-- Add table for the questionnaire results
@@../../sql/Oracle/ci_ddl_eval.tab
@@../../sql/Oracle/ci_ddl_eval.ind
@@../../sql/Oracle/ci_ddl_eval.con
@@../../sql/Oracle/ci_ddl_eval.sqs
/
--functions as compatability-wrappers for Oracles vs. PostgreSQL
CREATE OR REPLACE FUNCTION ci_quest_results_id_seq_nval RETURN INTEGER IS
    newid ci_questionnaire_results.id%TYPE;
BEGIN
    SELECT qur_seq.nextval INTO newid FROM dual;
    RETURN newid;
END;
/
