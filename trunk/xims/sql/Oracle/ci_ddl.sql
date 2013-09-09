-- Copyright (c) 2002-2013 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$
-- SET ECHO ON

@@ci_ddl.tab
@@ci_ddl.ind
@@ci_ddl.con
@@ci_ddl.sqs
@@ci_ddl_mime_type_aliases.tab
@@ci_ddl_mime_type_aliases.ind
@@ci_ddl_mime_type_aliases.con
@@ci_ddl_mime_type_aliases.sqs
@@ci_ddl_obttypeprivs.tab
@@ci_ddl_obttypeprivs.con
@@ci_ddl_obttypeprivs.ind
@@ci_ddl_obttypeprivs.sqs
@@ci_ddl_sessions.tab
@@ci_ddl_sessions.ind
@@ci_ddl_sessions.con
@@ci_ddl_sessions.sqs
@@ci_ddl_bookmarks.tab
@@ci_ddl_bookmarks.ind
@@ci_ddl_bookmarks.con
@@ci_ddl_bookmarks.sqs
@@ci_ddl_eval.tab
@@ci_ddl_eval.ind
@@ci_ddl_eval.con
@@ci_ddl_eval.sqs

-- CLOB_BYTELENGTH function for ci_content.content_length trigger
@@function_clob_bytelength.sql

-- SYSDATE wrapper
@@function_now.sql

-- SEQ wrappers
@@sequence_nextval_functionwrappers.sql

@@default_data.sql

-- Functions and triggers for location_path denormalization
@@ci_util_location_path.sql

-- VLibrary objects
@@cilib_library_ddl.sql

-- ReferenceLibrary objects
@@cireflib_reference_library_ddl.sql

-- ReferenceLibrary default data
@@../referencelibrary_defaultdata.sql

-- SimpleDB objects
@@cisimpledb_ddl.sql


-- commit;
-- PROMPT Changes have not been commited yet. Type commit; to do so!
commit;

exit;
