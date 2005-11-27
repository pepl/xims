-- Copyright (c) 2002-2005 The XIMS Project.
-- See the file "LICENSE" for information on usage and redistribution
-- of this file, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

SET SESSION AUTHORIZATION 'xims';
SET CLIENT_ENCODING TO 'UNICODE';

\echo Inserting into cireflib_reference_types...

INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Book', 'A publication that is complete in one part or a designated finite number of parts, often identified with an ISBN.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Bookitem', 'A defined section of a book, usually with a separate title or number.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Conference', 'A publication bundling the proceedings of a conference.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Proceeding', 'A conference paper or proceeding published in a conference publication.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Report', 'A report or technical report is a published document that is issued by an organization, agency or government body.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Document', 'General document type to be used when available data elements do not allow determination of a more specific document type, i.e. when one has only author and title but no publication information.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Unknown', 'Use when the genre of the document is unknown.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Issue', 'One instance of the serial publication' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Article', 'A document published in a journal.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Preprint', 'An individual paper or report published in paper or electronically prior to its publication' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Invited Talk', 'A given invited talk without being published' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Dissertation', 'A dissertation related to a course of study at an institution of higher education.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Poster', 'A poster presentation at a conference.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( nextval('cireflib_reference_types_id_seq'), 'Talk', 'A given talk without being published' );


\echo Inserting into cireflib_reference_properties

-- Descriptions are based on ANSI/NISO Z39.88-2004
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'title', 'Article, Chapter or Ressource title. Chapter title is included if it is a distinct title, i.e. "The Push Westward."', 100 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'btitle', 'Book title.', 150 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'date', 'Date of publication.', 200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'chron', 'Enumeration or chronology in not-normalized form, i.e. "1st quarter". Where numeric dates are also available, place the numeric portion in the "date" Key. So a recorded date of publication of "1st quarter 1992" becomes date=1992&chron=1st quarter. Normalized indications of chronology can be provided in the ssn and quarter Keys.', 210 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'ssn', 'Season (chronology). Legitimate values are spring, summer, fall, winter', 220 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'quarter', 'Quarter (chronology). Legitimate values are 1, 2, 3, 4.', 230 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'volume', 'Volume designation.Volume is usually expressed as a number but could be roman numerals or non-numeric, i.e. "124", or "VI".', 240 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'part', 'Part can be a special subdivision of a volume or it can be the highest level division of the journal. Parts are often designated with letters or names, i.e. "B", "Supplement".', 250 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'issue', 'This is the designation of the published issue of a journal, corresponding to the actual physical piece in most cases. While usually numeric, it could be non-numeric. Note that some publications use chronology in the place of enumeration, i.e. Spring, 1998.', 260 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'spage', 'First page number of a start/end (spage-epage) pair. Note that pages are not always numeric.', 400 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'epage', 'Second (ending) page number of a start/end (spage-epage) pair.', 410 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'pages', 'Start and end pages, i.e. "53-58". This can also be used for an unstructured pagination statement when data relating to pagination cannot be interpreted as a start-end pair, i.e. "A7, C4-9", "1-3,6".', 420 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'artnum', 'Article number assigned by the publisher. Article numbers are often generated for publications that do not have usable pagination, in particular electronic journal articles, i.e. "unifi000000090". A URL may be the only usable identifier for an online article, in which case the URL can be treated as an identifier for the article (i.e. "rft_id=http://www.firstmonday.org/ issues/issue6_2/odlyzko/ index.html").', 430 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'isbn', 'International Standard Book Number (ISBN). The ISBN is usually presented as 9 digits plus a final check digit (which may be "X"), i.e. "057117678X" but it may contain hyphens, i.e. "1-878067-73-7"', 500 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'coden', 'CODEN ', 600 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'sici', 'Serial Item and Contribution Identifier (SICI)', 650 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'place', 'Place of publication. "New York"', 300 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'pub', 'Publisher name. "Harper and Row"', 700 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'edition', 'Statement of the edition of the book. This will usually be a phrase, with or without numbers, but may be a single number. I.e. "First edition", "4th ed."', 800 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'tpages', 'Total pages. Total pages is the largest recorded number of pages, if this can be determined. I.e., "ix, 392 p." would be recorded as "392" in tpages. This data element is usually available only for monographs (books and printed reports). In some cases, tpages may not be numeric, i.e. "F36"', 900 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'series', 'The title of a series in which the book or document was issued. There may also be an ISSN associated with the series.', 1000 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'issn', 'International Standard Serials Number (ISSN). The issn may contain a hyphen, i.e. "1041-5653"', 1100 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'bici', 'Book Item and Component Identifier (BICI). BICI is a draft NISO standard.', 1200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'co', 'Country of publication, i.e. "United States".', 1300 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'inst', 'Institution that issued the disseration, i.e. "University of California, Berkeley".', 1400 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'advisor', 'Disseration advisor, i.e. "Prof. John H. James".', 1410 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'degree', 'Degree conferred, as listed in the metadata, i.e. "PhD", "laurea".', 1420 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'identifier', 'info: identifier (DOI, OAI, PMID, BIBCODE, SIC, ...) E.g. "oai:arXiv.org:hep-th/9901001"', 1500 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'status', 'in Print, "submitted", ...', 1600 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'conf_venue', 'Conference venue (City, Country)', 1700 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'conf_date', 'Date of the conference', 1710 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'conf_title', 'Title of the conference', 1720 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'conf_sponsor', 'Conference sponsor', 1730 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'conf_url', 'URL of the conference''s webpage', 1740 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'url', 'URL of the ressource', 1800 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'access_timestamp', 'Last access time (URL)', 1900 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'citekey', 'Citation Key', 2000 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( nextval('cireflib_reference_properties_id_seq'), 'url2', 'Alternative URL of the ressource (e.g. local copy)', 2100 );

\echo Inserting into cireflib_reference_type_propertymap

INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 1, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 2, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 2, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 2, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 3, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 4, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 4, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 4, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 5, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 5, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 5, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 6, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 6, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 6, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 7, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 8, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 8, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 9, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 9, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 9, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 10, 2);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 10, 4);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 10, 7);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 10, 9);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 11, 2);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 11, 4);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 11, 7);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 11, 9);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 12, 2);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 12, 4);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 12, 7);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 12, 9);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 13, 7);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 13, 9);
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 14, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 15, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 16, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 16, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 16, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 16, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 17, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 18, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 19, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 20, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 21, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 22, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 23, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 24, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 24, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 25, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 25, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 26, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 26, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 27, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 27, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 28, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 29, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 29, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 30, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 30, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 30, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 30, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 30, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 31, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 31, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 31, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 31, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 31, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 32, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 33, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 34, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 34, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 34, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 34, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 34, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 35, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 36, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 37, 14 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 1 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 2 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 3 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 4 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 5 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 6 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 7 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 8 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 9 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 10 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 11 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 12 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 13 );
INSERT INTO cireflib_reference_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( nextval('cireflib_reference_type_propertymap_id_seq'), 38, 14 );



