-- Copyright (c) 2002-2003 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
SPOOL testsuite.lst

@@testsuite.ci_documents.sql
@@testsuite.ci_content.sql
@@testsuite.ci_object_privs_granted.sql

commit;
SPOOL OFF
