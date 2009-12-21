\echo Inserting new object type SQLReport
INSERT INTO ci_object_types ( id, name, is_fs_container, redir_to_self, publish_gopublic )
       VALUES ( nextval('ci_object_types_id_seq'), 'SQLReport', 0, 1, 1 );

\echo Adding SCHEMA_ID column to CI_CONTENT
ALTER TABLE ci_content ADD COLUMN schema_id INTEGER REFERENCES ci_content ( id );

\echo Adding SUFFIX,EMAIL,URL columns to CILIB_AUTHORS
ALTER TABLE cilib_authors ADD COLUMN suffix VARCHAR(24);
ALTER TABLE cilib_authors ALTER COLUMN suffix SET DEFAULT '';
ALTER TABLE cilib_authors ADD COLUMN email VARCHAR(80);
ALTER TABLE cilib_authors ALTER COLUMN email SET DEFAULT '';
ALTER TABLE cilib_authors ADD COLUMN url VARCHAR(250);
ALTER TABLE cilib_authors ALTER COLUMN url SET DEFAULT '';

\echo Adding valid_from_timestamp and valid_to_timestamp;
ALTER TABLE ci_content ADD COLUMN valid_from_timestamp TIMESTAMP(0)  WITHOUT TIME ZONE;
ALTER TABLE ci_content ALTER COLUMN valid_from_timestamp SET DEFAULT now();
ALTER TABLE ci_content ADD COLUMN valid_to_timestamp TIMESTAMP(0)  WITHOUT TIME ZONE;
UPDATE ci_content set valid_from_timestamp = creation_timestamp;

\echo Dropping Foreign Key 'STYLE_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$2";

\echo Dropping Foreign Key 'SCRIPT_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$3";

\echo Dropping Foreign Key 'CSS_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$8";

\echo Dropping Foreign Key 'IMAGE_ID'
ALTER TABLE CI_CONTENT DROP CONSTRAINT "$9";

\echo Creating Foreign Key 'CTT_CTT_STYLE_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_STYLE_FK FOREIGN KEY (STYLE_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_CSS_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_CSS_FK FOREIGN KEY (CSS_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_IMAGE_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_IMAGE_FK FOREIGN KEY (IMAGE_ID) REFERENCES CI_CONTENT (ID);

\echo Creating Foreign Key 'CTT_CTT_SCRIPT_FK'
ALTER TABLE CI_CONTENT ADD CONSTRAINT CTT_CTT_SCRIPT_FK FOREIGN KEY (SCRIPT_ID) REFERENCES CI_CONTENT (ID);

\echo Renaming ci_documents.status to ci_documents.document_status
ALTER TABLE ci_documents RENAME COLUMN status TO document_status;

BEGIN;
\echo Dropping view ci_content_loblength
DROP VIEW ci_content_loblength;

\echo Extending ci_content.title...this may take some time
ALTER TABLE ci_content ADD ntitle VARCHAR(400);
UPDATE ci_content SET ntitle = CAST(title AS VARCHAR(400));
ALTER TABLE ci_content DROP title;
ALTER TABLE ci_content RENAME ntitle TO title;

\echo Extending lastname and firstname columns...this may take even more time
ALTER TABLE ci_content ADD nlast_published_by_firstname VARCHAR(90);
UPDATE ci_content SET nlast_published_by_firstname = CAST(last_published_by_firstname AS VARCHAR(90));
ALTER TABLE ci_content DROP last_published_by_firstname;
ALTER TABLE ci_content RENAME nlast_published_by_firstname TO last_published_by_firstname;

ALTER TABLE ci_content ADD ncreated_by_firstname VARCHAR(90);
UPDATE ci_content SET ncreated_by_firstname = CAST(created_by_firstname AS VARCHAR(90));
ALTER TABLE ci_content DROP created_by_firstname;
ALTER TABLE ci_content RENAME ncreated_by_firstname TO created_by_firstname;

ALTER TABLE ci_content ADD nowned_by_firstname VARCHAR(90);
UPDATE ci_content SET nowned_by_firstname = CAST(owned_by_firstname AS VARCHAR(90));
ALTER TABLE ci_content DROP owned_by_firstname;
ALTER TABLE ci_content RENAME nowned_by_firstname TO owned_by_firstname;

ALTER TABLE ci_content ADD nlast_modified_by_firstname VARCHAR(90);
UPDATE ci_content SET nlast_modified_by_firstname = CAST(last_modified_by_firstname AS VARCHAR(90));
ALTER TABLE ci_content DROP last_modified_by_firstname;
ALTER TABLE ci_content RENAME nlast_modified_by_firstname TO last_modified_by_firstname;

ALTER TABLE ci_content ADD nlocked_by_firstname VARCHAR(90);
UPDATE ci_content SET nlocked_by_firstname = CAST(locked_by_firstname AS VARCHAR(90));
ALTER TABLE ci_content DROP locked_by_firstname;
ALTER TABLE ci_content RENAME nlocked_by_firstname TO locked_by_firstname;

