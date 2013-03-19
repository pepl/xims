\connect template1

-- drop db
DROP DATABASE xims;
-- drop users
DROP USER xims;
DROP USER ximsrun;


-- (re)create users
\i users.sql
-- (re)create database
\i db.sql
-- tables, fx, defaultdata
\i create.sql
-- add default data (object types, data formats, languages, root folder, ...)
\i defaultdata.sql
-- Functions and triggers for location_path denormalization
\i location_path.sql
-- VLibrary objects
\i create_library.sql
-- Reference Library objects
\i create_referencelibrary.sql
-- SimpleDB objects
\i create_simpledb.sql


