PROMPT Deleting nested set functions, triggers and table
DROP TRIGGER ci_doc_lftrgt_ins ON ci_documents;
DROP TRIGGER ci_doc_lftrgt_upd ON ci_documents;
DROP TRIGGER ci_doc_lftrgt_before_del ON ci_documents;
DROP TRIGGER ci_doc_lftrgt_after_del ON ci_documents;
DROP TABLE ci_documents_del_tmp;
DROP PACKAGE ci_util;

PROMPT Dropping 'lft' and 'rgt' from 'ci_documents'
ALTER TABLE ci_documents DROP COLUMN lft;
ALTER TABLE ci_documents DROP COLUMN rgt;
