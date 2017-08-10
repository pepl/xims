-- Copyright (c) 2002-2017 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

-- Drop the old instance of CI_CONTENT_LOBLENGTH

-- DROP VIEW ci_content_loblength
-- View CI_CONTENT_LOBLENGTH

CREATE OR REPLACE VIEW ci_content_loblength (
   binfile,
   last_modification_timestamp,
   notes,
   marked_new,
   id,
   locked_time,
   abstract,
   body,
   title,
   keywords,
   filename_external,
   status,
   creation_timestamp,
   attributes,
   locked_by_id,
   style_id,
   script_id,
   language_id,
   last_modified_by_id,
   owned_by_id,
   created_by_id,
   css_id,
   image_id,
   document_id,
   published,
   locked_by_lastname,
   locked_by_middlename,
   locked_by_firstname,
   last_modified_by_lastname,
   last_modified_by_middlename,
   last_modified_by_firstname,
   owned_by_lastname,
   owned_by_middlename,
   owned_by_firstname,
   created_by_lastname,
   created_by_middlename,
   created_by_firstname,
   data_format_name,
   lob_length,
   last_publication_timestamp,
   last_published_by_id,
   last_published_by_lastname,
   last_published_by_middlename,
   last_published_by_firstname,
   marked_deleted
)
AS
SELECT c.binfile,
       c.last_modification_timestamp,
       c.notes,
       c.marked_new,
       c.id,
       c.locked_time,
       c.abstract,
       c.body,
       c.title,
       c.keywords,
       c.filename_external,
       c.status,
       c.creation_timestamp,
       c.attributes,
       c.locked_by_id
       , c.style_id
       , c.script_id
       , c.language_id
       , c.last_modified_by_id
       , c.owned_by_id
       , c.created_by_id
       , c.css_id
       , c.image_id
       , c.document_id
       , c.published
       , c.locked_by_lastname
       , c.locked_by_middlename
       , c.locked_by_firstname
       , c.last_modified_by_lastname
       , c.last_modified_by_middlename
       , c.last_modified_by_firstname
       , c.owned_by_lastname
       , c.owned_by_middlename
       , c.owned_by_firstname
       , c.created_by_lastname
       , c.created_by_middlename
       , c.created_by_firstname
       , c.data_format_name
       , DECODE(NVL(CLOB_BYTELENGTH (c.body), 0), 0,
                   NVL(DBMS_LOB.getlength (c.binfile), 0),
                   NVL(CLOB_BYTELENGTH (c.body), 0)
                   ) lob_length
       , c.last_publication_timestamp
       , c.last_published_by_id
       , c.last_published_by_lastname
       , c.last_published_by_middlename
       , c.last_published_by_firstname
       , c.marked_deleted
  FROM ci_content c
/

-- End of DDL script for CI_CONTENT_LOBLENGTH
