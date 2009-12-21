-- Set is_objectroot object type property
UPDATE ci_object_types SET IS_OBJECTROOT = 0;
UPDATE ci_object_types SET IS_OBJECTROOT = 1 WHERE name IN ('DepartmentRoot', 'SiteRoot', 'VLibrary', 'Portal');

-- VLibraries are published via gopublic
UPDATE ci_object_types SET PUBLISH_GOPUBLIC = 1 WHERE name = 'VLibrary';

-- Upgrade Script from 0.1b to 0.1 forgot to do the following
UPDATE CI_DATA_FORMATS SET mime_type = 'text/javascript' WHERE name = 'ECMA';

-- Grant object type privilege JavaScript for role everyone
INSERT INTO CI_OBJECT_TYPE_PRIVS ( grantee_id, grantor_id, object_type_id )
       VALUES ( 5, 2, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'JavaScript') );
