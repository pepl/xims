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

\echo Inserting new data format 'Icon'
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'Icon', 'image/x-icon', 'ico' );
\echo Inserting new data format 'PPZ'
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPZ', 'application/vnd.ms-powerpoint', 'ppz' );
\echo Inserting new data format 'POT'
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'POT', 'application/vnd.ms-powerpoint', 'pot' );
\echo Inserting new data format 'PPS'
INSERT INTO ci_data_formats ( id, name, mime_type, suffix )
       VALUES ( nextval('ci_data_formats_id_seq'), 'PPS', 'application/vnd.ms-powerpoint', 'pps' );


