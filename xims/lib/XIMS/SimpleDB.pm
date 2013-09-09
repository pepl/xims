
=head1 NAME

XIMS::SimpleDB -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SimpleDB;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SimpleDB;

use common::sense;
use parent qw( XIMS::Folder );
use XIMS::DataFormat;
use XIMS::SimpleDBMemberProperty;
use XIMS::SimpleDBMemberPropertyMap;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    my $simpledb = XIMS::SimpleDB->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $simpledb: XIMS::SimpleDB instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'SimpleDB' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my @property_list = $simpledb->mapped_member_properties( [ %args ] );

=head3 Parameter

    $args{part_of_title}    (optional)    : Filter properties by part_of_title
                                            property
    $args{mandatory}        (optional)    : Filter properties by mandatory
                                            property
    $args{gopublic}         (optional)    : Filter properties by gopublic
                                            property

=head3 Returns

    @property_list  : Array of mapped member properties 
                      (XIMS::SimpleDBMemberProperty instances)

=head3 Description

Fetch mapped properties assigned to the SimpleDB

=cut

sub mapped_member_properties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return () unless defined $self->document_id();

    my %params;
    $params{mandatory} = delete $args{mandatory} if exists $args{mandatory};
    $params{part_of_title} = delete $args{part_of_title} if exists $args{part_of_title};
    $params{gopublic} = delete $args{gopublic} if exists $args{gopublic};
    $params{order} = 'position ASC';
    $params{limit} = delete $args{limit} if exists $args{limit};
    $params{offset} = delete $args{offset} if exists $args{offset};

    # Think of doing a join instead of the two queries here...
    my @property_data = $self->data_provider->getSimpleDBMemberPropertyMap( document_id => $self->document_id(), properties => [ qw( property_id ) ] );
    return () unless scalar(@property_data) > 0;
    my @property_ids = map { values %{$_} } @property_data;
    my @data = $self->data_provider->getSimpleDBMemberProperty( id => \@property_ids, %params );
    my @out = map { XIMS::SimpleDBMemberProperty->new->data( %{$_} ) } @data;
    return @out;
}



=head2    my $boolean = $simpledb->map_member_property( $memberproperty );

=head3 Parameter

    $memberproperty                : Instance of XIMS::SimpleDBMemberProperty

=head3 Returns

    True if mapping suceeded, false otherwise

=head3 Description

Maps a SimpleDB member property to a SimpleDB instance

=cut

sub map_member_property {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $memberproperty = shift;

    if ( defined $memberproperty and $memberproperty->isa('XIMS::SimpleDBMemberProperty') and defined $memberproperty->id() ) {
        my $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( document_id => $self->document_id(), property_id => $memberproperty->id() );
        if ( not defined $memberpropertymap ) {
            $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new();
            $memberpropertymap->document_id( $self->document_id() );
            $memberpropertymap->property_id( $memberproperty->id() );
            return $memberpropertymap->create();
        }
        else {
            XIMS::Debug( 3, "Mapping already exists." );
            return;
        }
    }
    else {
        XIMS::Debug( 3, "An existing XIMS::SimpleDBMemberProperty object is needed to map to a SimpleDB" );
        return;
    }
}



=head2    my $boolean = $simpledb->unmap_member_property( $memberproperty );

=head3 Parameter

    $memberproperty                : Instance of XIMS::SimpleDBMemberProperty

=head3 Returns

    True if unmapping suceeded, false otherwise

=head3 Description

Unmaps a SimpleDB member property to a SimpleDB instance

=cut

sub unmap_member_property {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $memberproperty = shift;

    if ( defined $memberproperty and $memberproperty->isa('XIMS::SimpleDBMemberProperty') and defined $memberproperty->id() ) {
        my $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( document_id => $self->document_id(), property_id => $memberproperty->id() );
        if ( defined $memberpropertymap ) {
            return $memberpropertymap->delete();
        }
        else {
            XIMS::Debug( 3, "Mapping does not exist and therefore cannot be deleted." );
            return;
        }
    }
    else {
        XIMS::Debug( 3, "An existing XIMS::SimpleDBMemberProperty object is needed to unmap from a SimpleDB" );
        return;
    }
}



=head2    my $boolean = $item->reposition_property( %args );

