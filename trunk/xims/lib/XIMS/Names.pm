# Copyright (c) 2002-2003 The XIMS Project.

# See the file "LICENSE" for information on usage and redistribution

# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package XIMS::Names;

use strict;

use vars qw( @ResourceTypes %Properties);
use XIMS;

@ResourceTypes = ( 'Session',
                   'User',
                   'Document',
                   'Content',
                   'Object',
                   'ObjectType',
                   'UserPriv',
                   'Bookmark',
                   'DataFormat',
                   'Language',
                   'ObjectPriv',
                   'ObjectTypePriv',
                   'MimeType'
                    );

# this is the master list of all
# properties known.
%Properties = (
  Session => [
               'session.id',
               'session.session_id',
               'session.user_id',
               'session.attributes',
               'session.host',
               'session.last_access_timestamp',
               'session.salt'
             ],
  User =>   [
              'user.password',
              'user.enabled',
              'user.admin',
              'user.id',
              'user.system_privs_mask',
              'user.name',
              'user.lastname',
              'user.middlename',
              'user.firstname',
              'user.email',
              'user.url',
              'user.object_type'
             ],
  Content => [
              'content.binfile',
              'content.last_modification_timestamp',
              'content.notes',
              'content.marked_new',
              'content.id',
              'content.locked_time',
              'content.abstract',
              'content.body',
              'content.title',
              'content.keywords',
              'content.status',
              'content.creation_timestamp',
              'content.attributes',
              'content.locked_by_id',
              'content.style_id',
              'content.script_id',
              'content.language_id',
              'content.last_modified_by_id',
              'content.owned_by_id',
              'content.created_by_id',
              'content.css_id',
              'content.image_id',
              'content.document_id',
              'content.published',
              'content.last_publication_timestamp',
              'content.last_published_by_id',
              'content.marked_deleted',
              'content.locked_by_lastname',
              'content.locked_by_middlename',
              'content.locked_by_firstname',
              'content.last_modified_by_lastname',
              'content.last_modified_by_middlename',
              'content.last_modified_by_firstname',
              'content.owned_by_lastname',
              'content.owned_by_middlename',
              'content.owned_by_firstname',
              'content.created_by_lastname',
              'content.created_by_middlename',
              'content.created_by_firstname',
              'content.last_published_by_lastname',
              'content.last_published_by_middlename',
              'content.last_published_by_firstname',
              'content.data_format_name'
             ],
    Document =>
             [
              'document.location',
              'document.status',
              'document.id',
              'document.parent_id',
              'document.object_type_id',
              'document.department_id',
              'document.data_format_id',
              'document.symname_to_doc_id',
              'document.position'
             ],
    ObjectType =>
             [
              'objecttype.id',
              'objecttype.name',
              'objecttype.is_fs_container',
              'objecttype.is_xims_data',
              'objecttype.redir_to_self',
              'objecttype.publish_gopublic'
             ],
    Bookmark =>
             [
              'bookmark.id',
              'bookmark.content_id',
              'bookmark.owner_id',
              'bookmark.stdhome'
             ],
    DataFormat =>
             [
              'dataformat.mime_type',
              'dataformat.id',
              'dataformat.name',
              'dataformat.suffix'
             ],
    Language =>
             [
              'language.id',
              'language.code',
              'language.fullname'
             ],
    UserPriv =>
             [
              'userpriv.id',
              'userpriv.grantor_id',
              'userpriv.grantee_id',
              'userpriv.role_master',
              'userpriv.default_role'
             ],
    ObjectPriv =>
             [
              'objectpriv.privilege_mask',
              'objectpriv.grantor_id',
              'objectpriv.grantee_id',
              'objectpriv.content_id'
             ],
    ObjectTypePriv =>
             [
              'objecttypepriv.grantor_id',
              'objecttypepriv.grantee_id',
              'objecttypepriv.object_type_id',
              'objecttypepriv.userselection'
             ],
    MimeType =>
             [
              'mimetype.id',

              'mimetype.data_format_id',
              'mimetype.mime_type'
             ],
);

my @oprops = ( @{$Properties{Document}}, @{$Properties{Content}} );
$Properties{Object} = \@oprops;

sub get_URI {
    my ($r_type, $property_name) = @_;
    XIMS::Debug( 1, "Unknown resource type '$r_type'!" ) unless grep { $_ eq $r_type} resource_types();
    if ( $r_type eq 'Object' ) {
        my ( $p, $t ) = reverse ( split /\./, $property_name );
        if ( $t ) {
            return $property_name;
        }
        if ( grep { $_ =~ /^.+?\.$property_name$/ } @{$Properties{Content}} ) {
            return 'content' . '.' . $property_name;
        }
        else {
            return 'document' . '.' . $property_name;
        }
    }
    return $property_name =~ /\./go ? $property_name : lc( $r_type ) . '.' . $property_name;
}

sub property_list {
    my $r_type = shift;
    if ( $r_type ) {
        return $Properties{$r_type};
    }
    else {
        return %Properties;
    }
}

sub property_interface_names {
    my $r_type = shift;
    return [] unless $r_type;
    my @out_list = map{ (split /\./, $_)[1] } @{property_list( $r_type )};
    return \@out_list;
}

sub resource_types {
    return @ResourceTypes;
}

sub properties {
    return %Properties;
}

sub valid_property {
    my ( $r_type, $prop_name ) = @_;
    return 1 if grep { $_ eq $prop_name } @{$Properties{$r_type}};
    return undef;
}

1;
