INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'quality_criterion', '"Quality criterion": One of "peer reviewed", "not peer reviewed", "invited", "popular scientific"', 2400 );

INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'quality_criterion'), 18 );

INSERT INTO cireflib_reference_properties ( id, name, description, position )
       VALUES ( cireflib_refprop_id_seq_nval(), 'local_restricted_url', 'Use "1" to specify that a local copy exists inside the intranet and a link to it will automatically be generated', 2150 );

INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 1 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 2 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 3 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 4 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 5 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 6 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 7 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 8 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 9 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 10 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 11 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 12 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 13 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 14 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 15 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 16 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 17 );
INSERT INTO cireflib_ref_type_propertymap ( id, property_id, reference_type_id )
       VALUES ( cireflib_rtpm_id_seq_nval(), (select id from cireflib_reference_properties where name = 'local_restricted_url'), 18 );

INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, parent_id, davprivval ) 
       VALUES ( ci_object_types_id_seq_nval(), 'Event', 0, 1, 1, (SELECT id FROM CI_OBJECT_TYPES WHERE name = 'VLibraryItem' ), 0 );
INSERT INTO CI_OBJECT_TYPES ( id, name, is_fs_container, is_xims_data, redir_to_self, publish_gopublic, is_mailable ) 
       VALUES ( ci_object_types_id_seq_nval(), 'NewsLetter', 0, 1, 1, 0, 1 );

-- update flags from NULL to 0
UPDATE CI_CONTENT SET marked_new = 0     WHERE marked_new     IS NULL;
UPDATE CI_CONTENT SET marked_deleted = 0 WHERE marked_deleted IS NULL;
UPDATE CI_CONTENT SET published = 0      WHERE published      IS NULL;
