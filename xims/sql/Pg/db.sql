-- drop db
-- DROP DATABASE xims;

-- create db
-- start over with a clean new db, set its encoding to UNICODE
CREATE DATABASE XIMS WITH TEMPLATE = template0 ENCODING = 'UNICODE';

\connect xims
-- install pl/pgsql
CREATE OR REPLACE FUNCTION plpgsql_call_handler () RETURNS language_handler
    AS '$libdir/plpgsql', 'plpgsql_call_handler'
    LANGUAGE c;
CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler;

CREATE EXTENSION tablefunc;
