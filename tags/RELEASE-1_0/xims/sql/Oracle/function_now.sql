-- Copyright (c) 2002-2005 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
CREATE OR REPLACE FUNCTION now RETURN DATE
AS 
BEGIN
   RETURN SYSDATE;
END;
/