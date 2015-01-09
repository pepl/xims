
=head1 NAME

XIMS::CGI::ReferenceLibraryItem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::ReferenceLibraryItem;

=head1 DESCRIPTION

It is based on XIMS::CGI.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::ReferenceLibraryItem;

use common::sense;
use parent qw(XIMS::CGI);
use XIMS::ReferenceLibrary;
use XIMS::RefLibReference;
use XIMS::RefLibReferenceType;
use XIMS::VLibAuthor;
use XIMS::RefLibSerial;
use XIMS::RefLibReferencePropertyValue;
use XIMS::Importer::Object::ReferenceLibraryItem;
use Encode;
use Locale::TextDomain ('info.xims');


=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          obj_acllist
          obj_acllight
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          remove_author_mapping
          remove_serial_mapping
          create_author_mapping
          create_editor_mapping
          create_serial_mapping
          reposition_author
          change_reference_type
          )
        );
}

=head2 event_init()

=cut

sub event_init {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator( 'XIMS::SAX::Generator::ReferenceLibraryItem' );
    $self->SUPER::event_init( $ctxt );

    my $reftype = $self->param( 'reftype' );
    if ( defined $reftype ) {
        my $reference_type = XIMS::RefLibReferenceType->new( id => $reftype );
        if ( defined $reference_type ) {
            my $reference = XIMS::RefLibReference->new->data( reference_type_id => $reftype );
            $ctxt->object->reference( $reference );
        }
        else {
            $self->sendError( $ctxt, __"Could not resolve reference type." );
            return 0;
        }
    }
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # check for author title, date here as minumum properties

    my $body;
    my $fh = $self->upload( 'file' );
    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    if ( defined $body and length $body ) {
        if ( $ctxt->object->body( $body ) ) {
            XIMS::Debug( 6, "Body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "Could not set body." );
            $self->sendError( $ctxt, __"Could not set body." );
            return 0;
        }
    }

    my $abstract = $self->param( 'abstract' );
    # check if a valid abstract is given
    if ( defined $abstract and (length $abstract and $abstract !~ /^\s+$/ or not length $abstract) ) {
        XIMS::Debug( 6, "abstract, len: " . length($abstract) );
        $ctxt->object->abstract( $abstract );
    }

    my $notes = $self->param( 'notes' );
    # check if valid notes are given
    if ( defined $notes and (length $notes and $notes !~ /^\s+$/ or not length $notes) ) {
        XIMS::Debug( 6, "notes, len: " . length($notes) );
        $ctxt->object->notes( $notes );
    }


    if ( $ctxt->parent() ) {
        my $reference = $ctxt->object->reference();
        if ( not defined $reference ) {
            $self->sendError( $ctxt, __"Missing Reference Type." );
            return 0
        }
        my $importer = XIMS::Importer::Object::ReferenceLibraryItem->new( User => $ctxt->session->user(), Parent => $ctxt->parent() );
        my $identifier = XIMS::trim( $self->param( 'identifier' ) );
        if ( defined $identifier and length $identifier and not $importer->check_duplicate_identifier( $identifier ) ) {
            XIMS::Debug( 3, "Reference with the same identifier already exists." );
            $self->sendError( $ctxt , __"Reference with the same identifier already exists." );
            return 0;
        }
        $ctxt->object->location( 'dummy.xml' );
        if ( $importer->import( $ctxt->object() ) ) {
            XIMS::Debug( 4, "Import of ReferenceLibraryItem successful." );
            $ctxt->object->location( $ctxt->object->document_id() . '.' . $ctxt->object->data_format->suffix());
            $reference->document_id( $ctxt->object->document_id() );
            if ( $reference->create() ) {
                XIMS::Debug( 4, "Successfully created reference object." );
            }
            else {
                XIMS::Debug( 2, "Could not create reference object." );
                $self->sendError( $ctxt , __"Could not create reference object." );
                return 0;
            }
        }
        else {
            XIMS::Debug( 2, "Could not import ReferenceLibraryItem" );
            $self->sendError( $ctxt , __"Could not import ReferenceLibraryItem" );
            return 0;
        }
    }
    else {
        unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
            return $self->event_access_denied( $ctxt );
        }
    }


    $self->create_author_mapping( $ctxt );
    $self->create_serial_mapping( $ctxt );
    $self->update_properties( $ctxt );
    $ctxt->object->update_title( $self->param('date'), $self->param('title') );

    if ( not $ctxt->parent() ) {
        XIMS::Debug( 6, "unlocking object" );
        $ctxt->object->unlock();
    }

    if ( not $ctxt->object->update() ) {
        XIMS::Debug( 2, "update failed" );
        $self->sendError( $ctxt, __"Update of object failed." );
        return 0;
    }
    my $rdpath = $self->redirect_uri($ctxt);

    if ( $self->param('proceed_to_edit') == 1 ) {
        $rdpath .=
          ( $self->redirect_uri($ctxt) =~ /\?/ ) ? ';edit=1' : '?edit=1';
    }
    $self->redirect( $rdpath );
    return 1;
}

