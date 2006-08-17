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
