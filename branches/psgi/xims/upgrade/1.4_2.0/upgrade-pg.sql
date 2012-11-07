DELETE FROM CI_OBJECT_TYPES WHERE NAME IN ('AnonDiscussionForum', 'AnonDiscussionForumContrib');
ALTER TABLE CI_OBJECT_TYPES ADD MENU_LEVEL SMALLINT DEFAULT 0;
UPDATE CI_OBJECT_TYPES SET MENU_LEVEL=1 WHERE NAME IN 
	('Document', 'Folder', 'Departmentroot', 'File', 'Image', 'URLLink')
	AND PARENT_ID IS NULL;
UPDATE CI_OBJECT_TYPES SET MENU_LEVEL=2 WHERE NAME IN 
	('Portlet', 'NewsItem', 'Gallery', 'Newsletter', 'NewsItem2', 'ReferenceLibrary', 'Questionnaire', 'XML', 'sDocBookXML', 'SQLReport', 'Javascript', 'AxPointPresentation', 'SymbolicLink', 'XSPScript', 'CSS', 'VLibrary', 'XSLStylesheet', 'TAN_List', 'SimpleDB', 'Text', 'AnonDiscussionForum')
	AND PARENT_ID IS NULL;

-- Extending  column ci_data_formats.mime_type column
ALTER TABLE ci_data_formats ALTER COLUMN mime_type TYPE VARCHAR(100);
-- Adding new data formats
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'ODT', 'application/vnd.oasis.opendocument.text', 'odt' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'ODS', 'application/vnd.oasis.opendocument.spreadsheet', 'ods' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'ODP', 'application/vnd.oasis.opendocument.presentation', 'odp' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'DOCX', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'docx' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'XLSX', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'xlsx' );  
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'SLDX', 'application/vnd.openxmlformats-officedocument.presentationml.slide', 'sldx' );
INSERT INTO CI_DATA_FORMATS ( id, name, mime_type, suffix ) VALUES ( nextval('ci_data_formats_id_seq'), 'PPTX', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'pptx' );
