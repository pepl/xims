
-- add SiteRoot "xims" with SiteRoot URL '/ximspubroot/xims'
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
       VALUES (nextval('ci_documents_id_seq'), 1, 17, 31, 2, 'xims', 1, '/xims' );
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
       VALUES (nextval('ci_content_id_seq') , 2, '/ximspubroot/xims', 2, 2, 2, 2);


