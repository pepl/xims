\connect template1

-- drop and recreate users
\i users.sql
-- drop and recreate database
\i db.sql
-- change user
SET SESSION AUTHORIZATION 'xims';
-- tables, fx, defaultdata
\i create.sql