=head2 create_author_mapping()

=cut

sub create_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $vlauthor = $self->param('vlauthor');
    my $vleditor = $self->param('vleditor');

    if ( $vlauthor or $vleditor ) {
        $ctxt->object->create_author_mapping_from_name( 0, $vlauthor ) if $vlauthor;
        $ctxt->object->create_author_mapping_from_name( 1, $vleditor ) if $vleditor;
        if ( $vlauthor and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        return 1;
    }

    return 0;
}

=head2 create_serial_mapping()

=cut

sub create_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $vlserial = $self->param('vlserial');

    if ( $vlserial ) {
        my $serial = XIMS::RefLibSerial->new( title => XIMS::escapewildcard( $vlserial ) );
        if ( not defined $serial ) {
            $serial = XIMS::RefLibSerial->new->data( title => $vlserial );
            if ( not $serial->create() ) {
                XIMS::Debug( 3, "Could not create serial $vlserial." );
                return 0;
            }
        }
        return $ctxt->object->vleserial( $serial );
    }

    return 0;
}

=head2 update_properties()

=cut

sub update_properties {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $reference = $ctxt->object->reference;

    foreach my $property ( $ctxt->object->property_list() ) {
        my $value = $self->param( $property->name() );
        next unless defined $value;
        $value = XIMS::trim( $value );

        my $reflibpropval = XIMS::RefLibReferencePropertyValue->new( property_id => $property->id(), reference_id => $reference->id() );
        if ( defined $reflibpropval ) {
            if ( defined $reflibpropval->value and defined $value and $reflibpropval->value ne $value
                or defined $reflibpropval->value and not defined $value
                or not defined $reflibpropval->value and defined $value ) {
                $reflibpropval->value( $value );
                if ( $reflibpropval->update() ) {
                    XIMS::Debug( 4, "Updated value of " . $property->name() );
                }
            }
        }
        else {
            $reflibpropval = XIMS::RefLibReferencePropertyValue->new->data( property_id => $property->id(),
                                                                       reference_id => $reference->id(),
                                                                       value => $value );
            if ( not $reflibpropval->create() ) {
                XIMS::Debug( 3, "Could not set value of " .  $property->name() );
            }
        }

        $ctxt->object->{_title} = $value if $property->name() eq 'title';
        $ctxt->object->{_date} = $value if $property->name() eq 'date';
    }

    return 1;
}

=head2 event_remove_author_mapping()

=cut