=head3 Parameter

    $args{ old_position }    :  Old position
    $args{ new_position }    :  New position
    $args{ property_id }     :  Member property_id

=head3 Returns

    $boolean : True or False for repositioning the property

=head3 Description

Updates position of the member property for a SimpleDB instance

=cut

sub reposition_property {
    my $self = shift;
    my %args = @_;

    my $old_position = delete $args{old_position};
    return unless $old_position;

    my $new_position = delete $args{new_position};
    return unless $new_position;

    return if $old_position == $new_position;

    my $property_id = delete $args{property_id};
    return unless defined $property_id;

    return unless $self->document_id();
    my $position_diff = $old_position - $new_position;

    my ( $udop, $upperop, $lowerop );
    if ( $position_diff > 0 ) {
        $udop    = "+";
        $upperop = "<";
        $lowerop = ">=";
    }
    else {
        $udop    = "-";
        $upperop = ">";
        $lowerop = "<=";
    }

    my @iddata = $self->data_provider->getSimpleDBMemberPropertyMap( document_id => $self->document_id(),
                                                                     properties => [ qw( property_id ) ] );
    my @property_ids = map { values %{$_} } @iddata;
    my $property_id_quotes = join(',', map { '?' } @property_ids);

    my $data = $self->data_provider->dbh->do_update( sql => [ qq{UPDATE cisimpledb_member_properties
                                                    SET
                                                      position = position $udop 1
                                                    WHERE
                                                      position $upperop ?
                                                      AND position $lowerop ?
                                                      AND id IN ($property_id_quotes)
                                                    }
                                                  , $old_position
                                                  , $new_position
                                                  , @property_ids
                                               ],
                                       );

    $data = $self->data_provider->dbh->do_update( table    => 'cisimpledb_member_properties',
                                     values   => { 'position' => $new_position },
                                     criteria => { id => $property_id } );

    return $data;
}



=head2    my $boolean = $item->close_property_position_gap( %args );

=head3 Parameter

    $args{ position }        :  Position of property to be deleted

=head3 Returns

    $boolean : True or False for closing the property position gap

=head3 Description

Closes the position gap resulting in the deletion of a member property of a 
SimpleDB instance

=cut

sub close_property_position_gap {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return unless defined $args{position};
    return unless $self->document_id();

    my @iddata = $self->data_provider->getSimpleDBMemberPropertyMap( document_id => $self->document_id(),
                                                                     properties => [ qw( id ) ] );
    my @property_ids = map { values %{$_} } @iddata;
    my $property_id_quotes = join(',', map { '?' } @property_ids);

    return $self->data_provider->dbh->do_update( sql => [ qq{UPDATE cisimpledb_member_properties
                                                  SET
                                                    position = position - 1
                                                  WHERE
                                                    position > ?
                                                    AND id IN ($property_id_quotes)}
                                                , $args{position}
                                                , @property_ids
                                           ]
                                  );
}



=head2    my ($item_count, $items) = $simpledb->items_granted( [ %args ] )

=head3 Parameter

    $args{ User }         (optional) :  XIMS::User instance

    $args{ limit }        (optional) :  Limit size of $reflibitems arrayref
                                        Usually used together with 'offset' for
                                        pagination
    $args{ offset }       (optional) :  Offset of returned items relative to
                                        total items
                                        Usually used together with 'limit' for
                                        pagination
    $args{ order }        (optional) :  Sort by object property

    $args{ criteria }     (optional) :  Filter items by where clause
                                        (created with XIMS::QueryBuilder::SimpleDB)
                                        for in the mandatory member properties
    $args{ published }    (optional) :  Filter published items
    $args{ gopublic }     (optional) :  Filter properties where gopublic is set

=head3 Returns

    $item_count:  Count of total items
    $items: Arrayref of SimpleDBItems part of the SimpleDB,
                  slice selected by $args{limit} and $args{offset}

=head3 Description

Fetches SimpleDBItems part of the SimpleDB granted to $args{User} or
$simpledb->User resp. Returned SimpleDBItems will include a 'member_values'
key including the items member property values and a 'user_privileges' key
containing the active user object privileges.

=cut

