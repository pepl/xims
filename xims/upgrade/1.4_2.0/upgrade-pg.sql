DELETE FROM CI_OBJECT_TYPES WHERE NAME IN ('AnonDiscussionForum', 'AnonDiscussionForumContrib');
ALTER TABLE CI_OBJECT_TYPES ADD MENU_LEVEL SMALLINT DEFAULT 0;
UPDATE CI_OBJECT_TYPES SET MENU_LEVEL=1 WHERE NAME IN 
	('Document', 'Folder', 'Departmentroot', 'File', 'Image', 'URLLink')
	AND PARENT_ID IS NULL;
UPDATE CI_OBJECT_TYPES SET MENU_LEVEL=2 WHERE NAME IN 
	('Portlet', 'NewsItem', 'Gallery', 'Newsletter', 'NewsItem2', 'ReferenceLibrary', 'Questionnaire', 'XML', 'sDocBookXML', 'SQLReport', 'Javascript', 'AxPointPresentation', 'SymbolicLink', 'XSPScript', 'CSS', 'VLibrary', 'XSLStylesheet', 'TAN_List', 'SimpleDB', 'Text', 'AnonDiscussionForum')
	AND PARENT_ID IS NULL;
