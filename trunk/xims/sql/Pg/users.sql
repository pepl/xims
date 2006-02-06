-- Copyright (c) 2002-2006 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- drop users
DROP USER xims;
DROP USER ximsrun;
-- create with extended privs and empty password
CREATE USER xims    WITH NOCREATEUSER   CREATEDB UNENCRYPTED PASSWORD 'xims';
CREATE USER ximsrun WITH NOCREATEUSER NOCREATEDB UNENCRYPTED PASSWORD 'ximsrun';