sub items_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $criteria = delete $args{criteria};
    my $gopublic = delete $args{gopublic};
    my $published = delete $args{published};

    my $child_count;
    my @children;
    my %privmask;
    my $userid = $self->User()->id();
    my $properties = 'distinct c.id, m.id AS member_id, d.document_status, d.position, d.parent_id, object_type_id, creation_timestamp, symname_to_doc_id, last_modified_by_middlename, last_modified_by_firstname, language_id, last_publication_timestamp, last_published_by_lastname, css_id, created_by_firstname, data_format_id, keywords, last_modification_timestamp, last_modified_by_id, c.title, c.document_id, location, created_by_lastname, attributes, last_modified_by_lastname, image_id, created_by_id, owned_by_firstname, marked_deleted, last_published_by_id, notes, style_id, owned_by_lastname, owned_by_middlename, abstract, published, locked_by_lastname, locked_by_id, last_published_by_firstname, script_id, owned_by_id, created_by_middlename, data_format_name, locked_by_middlename, last_published_by_middlename, marked_new, locked_time, department_id, locked_by_firstname ';
    my $tables = 'ci_content c, ci_documents d, cisimpledb_members m';
    my $conditions = 'c.document_id = d.id AND m.document_id = d.id AND d.parent_id = ?';
    $conditions .= ' AND c.published = 1' if $published;
    my @values = ( $self->document_id() );
    if ( not $self->User->admin() ) {
        my @userids = ( $userid, $self->User->role_ids());
        $tables .= ', ci_object_privs_granted p';
        $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
        push @values, @userids;
    }

    if ( defined $criteria ) {
        $tables .= ', cisimpledb_mempropertyvalues pv';
        my ( $critstring, @critvals ) = @{$criteria};
        push( @values, @critvals );
        $conditions .= " AND pv.member_id = m.id AND $critstring";
    }

    my $countsql = "SELECT count(distinct c.id) AS cid FROM $tables WHERE $conditions";
    my $countdata = $self->data_provider->driver->dbh->fetch_select( sql => [ $countsql, @values ] );
    $child_count = $countdata->[0]->{cid};

    if ( defined $child_count and $child_count > 0 ) {
        my $sql = "SELECT $properties FROM $tables WHERE $conditions";
        my $data = $self->data_provider->driver->dbh->fetch_select(
                                                                     sql => [ $sql, @values ],
                                                                     limit => $args{limit},
                                                                     offset => $args{offset},
                                                                     order => $args{order}
                                                                     );

        my @gopublic_propids;
        my %pv_param;
        if ( $gopublic ) {
            my @iddata = $self->data_provider->getSimpleDBMemberProperty( gopublic => 1,
                                                                          properties => [ qw( id ) ] );
            @gopublic_propids = map { values %{$_} } @iddata;
            $pv_param{property_id} = \@gopublic_propids;
        }

        my @childids;
        foreach my $kiddo ( @{$data} ) {
            push( @children, (bless $kiddo, 'XIMS::SimpleDBItem') );
            push( @childids, $kiddo->{id} );
            $privmask{$kiddo->{id}} = 0xffffffff if $self->User->admin();

            my @propdata = $self->data_provider->getSimpleDBMemberPropertyValue( member_id => $kiddo->{member_id},
                                                                                 properties => [ qw( property_id value ) ],
                                                                                 %pv_param,
                                                                                 );
            my @propout = map { XIMS::SimpleDBMemberPropertyValue->new->data( %{$_} ) } @propdata;
            $kiddo->{member_values} = { member_value => \@propout };
        }

        if ( not $self->User->admin() ) {
            my @uid_list = ($userid, $self->User->role_ids());
            my @priv_data = $self->data_provider->getObjectPriv( content_id => \@childids,
                                                                 grantee_id => \@uid_list,
                                                                 properties => [ 'privilege_mask', 'content_id' ] );
            foreach my $priv ( @priv_data ) {
                $privmask{$priv->{'objectpriv.content_id'}} |= int($priv->{'objectpriv.privilege_mask'});
            }
        }
    }

    foreach my $child ( @children ) {
        my $privilege_mask = $privmask{$child->{id}};
        $child->{user_privileges} = XIMS::Helpers::privmask_to_hash( $privilege_mask );
    }

    return ($child_count, \@children);
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

