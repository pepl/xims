-- drop db
DROP DATABASE xims;
-- create
CREATE DATABASE xims WITH TEMPLATE = template0 ENCODING = 'LATIN1';


\connect xims
-- install pl/pgsql
CREATE OR REPLACE FUNCTION plpgsql_call_handler () RETURNS language_handler
    AS '$libdir/plpgsql', 'plpgsql_call_handler'
    LANGUAGE c;
CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler;
