\echo Deleting nested set functions, triggers and rule
DROP TRIGGER ci_doc_lftrgt_bi ON ci_documents CASCADE;
DROP FUNCTION ci_doc_lftrgt_bi();
DROP RULE move_rule ON ci_documents;
DROP FUNCTION ci_doc_move_tree(INTEGER, INTEGER, INTEGER);
DROP FUNCTION ci_del_tree(INTEGER);

\echo Dropping 'lft' and 'rgt' from 'ci_documents'
\echo This will only work with PostgreSQL >7.2
\echo If you have PostgreSQL 7.2 please update to >= 7.3
ALTER TABLE ci_documents DROP COLUMN lft;
ALTER TABLE ci_documents DROP COLUMN rgt;
ALTER TABLE ci_documents DROP CONSTRAINT "$1";
ALTER TABLE ci_documents ADD  CONSTRAINT "$1" 
      FOREIGN KEY (parent_id) REFERENCES ci_documents (id) ON DELETE CASCADE;
	
