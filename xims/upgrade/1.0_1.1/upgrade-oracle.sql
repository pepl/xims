PROMPT Adding ReferenceLibrary objects
@@../../sql/Oracle/cireflib_reference_library_ddl.sql

PROMPT Adding ReferenceLibrary default data
@@../../sql/referencelibrary_defaultdata.sql

PROMPT Adding SimpleDB objects
@@../../sql/Oracle/cisimpledb_ddl.sql

PROMPT Adding new attributes to CILIB_META
ALTER TABLE CILIB_META ADD COVERAGE            VARCHAR2(256);
ALTER TABLE CILIB_META ADD PUBLISHER           VARCHAR2(256);
ALTER TABLE CILIB_META ADD AUDIENCE            VARCHAR2(256);
ALTER TABLE CILIB_META ADD DC_DATE             DATE;
ALTER TABLE CILIB_META ADD DATE_FROM_TIMESTAMP DATE;
ALTER TABLE CILIB_META ADD DATE_TO_TIMESTAMP   DATE;

COMMIT;

