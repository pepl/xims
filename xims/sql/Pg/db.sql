-- drop db
DROP DATABASE xims;

-- create db
-- start over with a clean new db, set it's encoding to UNICODE
-- the clientlib will be set up to LATIN1, it will translate on the fly as we are
-- currently using this encoding in xims it is said that Pg will become UNICODE as
-- default in upcoming versions of PostgreSQL
-- i just think this is the 'safe' option here ATM
CREATE DATABASE xims WITH TEMPLATE = template0 ENCODING = 'LATIN1';
-- CREATE DATABASE XIMS WITH TEMPLATE = template0 ENCODING = 'UNICODE';

\connect xims
-- install pl/pgsql
CREATE OR REPLACE FUNCTION plpgsql_call_handler () RETURNS language_handler
    AS '$libdir/plpgsql', 'plpgsql_call_handler'
    LANGUAGE c;
CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler;