sub event_remove_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $property = $self->param('property');
    my $property_id = $self->param('property_id');
    my $role = $self->param('role');
    if ( not ($property and $property_id and defined $role) ) {
        return 0;
    }

    # look up mapping
    my $propmapclass = "XIMS::RefLib" . ucfirst($property) . "Map";
    my $propid = $property . "_id";
    my $propmapobject = $propmapclass->new( reference_id => $ctxt->object->reference->id(), $propid => $property_id, role => $role );
    if ( not( $propmapobject ) ) {
        $self->sendError( $ctxt, __"No mapping found which could be deleted." );
        return 0;
    }

    # special case for property "author", we will not delete the mapping if
    # it is the last one.
    if ( $property eq 'author' and $role == 0 ) {
        my $propmethod = "vl".$property."s";
        if ( scalar $ctxt->object->$propmethod() == 1 ) {
            $self->sendError( $ctxt, __"Will not delete last associated author." );
            return 0;
        }
    }

    # delete mapping and redirect to event edit
    if ( $propmapobject->delete() ) {
        if ( $role == 0 and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, __"Mapping could not be deleted." );
    }

    return 0;
}

=head2 event_remove_serial_mapping()

=cut

sub event_remove_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $serial_id = $self->param('serial_id');

    if ( not defined $serial_id ) {
        $self->sendError( $ctxt, __"Wrong Parameters." );
        return 0;
    }

    # look up mapping
    my $serial = XIMS::RefLibSerial->new( id => $serial_id );
    if ( not defined $serial ) {
        $self->sendError( $ctxt, __"Serial not found." );
        return 0;
    }

    if ( $serial->id() eq $ctxt->object->reference->serial_id() ) {
        # delete mapping and redirect to event edit
        my $reference = $ctxt->object->reference;
        $reference->serial_id( undef );
        if ( $reference->update() ) {
            $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
            return 1;
        }
        else {
            $self->sendError( $ctxt, __"Mapping could not be deleted." );
        }
    }
    else {
        $self->sendError( $ctxt, __"Given Serial does not match currently assigned serial." );
    }

    return 0;
}

=head2 event_create_author_mapping()

=cut

sub event_create_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->param('vleditor', undef);
    $self->create_author_mapping( $ctxt );
    #warn "\n\nObject ID : ".$ctxt->object->id();
    #warn "\n\nRedPath : ".$self->redirect_uri( $ctxt, $ctxt->object->id() );
    $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}

=head2 event_create_editor_mapping()

=cut

sub event_create_editor_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->param('vlauthor', undef);
    $self->create_author_mapping( $ctxt );
    $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}

=head2 event_create_serial_mapping()

=cut

sub event_create_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->create_serial_mapping( $ctxt );
    $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}

=head2 event_reposition_author()

=cut

sub event_reposition_author {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my %param;
    $param{old_position} = $self->param('old_position');
    $param{new_position} = $self->param('new_position');
    $param{author_id} = $self->param('author_id');
    $param{role} = $self->param('role');

    if ( scalar grep { !/^\d+$/ } values %param ) {
        $self->sendError( $ctxt, __"Invalid parameters." );
        return 0;
    }

    if ( $ctxt->object->reposition_author( %param ) ) {
        if ( $param{role} == 0 and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, __"Could not reposition author." );
        return 0;
    }
}

=head2 event_change_reference_type()

=cut

sub event_change_reference_type {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $reference_type_id = $self->param('reference_type_id');
    if ( not defined $reference_type_id ) {
        return $self->sendError( $ctxt, __"Need a new reference type id." );
    }

    my $reference_type = XIMS::RefLibReferenceType->new( id => $reference_type_id );
    if ( defined $reference_type ) {
        my $reference = $ctxt->object->reference();
        $reference->reference_type_id( $reference_type_id );
        if ( $reference->update() ) {
            $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) . "?edit=1" );
            return 1;
        }
        else {
            return $self->sendError( $ctxt, __"Reference Type could not be updated." );
        }
    }
    else {
        return $self->sendError( $ctxt, __"Could not resolve reference type." );
    }
}

=head2 event_publish_prompt()

=cut

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

=head2 event_publish()

=cut

sub event_publish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->publish_gopublic( @_ );
}

=head2 event_unpublish()

=cut

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->unpublish_gopublic( @_ );
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

