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

PROMPT Inserting new data format 'Icon'
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'Icon', 'image/x-icon', 'ico' );
PROMPT Inserting new data format 'PPZ'
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PPZ', 'application/vnd.ms-powerpoint', 'ppz' );
PROMPT Inserting new data format 'POT'
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'POT', 'application/vnd.ms-powerpoint', 'pot' );
PROMPT Inserting new data format 'PPS'
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( DFM_SEQ.NEXTVAL, 'PPS', 'application/vnd.ms-powerpoint', 'pps' );
