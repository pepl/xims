
=head1 NAME

XIMS::DepartmentRoot

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::DepartmentRoot;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::DepartmentRoot;

use common::sense;
use parent qw( XIMS::Folder );
use XIMS::Portlet;
use XIMS::URLLink;
use XIMS::DataFormat;
use XIMS::Importer::Object;
use XIMS::Importer::Object::URLLink;

use XML::LibXML;




=head2    XIMS::DepartmentRoot->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $dept: XIMS::DepartmentRoot instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'DepartmentRoot' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}


=head2    my $boolean = $deptroot->add_departmentlinks( @objects );

=head3 Parameter

    @objects    : Array of content objects to be used as departmentlinks

=head3 Returns

    $boolean : True or False on success or failure

=head3 Description

Checks for an already assigned departmentlinks portlet and adds additional
departmentlinks if such portlet already exists.  If not, a 'departmentlinks'
folder is created, the departmentlinks and the portlet added and assigned
respectively.

=cut

sub add_departmentlinks {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @objects = @_;

    return unless @objects and scalar @objects > 0;

    my $oimporter = XIMS::Importer::Object->new( User => $self->User, Parent => $self );

    # hardcode alarm
    my $dpl_location = 'departmentlinks';
    my $dplp_location = 'departmentlinks_portlet.ptlt';

    # check for portlet
    my @portlet_ids = $self->get_portlet_ids();

    my $deptlinksportlet;
    $deptlinksportlet = XIMS::Portlet->new( id => \@portlet_ids, location => $dplp_location, marked_deleted => 0 ) if $portlet_ids[0];

    my $deptlinksfolder;
    $deptlinksfolder = $deptlinksportlet->target() if $deptlinksportlet;
    $deptlinksfolder = undef if (defined $deptlinksfolder and $deptlinksfolder->marked_deleted());
    if ( not $deptlinksfolder ) {
        # add folder if its not here already
        my @children = $self->children( location => $dpl_location, marked_deleted => 0 );
        $deptlinksfolder = $children[0];
        if ( not ($deptlinksfolder and $deptlinksfolder->id) ) {
            $deptlinksfolder = XIMS::Folder->new( User => $self->User, location => $dpl_location );
            my $id = $oimporter->import( $deptlinksfolder );
            if ( not $id ) {
                XIMS::Debug( 2, "could not create departmentlinks folder '$dpl_location'" );
                return;
            }
        }
    }

    # add links
    my $urlimporter = XIMS::Importer::Object::URLLink->new( User => $self->User, Parent => $deptlinksfolder );
    return unless $urlimporter;
    my $location_path;
    foreach my $object ( @objects ) {
        next if ($object->location eq $dpl_location or $object->location eq $dplp_location);
        $location_path = XIMS::RESOLVERELTOSITEROOTS() eq '1' ? $object->location_path_relative() : $object->location_path();
        my $urllink = XIMS::URLLink->new( User => $self->User(),
                                          location => $location_path,
                                          title => $object->title(),
                                          abstract => $object->abstract(),
                                       );
        my $id = $urlimporter->import( $urllink );
        XIMS::Debug( 3, "could not create departmentlink '$location_path'. Perhaps it already exists." ) unless $id;
    }

    # create and assign portlet if neccessary
    if ( not $deptlinksportlet ) {
        my $dplp_location_nosuffix = $dplp_location;
        $dplp_location_nosuffix =~ s/\.[^\.]+$//;
        $deptlinksportlet = XIMS::Portlet->new( User => $self->User, location => $dplp_location, title => $dplp_location_nosuffix );
        $deptlinksportlet->target( $deptlinksfolder );
        # *do not look at the following lines, hack-attack!*
        # see portlet::generate_body why this hack is here.
        # REWRITE!
        my $body = '<content><column name="abstract"/><column name="location"/><column name="title"/><object-type name="URLLink"/></content>';
        $deptlinksportlet->body( $body );
        my $id = $oimporter->import( $deptlinksportlet );
        if ( not $id ) {
            XIMS::Debug( 2, "could not create departmentlinks portlet '$dplp_location'" );
            return;
        }
        if ( not ($self->add_portlet( $deptlinksportlet ) and $self->update()) ) {
            XIMS::Debug( 2, "could not assign departmentlinks portlet '$dplp_location'" );
            return;
        }
    }

    return 1;
}


=head2    my @portlet_ids = $deproot->get_portlet_ids();

=head3 Parameter

    none

=head3 Returns

    @portlet_ids : Array of content ids of portlets stored in the body's
    XML-Fragment

=head3 Description

Returns a list of content ids of the portlets stored in the body's
XML-Fragment. In scalar context it returns the first entry.

=cut