ALTER TABLE ci_content ADD nlast_published_by_lastname VARCHAR(90);
UPDATE ci_content SET nlast_published_by_lastname = CAST(last_published_by_lastname AS VARCHAR(90));
ALTER TABLE ci_content DROP last_published_by_lastname;
ALTER TABLE ci_content RENAME nlast_published_by_lastname TO last_published_by_lastname;

ALTER TABLE ci_content ADD ncreated_by_lastname VARCHAR(90);
UPDATE ci_content SET ncreated_by_lastname = CAST(created_by_lastname AS VARCHAR(90));
ALTER TABLE ci_content DROP created_by_lastname;
ALTER TABLE ci_content RENAME ncreated_by_lastname TO created_by_lastname;

ALTER TABLE ci_content ADD nowned_by_lastname VARCHAR(90);
UPDATE ci_content SET nowned_by_lastname = CAST(owned_by_lastname AS VARCHAR(90));
ALTER TABLE ci_content DROP created_by_lastname;
ALTER TABLE ci_content RENAME nowned_by_lastname TO created_by_lastname;

ALTER TABLE ci_content ADD nlast_modified_by_lastname VARCHAR(90);
UPDATE ci_content SET nlast_modified_by_lastname = CAST(last_modified_by_lastname AS VARCHAR(90));
ALTER TABLE ci_content DROP created_by_lastname;
ALTER TABLE ci_content RENAME nlast_modified_by_lastname TO created_by_lastname;

ALTER TABLE ci_content ADD nlocked_by_lastname VARCHAR(90);
UPDATE ci_content SET nlocked_by_lastname = CAST(locked_by_lastname AS VARCHAR(90));
ALTER TABLE ci_content DROP created_by_lastname;
ALTER TABLE ci_content RENAME nlocked_by_lastname TO created_by_lastname;

ALTER TABLE ci_users_roles ADD nfirstname VARCHAR(90);
UPDATE ci_users_roles SET nfirstname = CAST(firstname AS VARCHAR(90));
ALTER TABLE ci_users_roles DROP firstname;
ALTER TABLE ci_users_roles RENAME nfirstname TO firstname;

ALTER TABLE ci_users_roles ADD nlastname VARCHAR(90);
UPDATE ci_users_roles SET nlastname = CAST(lastname AS VARCHAR(90));
ALTER TABLE ci_users_roles DROP lastname;
ALTER TABLE ci_users_roles RENAME nlastname TO lastname;

\echo Creating view ci_content_loblength
CREATE VIEW ci_content_loblength (
            binfile
           ,last_modification_timestamp
           ,notes
           ,marked_new
           ,id
           ,locked_time
           ,abstract
           ,body
           ,title
           ,keywords
           ,status
           ,creation_timestamp
           ,attributes
           ,locked_by_id
           ,style_id
           ,script_id
           ,language_id
           ,last_modified_by_id
           ,owned_by_id
           ,created_by_id
           ,css_id
           ,image_id
           ,document_id
           ,published
           ,locked_by_lastname
           ,locked_by_middlename
           ,locked_by_firstname
           ,last_modified_by_lastname
           ,last_modified_by_middlename
           ,last_modified_by_firstname
           ,owned_by_lastname
           ,owned_by_middlename
           ,owned_by_firstname
           ,created_by_lastname
           ,created_by_middlename
           ,created_by_firstname
           ,data_format_name
           ,lob_length
           ,last_publication_timestamp
           ,last_published_by_id
           ,last_published_by_lastname
           ,last_published_by_middlename
           ,last_published_by_firstname
           ,marked_deleted
)
AS
SELECT  c.binfile
       ,c.last_modification_timestamp
       ,c.notes
       ,c.marked_new
       ,c.id
       ,c.locked_time
       ,c.abstract
       ,c.body
       ,c.title
       ,c.keywords
       ,c.status
       ,c.creation_timestamp
       ,c.attributes
       ,c.locked_by_id
       ,c.style_id
       ,c.script_id
       ,c.language_id
       ,c.last_modified_by_id
       ,c.owned_by_id
       ,c.created_by_id
       ,c.css_id
       ,c.image_id
       ,c.document_id
       ,c.published
       ,c.locked_by_lastname
       ,c.locked_by_middlename
       ,c.locked_by_firstname
       ,c.last_modified_by_lastname
       ,c.last_modified_by_middlename
       ,c.last_modified_by_firstname
       ,c.owned_by_lastname
       ,c.owned_by_middlename
       ,c.owned_by_firstname
       ,c.created_by_lastname
       ,c.created_by_middlename
       ,c.created_by_firstname
       ,c.data_format_name
       ,COALESCE( octet_length(c.body), octet_length(c.binfile), 0 )
       AS lob_length
       ,c.last_publication_timestamp
       ,c.last_published_by_id
       ,c.last_published_by_lastname
       ,c.last_published_by_middlename
       ,c.last_published_by_firstname
       ,c.marked_deleted
  FROM ci_content AS c
;

\echo Granting select to ximsrun
GRANT SELECT ON  ci_content_loblength TO ximsrun
;

\echo You may consider running VACUUM FULL ci_content; VACUUM FULL ci_users_roles; to give back some diskspace


COMMIT;