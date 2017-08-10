-- Copyright (c) 2002-2017 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
CREATE OR REPLACE FUNCTION now RETURN DATE
AS 
BEGIN
   RETURN SYSDATE;
END;
/