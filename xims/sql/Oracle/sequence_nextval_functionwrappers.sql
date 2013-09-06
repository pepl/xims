-- Copyright (c) 2002-2013 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
CREATE OR REPLACE FUNCTION ci_documents_id_seq_nval RETURN INTEGER IS
newid ci_documents.id%TYPE;
 BEGIN
  SELECT doc_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_roles_granted_id_seq_nval RETURN INTEGER IS
newid ci_roles_granted.id%TYPE;
 BEGIN
  SELECT rgt_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_data_formats_id_seq_nval RETURN INTEGER IS
newid ci_data_formats.id%TYPE;
 BEGIN
  SELECT dfm_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_object_types_id_seq_nval RETURN INTEGER IS
newid ci_object_types.id%TYPE;
 BEGIN
  SELECT obt_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_users_roles_id_seq_nval RETURN INTEGER IS
newid ci_users_roles.id%TYPE;
 BEGIN
  SELECT usr_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_languages_id_seq_nval RETURN INTEGER IS
newid ci_languages.id%TYPE;
 BEGIN
  SELECT lng_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_content_id_seq_nval RETURN INTEGER IS
newid ci_content.id%TYPE;
 BEGIN
  SELECT ctt_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_sessions_id_seq_nval RETURN INTEGER IS
newid ci_sessions.id%TYPE;
 BEGIN
  SELECT ses_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_bookmarks_id_seq_nval RETURN INTEGER IS
newid ci_bookmarks.id%TYPE;
 BEGIN
  SELECT bmk_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_mime_aliases_id_seq_nval RETURN INTEGER IS
newid ci_mime_type_aliases.id%TYPE;
 BEGIN
  SELECT mta_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/

CREATE OR REPLACE FUNCTION ci_quest_results_id_seq_nval RETURN INTEGER IS
newid ci_questionnaire_results.id%TYPE;
 BEGIN
  SELECT qur_seq.nextval INTO newid FROM dual;
 RETURN newid;
 END;
/
