
=head1 NAME

XIMS::ReferenceLibrary -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::ReferenceLibrary;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::ReferenceLibrary;

use strict;
use parent qw( XIMS::Folder );
use XIMS::DataFormat;
use XIMS::RefLibReferenceType;
use XIMS::VLibAuthor;
use XIMS::RefLibSerial;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    my $reflib = XIMS::ReferenceLibrary->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from XIMS::Object::new()

=head3 Returns

    $reflib: instance of XIMS::ReferenceLibrary

=head3 Description

Fetches existing objects or creates a new instance of XIMS::ReferenceLibrary
for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'ReferenceLibrary' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my @reference_types = $reflib->reference_types( [ %args ] )

=head3 Parameter

    %args: One of the properties of XIMS::ReflibReferenceType

=head3 Returns

    @reference_types: Array of available reference types

=head3 Description

Fetches available reference types. Reference Types can be filtered by a reference
type property. (E.g. name => '%Talk%')

=cut

sub reference_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $cache;
    $cache = 1 unless scalar keys %args > 0;
    if ( defined $cache and defined $self->{'_cachedreft'} ) {
        return @{$self->{'_cachedreft'}};
    }
    my @data = $self->data_provider->getRefLibReferenceType( %args );
    my @out = map { XIMS::RefLibReferenceType->new->data( %{$_} ) } @data;
    $self->{'_cachedreft'} = \@out if defined $cache;
    return @out;
}



=head2    my @reference_properties = $reflib->reference_properties( [ %args ] )

=head3 Parameter

    %args: One of the properties of XIMS::ReflibReferenceProperty

=head3 Returns

    @reference_properties: Array of available reference properties

=head3 Description

Fetches available reference properties. Reference Properties can be filtered by a reference
property property. (E.g. name => '%conf%')

=cut

sub reference_properties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $cache;
    $cache = 1 unless scalar keys %args > 0;
    if ( defined $cache and defined $self->{'_cachedrefp'} ) {
        return @{$self->{'_cachedrefp'}};
    }
    my @data = $self->data_provider->getRefLibReferenceProperty( %args );
    my @out = map { XIMS::RefLibReferenceProperty->new->data( %{$_} ) } @data;
    $self->{'_cachedrefp'} = \@out if defined $cache;
    return @out;
}



=head2    my @vlauthors = $reflib->vlauthors()

=head3 Parameter

    none

=head3 Returns

    @vlauthors: Array of VLAuthors mapped to the Reference Library

=head3 Description

Fetches VLAuthors mapped to the Reference Library

=cut

sub vlauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = 'Author';

    my $sql = 'select DISTINCT m.'.$type.'_id AS ID from cireflib_'.$type.'map m, ci_documents d, cireflib_references r where d.id = r.document_id and r.id = m.reference_id and d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method = "getVLib$type";
    my @data = $self->data_provider->$method( id => \@ids );
    my $class = "XIMS::VLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}



=head2    my @vlserials = $reflib->vlserials()

=head3 Parameter

    none

=head3 Returns

    @vlserials: Array of RefLibSerials mapped to the Reference Library

=head3 Description

Fetches RefLibSerials mapped to the Reference Library

=cut

