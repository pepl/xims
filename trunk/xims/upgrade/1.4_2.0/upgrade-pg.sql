DELETE FROM CI_OBJECT_TYPES WHERE NAME IN ('AnonDiscussionForum', 'AnonDiscussionForumContrib');
ALTER TABLE CI_OBJECT_TYPES ADD MENU_LEVEL SMALLINT DEFAULT 0;
UPDATE TABLE CI_OBJECT_TYPES SET MENU_LEVEL=1 WHERE NAME IN 
	('Document', 'NewsItem', 'NewsItem2', 'Newsletter', 'Folder', 'Departmentroot', 'File', 'Image', 'Gallery', 'URLLink', 'Portlet')
	AND PARENT_ID IS NULL;
UPDATE TABLE CI_OBJECT_TYPES SET MENU_LEVEL=2 WHERE NAME IN 
	('ReferenceLibrary', 'Questionnaire', 'XML', 'sDocBookXML', 'SQLReport', 'Javascript', 'AxPointPresentation', 'SymbolicLink', 'XSPScript', 'CSS', 'VLibrary', 'XSLStylesheet', 'TAN_List', 'SimpleDB', 'Text')
	AND PARENT_ID IS NULL;
