-- In order to remove clutter and useless parsing effort, we changed the
-- behaviour of attributes to be removed completely when they lack a value.

-- XIMS does this automatically when the respective objects are edited and
-- stored. The following is intended to hint an optional way for a quick cleanup
-- on the DB level but NOT required.

-- DO NOT SIMPY RUN THIS! DOUBLE CHECK WITH YOUR DATA AND GET COMFORTABLE WITH
-- WHAT YOU ARE DOING.


-- remove unused expandrefs attributes 
select attributes, regexp_replace(attributes,'(.*)expandrefs=?[01]?;?(.*)$','\1\2')
from ci_content
where attributes is not null and attributes like '%expandrefs%';

-- update ci_content set attributes = regexp_replace(attributes,'(.*)expandrefs=?[01]?;?(.*)$','\1\2')
-- where attributes is not null and attributes like '%expandrefs%';

-- gen-social-bookmarks=
select attributes, regexp_replace(attributes, '(.*)gen-social-bookmarks=[^1]?(;|$)(.*)$','\1\3')
from ci_content
where attributes like '%gen-social-bookmarks%';

-- update ci_content set attributes = regexp_replace(attributes, '(.*)gen-social-bookmarks=[^1]?(;|$)(.*)$','\1\3')
-- where attributes like '%gen-social-bookmarks%';

-- pagerowlimit=
select attributes, regexp_replace(attributes, '(.*)pagerowlimit=[^\d]?(;|$)(.*)$','\1\3')
from ci_content
where attributes like '%pagerowlimit%';

-- update ci_content set attributes = regexp_replace(attributes, '(.*)pagerowlimit=[^\d]?(;|$)(.*)$','\1\3')
-- where attributes like '%pagerowlimit%';

-- geekmode=0
select attributes, regexp_replace(attributes, '(.*)geekmode=0(;|$)(.*)$','\1\3')
from ci_content
where attributes like '%geekmode=0%';

-- update ci_content set attributes = regexp_replace(attributes, '(.*)geekmode=0(;|$)(.*)$','\1\3')
-- where attributes like '%geekmode=0%';

-- ditto, autoindex=0
-- update ci_content set attributes = regexp_replace(attributes, '(.*)autoindex=0(;|$)(.*)$','\1\3')
-- where attributes like '%autoindex=0%';

-- autoindex=1 and an index document exists
select attributes, regexp_replace(attributes, '(.*)autoindex=1(;|$)(.*)$','\1\3') , location_path 
from ci_documents d
join ci_content c on c.document_id = d.id
where attributes like '%autoindex=1%' 
  and exists (select 1 
              from ci_documents d2 
              where d2.location like 'index%' 
              and   d2.parent_id = d.id);
              
-- update ci_content set attributes = regexp_replace(attributes, '(.*)autoindex=1(;|$)(.*)$','\1\3')
-- where id in 
--   ( select c.id
--     from ci_documents d
--     join ci_content c on c.document_id = d.id
--     where attributes like '%autoindex=1%' 
--       and exists (select 1 
--                   from ci_documents d2 
--                   where d2.location like 'index%' 
--                   and   d2.parent_id = d.id) );

-- =; b0rkage
select attributes, regexp_replace(attributes, '^=;(.*)$','\1') from ci_content
where attributes like '=%';

-- update ci_content set attributes = regexp_replace(attributes, '^=;(.*)$','\1')
-- where attributes like '=%';

-- trailing ;
select attributes, regexp_replace(attributes, '(.*);$','\1') from ci_content
where attributes like '%;';

-- update ci_content set attributes = regexp_replace(attributes, '^(.*);$','\1')
-- where attributes like '%;';

select count(*) from ci_content where attributes is not null;
select attributes from ci_content where attributes is not null;

select attributes from ci_content where attributes like '%;;%';

