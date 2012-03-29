CREATE TABLE CI_USER_PREFS 
(
  ID NUMBER(6, 0) NOT NULL 
, PROFILE_TYPE VARCHAR2(20 BYTE) NOT NULL 
, SKIN VARCHAR2(20 BYTE) NOT NULL 
, PUBLISH_AT_SAVE NUMBER(1, 0) NOT NULL 
, CONTAINERVIEW_SHOW VARCHAR2(20 BYTE) NOT NULL 
) ;
DELETE FROM CI_OBJECT_TYPES WHERE NAME IN ('AnonDiscussionForum', 'AnonDiscussionForumContrib');
ALTER TABLE CI_OBJECT_TYPES ADD MENU_LEVEL NUMBER(1,0) DEFAULT 0;
UPDATE TABLE CI_OBJECT_TYPES SET MENU_LEVEL=1 WHERE NAME IN 
	('Document', 'NewsItem', 'NewsItem2', 'Newsletter', 'Folder', 'Departmentroot', 'File', 'Image', 'Gallery', 'URLLink', 'Portlet')
	AND PARENT_ID IS NULL;
UPDATE TABLE CI_OBJECT_TYPES SET MENU_LEVEL=2 WHERE NAME IN 
	('ReferenceLibrary', 'Questionnaire', 'XML', 'sDocBookXML', 'SQLReport', 'Javascript', 'AxPointPresentation', 'SymbolicLink', 'XSPScript', 'CSS', 'VLibrary', 'XSLStylesheet', 'TAN_List', 'SimpleDB', 'Text')
	AND PARENT_ID IS NULL;