sub get_portlet_ids {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my @portlet_ids;

    return unless ($self->body and length $self->body);

    my $fragment = $self->_getbodyfragment();
    return unless $fragment;

    foreach my $node ( grep {$_->nodeName() eq 'portlet'} $fragment->childNodes ) {
        push @portlet_ids, $node->string_value();
    }

    return unless (@portlet_ids and scalar @portlet_ids > 0);
    return wantarray ? @portlet_ids : $portlet_ids[0];
}



=head2    my $boolean = $deproot->add_portlet( $target );

=head3 Parameter

    $target   :  XIMS::Object instance or location_path to one

=head3 Returns

    $boolean : True or False on success or failure

=head3 Description

Adds a portlet entry to the body in form of an XML-Fragment.
Storing the portlets that way and not relational is something still
to be discussed I guess.

=cut

sub add_portlet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $target = shift;

    return unless $target;

    my $pobject;
    $pobject = $target if (ref $target and $target->isa('XIMS::Object'));
    $pobject ||= XIMS::Portlet->new( User => $self->User, path => $target, marked_deleted => 0 );
    if ( $pobject ) {
        my $id = $pobject->id;
        XIMS::Debug( 4, "got portlet with id=$id for $target");
        if ( defined $self->body() and length $self->body() > 1 ) {
            XIMS::Debug( 4, "found an existing portlet assignment" );

            my $fragment = $self->_getbodyfragment();
            return unless $fragment;

            # check if id is already there
            my ( $node ) = grep {$_->string_value() eq $id} $fragment->childNodes;
            if ( defined $node ) {
                XIMS::Debug( 3, "portlet ($id) already assigned" );
                return 0;
            }
            else {
                XIMS::Debug( 4, "inserting the entry" );
                $node = XML::LibXML::Element->new("portlet");
                $node->appendText( $id );
                $fragment->appendChild( $node );

                XIMS::Debug( 4, "storing body back. " );
                $self->body( $fragment->toString() );
            }
        }
        else {
            $self->body( "<portlet>$id</portlet>" );
        }
    }
    else {
        XIMS::Debug( 3, "Portlet not found for $target!");
        return;
    }

    return 1;
}


=head2    my $boolean = $deproot->remove_portlet( $portlet_id );

=head3 Parameter

    $portlet_id   :  Content id of portlet to be removed

=head3 Returns

    $boolean : True or False on success or failure

=head3 Description

Removes a portlet entry from the body's XML-Fragment.

=cut

sub remove_portlet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $portlet_id = shift;

    return unless ($portlet_id and $portlet_id > 0);
    return unless ($self->body and length $self->body);

    my $fragment = $self->_getbodyfragment();
    return unless $fragment;

    my ( $node ) = grep {$_->string_value() eq $portlet_id} $fragment->childNodes;
    if ( defined $node ) {
        XIMS::Debug( 6, "found node" );
        $node->unbindNode; # remove node from its context.
        my $newbody = $fragment->toString()?$fragment->toString():' ';
        $self->body( $newbody );
    }
    else {
        XIMS::Debug( 3, "no portlet with id '$portlet_id' found" );
        return 0;
    }

    return 1;
}

=head2    my $boolean = $deproot->convert2folder;

=head3 Parameter

    none

=head3 Returns

    True or False on success or failure

=head3 Description

    Converts a DepartmentRoot into a Folder, updates its children's department
    id and voids department properties after storing them in the notes field
    as plain text for later reference.

=cut

sub convert2folder {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # store departmentroot information into notes and
    # delete departmentroot-specific information
    my $notes = $self->notes();
    foreach my $property (qw(image_id style_id script_id css_id feed_id attributes body)) {
        $notes .= $self->$property ? "\n$property: " . $self->$property: '';
        if ($property eq 'body') {
            $self->$property( ' ' );
        }
        else {
            $self->$property( undef );
        }
    }
    $self->notes($notes) if length($notes);

    # Update the department_id of descendants
    my $iterator = $self->descendants( department_id => $self->document_id() );

    if ( defined $iterator ) {
        while ( my $descendant = $iterator->getNext() ) {
            $descendant->department_id( $self->department_id() );
            if ( $descendant->update( User => $self->User, no_modder => 1 ) ) {
                XIMS::Debug(4, "Updated department_id of '" . $descendant->title . "'.\n");
            }
            else {
                XIMS::Debug(4, "Could not update department_id of '" . $descendant->location_path . "'.\n");
            }
        }
    }

    $self->object_type_id( XIMS::ObjectType->new( name => 'Folder' )->id() );
    $self->data_format_id( XIMS::DataFormat->new( name => 'Container' )->id() );

    return $self->data_provider->updateObject( $self->data() );
}


sub _getbodyfragment {
    my $self = shift;

    my $parser = XML::LibXML->new();
    my $fragment;
    eval {
        $fragment = $parser->parse_balanced_chunk( $self->body );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "problem with the department body ($@)"  );
        return;
    }

    return $fragment;
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

Copyright (c) 2002-2015 The XIMS Project.

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