sub vlserials {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = 'Serial';

    my $sql = 'select DISTINCT r.'.$type.'_id AS ID from ci_documents d, cireflib_references r where d.id = r.document_id and d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method = "getRefLib$type";
    my @data = $self->data_provider->$method( id => \@ids );
    my $class = "XIMS::RefLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}



=head2    my ($item_count, $reflibitems) = $reflib->items_granted( [ %args ] )

=head3 Parameter

    $args{ User }              :  XIMS::User instance

    $args{ limit }             :  Limit size of $reflibitems arrayref
                                  Usually used together with 'offset' for
                                  pagination
    $args{ offset }            :  Offset of returned items relative to total
                                  items. Usually used together with 'limit' for
                                  pagination
    $args{ order }             :  Sort by object property

    $args{ criteria }          :  Filter items by where clause (created with
                                  XIMS::QueryBuilder::ReferenceLibrary)
    $args{ published }         :  Filter published items
    $args{ date }              :  Filter items by date ReflibReferenceProperty
    $args{ author_id }         :  Filter items by VLAuthor id
    $args{ author_lname }      :  Filter items by VLAuthor lastname
    $args{ serial_id }         :  Filter items by ReflibSerial id
    $args{ reference_type_id } :  Filter items by reference_type_id
    $args{ workgroup_id }      :  Filter items by workgroup_id

=head3 Returns

    $item_count:  Count of total items
    $reflibitems: Arrayref of ReferenceLibraryItems part of the Reference
                  Library, slice selected by $args{limit} and $args{offset}

=head3 Description

Fetches ReferenceLibraryItems part of the Reference Library granted to
$args{User} or $reflib->User resp. Returned ReferenceLibraryItems will include
'authorgroup' and 'editorgroup' keys containing arrayrefs of authors and editors
assigned to the ReferenceLibraryItem as well as a 'user_privileges' key containing
the active user object privileges. Args are optional.

=cut

sub items_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    my $date = delete $args{date};
    my $author_id = delete $args{author_id};
    my $author_lname = delete $args{author_lname};
    my $serial_id = delete $args{serial_id};
    my $reference_type_id = delete $args{reference_type_id};
    my $workgroup_id = delete $args{workgroup_id};
    my $criteria = delete $args{criteria};
    my $published = delete $args{published};

    my $child_count;
    my @children;
    my %privmask;
    my $userid = $user->id();
    my $properties = 'distinct c.id, r.id AS reference_id, r.serial_id, r.reference_type_id, d.document_status, d.position, d.parent_id, object_type_id, creation_timestamp, symname_to_doc_id, last_modified_by_middlename, last_modified_by_firstname, language_id, last_publication_timestamp, last_published_by_lastname, css_id, created_by_firstname, data_format_id, keywords, last_modification_timestamp, last_modified_by_id, c.title, c.document_id, location, created_by_lastname, attributes, last_modified_by_lastname, image_id, created_by_id, owned_by_firstname, marked_deleted, last_published_by_id, notes, style_id, owned_by_lastname, owned_by_middlename, abstract, published, locked_by_lastname, locked_by_id, last_published_by_firstname, script_id, owned_by_id, created_by_middlename, data_format_name, locked_by_middlename, last_published_by_middlename, marked_new, locked_time, department_id, locked_by_firstname ';
    my $tables = 'ci_content c, ci_documents d, cireflib_references r';
    my $conditions = 'c.document_id = d.id AND r.document_id = d.id AND d.parent_id = ?';
    $conditions .= ' AND c.published = 1' if $published;
    my @values = ( $self->document_id() );
    if ( not $user->admin() ) {
        my @userids = ( $userid, $user->role_ids());
        $tables .= ', ci_object_privs_granted p';
        $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
        push @values, @userids;
    }

    if ( defined $criteria ) {
        $tables .= ', cireflib_authormap am';
        # Allow both a literal string and a array ref [ $string, @vals ] to be passed 
        my $critstring;
        my @critvals;
        if ( not ref $criteria and length $criteria) {
            $critstring = $criteria;
        }
        elsif ( ref $criteria eq 'ARRAY' ) {
            ( $critstring, @critvals ) = @{$criteria};
            push( @values, @critvals );
        }
        else {
            XIMS::Debug( 2, "Illegal parameters passed" );
            return ();
        }
        $conditions .= " AND am.reference_id = r.id AND $critstring";
    }
    else {
        if ( defined $reference_type_id ) {
            $conditions .= " AND r.reference_type_id = ?";
            push @values, $reference_type_id;
        }
        if ( defined $date ) {
            $tables .= ', cireflib_ref_propertyvalues pv';
            $conditions .= " AND pv.reference_id = r.id AND pv.property_id = (SELECT id FROM cireflib_reference_properties WHERE name = 'date') AND pv.value LIKE ?";
            push @values, $date;
        }
        if ( defined $workgroup_id ) {
            unless ( defined $date ) {
                $tables .= ', cireflib_ref_propertyvalues pv';
                $conditions .= ' AND pv.reference_id = r.id ';
            }
            $conditions .= " AND pv.property_id = (SELECT id FROM cireflib_reference_properties WHERE name = 'workgroup') AND pv.value LIKE ?";
            push @values, $workgroup_id;
        }
        if ( defined $author_id ) {
            $tables .= ', cireflib_authormap am';
            $conditions .= " AND am.reference_id = r.id AND am.author_id = ?";
            push @values, $author_id;
        }
        elsif ( defined $author_lname ) {
            $tables .= ', cireflib_authormap am';
            $conditions .= " AND am.reference_id = r.id AND am.author_id in (SELECT id FROM cilib_authors WHERE lower(lastname) LIKE ?)";
            push @values, lc $author_lname;
        }
        if ( defined $serial_id ) {
            $conditions .= " AND r.serial_id = ?";
            push @values, $serial_id;
        }
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

        my @childids;
        foreach my $kiddo ( @{$data} ) {
            push( @children, (bless $kiddo, 'XIMS::ReferenceLibraryItem') );
            push( @childids, $kiddo->{id} );
            $privmask{$kiddo->{id}} = 0xffffffff if $user->admin();

            my $audata = $self->data_provider->driver->dbh->fetch_select( table => [ qw( cireflib_authormap cilib_authors ) ],
                                                                          criteria => { 'cilib_authors.id'  => \'cireflib_authormap.author_id',
                                                                                        'cireflib_authormap.reference_id' => $kiddo->{reference_id}
                                                                                       } );
            my @authors;
            my @editors;
            foreach my $author ( @{$audata} ) {
                if ( $author->{role} eq '0' ) {
                    push( @authors, $author );
                }
                else {
                    push( @editors, $author );
                }
            }
            $kiddo->{authorgroup} = { author => \@authors };
            $kiddo->{editorgroup} = { author => \@editors };

            my @propdata = $self->data_provider->getRefLibReferencePropertyValue( reference_id => $kiddo->{reference_id},
                                                                                  properties => [ qw( property_id value ) ] );
            my @propout = map { XIMS::RefLibReferencePropertyValue->new->data( %{$_} ) } @propdata;
            $kiddo->{reference_values} = { reference_value => \@propout };
        }

        if ( not $user->admin() ) {
            my @uid_list = ($userid, $user->role_ids());
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

Copyright (c) 2002-2011 The XIMS Project.

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

