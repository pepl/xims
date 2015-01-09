-- Copyright (c) 2002-2015 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id$

INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Book', 'A publication that is complete in one part or a designated finite number of parts, often identified with an ISBN.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Bookitem', 'A defined section of a book, usually with a separate title or number.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Conference', 'A publication bundling the proceedings of a conference.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Proceeding', 'A conference paper or proceeding published in a conference publication.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Report', 'A report or technical report is a published document that is issued by an organization, agency or government body.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Document', 'General document type to be used when available data elements do not allow determination of a more specific document type, i.e. when one has only author and title but no publication information.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Unknown', 'Use when the genre of the document is unknown.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Issue', 'One instance of the serial publication' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Article', 'A document published in a journal.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Preprint', 'An individual paper or report published in paper or electronically prior to its publication' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Invited Talk', 'A given invited talk without being published' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Dissertation', 'A dissertation related to a course of study at an institution of higher education.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Poster', 'A poster presentation at a conference.' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Talk', 'A given talk without being published' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Seminar Talk', 'A given seminar talk without being published' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Colloquium', 'A given colloqium talk without being published' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'Diploma Thesis', 'A diploma thesis related to a course of study at an institution of higher education' );
INSERT INTO cireflib_reference_types ( id, name, description )
       VALUES ( cireflib_reftypes_id_seq_nval(), 'State Doctorate', 'Postdoctoral lecture qualification (Habilitation)' );

-- Descriptions are based on ANSI/NISO Z39.88-2004
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'title', 'Article, Chapter or Ressource title. Chapter title is included if it is a distinct title, i.e. "The Push Westward."', 100 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'btitle', 'Book title.', 150 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'date', 'Date of publication.', 200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'chron', 'Enumeration or chronology in not-normalized form, i.e. "1st quarter". Where numeric dates are also available, place the numeric portion in the "date" Key. So a recorded date of publication of "1st quarter 1992" becomes date=1992;chron=1st quarter. Normalized indications of chronology can be provided in the ssn and quarter Keys.', 210 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'ssn', 'Season (chronology). Legitimate values are spring, summer, fall, winter', 220 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'quarter', 'Quarter (chronology). Legitimate values are 1, 2, 3, 4.', 230 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'volume', 'Volume designation.Volume is usually expressed as a number but could be roman numerals or non-numeric, i.e. "124", or "VI".', 240 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'part', 'Part can be a special subdivision of a volume or it can be the highest level division of the journal. Parts are often designated with letters or names, i.e. "B", "Supplement".', 250 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'issue', 'This is the designation of the published issue of a journal, corresponding to the actual physical piece in most cases. While usually numeric, it could be non-numeric. Note that some publications use chronology in the place of enumeration, i.e. Spring, 1998.', 260 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'spage', 'First page number of a start/end (spage-epage) pair. Note that pages are not always numeric.', 400 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'epage', 'Second (ending) page number of a start/end (spage-epage) pair.', 410 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'pages', 'Start and end pages, i.e. "53-58". This can also be used for an unstructured pagination statement when data relating to pagination cannot be interpreted as a start-end pair, i.e. "A7, C4-9", "1-3,6".', 420 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'artnum', 'Article number assigned by the publisher. Article numbers are often generated for publications that do not have usable pagination, in particular electronic journal articles, i.e. "unifi000000090". A URL may be the only usable identifier for an online article, in which case the URL can be treated as an identifier for the article (i.e. "rft_id=http://www.firstmonday.org/ issues/issue6_2/odlyzko/ index.html").', 430 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'isbn', 'International Standard Book Number (ISBN). The ISBN is usually presented as 9 digits plus a final check digit (which may be "X"), i.e. "057117678X" but it may contain hyphens, i.e. "1-878067-73-7"', 500 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'coden', 'CODEN ', 600 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'sici', 'Serial Item and Contribution Identifier (SICI)', 650 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'place', 'Place of publication. "New York"', 300 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'pub', 'Publisher name. "Harper and Row"', 700 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'edition', 'Statement of the edition of the book. This will usually be a phrase, with or without numbers, but may be a single number. I.e. "First edition", "4th ed."', 800 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'tpages', 'Total pages. Total pages is the largest recorded number of pages, if this can be determined. I.e., "ix, 392 p." would be recorded as "392" in tpages. This data element is usually available only for monographs (books and printed reports). In some cases, tpages may not be numeric, i.e. "F36"', 900 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'series', 'The title of a series in which the book or document was issued. There may also be an ISSN associated with the series.', 1000 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'issn', 'International Standard Serials Number (ISSN). The issn may contain a hyphen, i.e. "1041-5653"', 1100 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'bici', 'Book Item and Component Identifier (BICI). BICI is a draft NISO standard.', 1200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'co', 'Country of publication, i.e. "United States".', 1300 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'inst', 'Institution that issued the disseration, i.e. "University of California, Berkeley".', 1400 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'advisor', 'Disseration advisor, i.e. "Prof. John H. James".', 1410 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'degree', 'Degree conferred, as listed in the metadata, i.e. "PhD", "laurea".', 1420 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'identifier', 'info: identifier (DOI, OAI, PMID, BIBCODE, SIC, ...) E.g. "oai:arXiv.org:hep-th/9901001"', 1500 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'status', 'in Print, "submitted", ...', 1600 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'conf_venue', 'Conference venue (City, Country)', 1700 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'conf_date', 'Date of the conference', 1710 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'conf_title', 'Title of the conference', 1720 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'conf_sponsor', 'Conference sponsor', 1730 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'conf_url', 'URL of the conference''s webpage', 1740 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'url', 'URL of the ressource', 1800 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'access_timestamp', 'Last access time (URL)', 1900 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'citekey', 'Citation Key', 2000 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'url2', 'Alternative URL of the ressource (e.g. local copy)', 2100 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'workgroup', 'Workgroup', 2200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'preprint_identifier', 'E-Print Identifier (E.g. "oai:arXiv.org:hep-th/9901001")', 2200 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'project', 'Name(s) of associated project(s). Separate multiple values using a comma (,)', 2300 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'preprint_submitdate', 'Submittal date of the E-Print version of an article', 2250 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'thesis_inprocess', 'Specify "1" if the thesis is currently being worked on and has not been finished yet, specify "0" or leave blank if the thesis has already been finished.', 1430 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'quality_criterion', '"Quality criterion": One of "peer reviewed", "not peer reviewed", "invited", "popular scientific"', 2400 );
INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'local_restricted_url', 'Use "1" to specify that a local copy exists inside the intranet and a link to it will automatically be generated', 2150 );


INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 1, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 2, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 2, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 2, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 3, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 4, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 4, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 4, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 5, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 5, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 5, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 6, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 6, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 6, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 7, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 8, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 8, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 9, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 9, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 9, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 10, 2);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 10, 4);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 10, 7);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 10, 9);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 11, 2);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 11, 4);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 11, 7);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 11, 9);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 12, 2);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 12, 4);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 12, 7);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 12, 9);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 13, 7);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 13, 9);
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 14, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 15, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 16, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 16, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 16, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 16, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 17, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 18, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 19, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 20, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 21, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 22, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 23, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 24, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 24, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 24, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 24, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 25, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 25, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 25, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 25, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 26, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 26, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 26, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 26, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 27, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 27, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 27, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 27, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 28, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 29, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 29, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 30, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 31, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 32, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 33, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 34, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 35, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 36, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 37, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 38, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 39, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 40, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 41, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 42, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 43, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 43, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 43, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 44, 18 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), 45, 18 );

