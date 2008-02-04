
=head1 NAME

XIMS::CGI::VLibraryItem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibraryItem;

use strict;
use base qw( XIMS::CGI );
use XIMS::VLibrary;
use XIMS::VLibAuthor;
use XIMS::VLibAuthorMap;
use XIMS::VLibKeyword;
use XIMS::VLibKeywordMap;
use XIMS::VLibSubject;
use XIMS::VLibSubjectMap;
use XIMS::VLibPublication;
use XIMS::VLibPublicationMap;
use XIMS::VLibMeta;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    XIMS::CGI::registerEvents(
        $self,
        qw(
          create
          edit
          store
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          remove_mapping
          create_mapping
          )
    );
}

sub event_init {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator('XIMS::SAX::Generator::VLibraryItem');
    $self->SUPER::event_init($ctxt);
}

sub event_create {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator('XIMS::SAX::Generator::VLibraryItem');

    my $vlibrary =
      XIMS::VLibrary->new( document_id => $ctxt->object->parent_id() );
    $ctxt->object->vlkeywords( $vlibrary->vlkeywords() );
    $ctxt->object->vlsubjects( $vlibrary->vlsubjects() );
    $ctxt->object->vlauthors( $vlibrary->vlauthors() );

    $self->SUPER::event_create($ctxt);
}

sub event_edit {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );
    $ctxt->properties->content->escapebody(1);
    my $vlibrary =
      XIMS::VLibrary->new( document_id => $ctxt->object->parent_id() );

    $ctxt->object->vlkeywords( $vlibrary->vlkeywords() );
    $ctxt->object->vlsubjects( $vlibrary->vlsubjects() );
    $ctxt->object->vlauthors( $vlibrary->vlauthors() );

    $self->expand_attributes($ctxt);

    return $self->SUPER::event_edit($ctxt);
}

sub event_remove_mapping {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    my $property    = $self->param('property');
    my $property_id = $self->param('property_id');
    if ( not( $property and $property_id ) ) {
        return 0;
    }

    # look up mapping
    my $propmapclass  = "XIMS::VLib" . ucfirst($property) . "Map";
    my $propid        = $property . "_id";
    my $propmapobject = $propmapclass->new(
        document_id => $ctxt->object->document_id(),
        $propid     => $property_id
    );
    if ( not($propmapobject) ) {
        $self->sendError( $ctxt, "No mapping found which could be deleted." );
        return 0;
    }

    # special case for property "subject", we will not delete the mapping if
    # it is the last one.
    if ( $property eq 'subject' ) {
        my $propmethod = "vl" . $property . "s";
        if ( scalar $ctxt->object->$propmethod() == 1 ) {
            $self->sendError( $ctxt,
                "Will not delete last associated subject." );
            return 0;
        }
    }

    # delete mapping and redirect to event edit
    if ( $propmapobject->delete() ) {
        $self->redirect(
            $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, "Mapping could not be deleted." );
    }

    return 0;
}

sub event_create_mapping {
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    XIMS::Debug( 5, "called" );

    my $vlsubject = $self->param('vlsubject');
    my $vlkeyword = $self->param('vlkeyword');
    my $vlauthor  = $self->param('vlauthor');

    if ( $vlsubject or $vlkeyword or $vlauthor ) {
        $self->_create_mapping_from_id( $ctxt->object(), 'Subject',
            $vlsubject )
          if $vlsubject;
        $self->_create_mapping_from_id( $ctxt->object(), 'Keyword',
            $vlkeyword )
          if $vlkeyword;
        $self->_create_mapping_from_id( $ctxt->object(), 'Author', $vlauthor )
          if $vlauthor;
        if ( index( ref($object), 'URLLink' ) > -1 ) {

            # jokar: If the object is an URLLink the edit parameter has
            # to be preceeded with a semikolon Because the parameter
            # string is not empty
            $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() )
                  . ";edit=1" );
        }
        else {

            # jokar: else a questionmark is needed
            $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() )
                  . "?edit=1" );
        }

        #$ctxt->properties->application->style( "edit" );
        return 1;
    }

    return 0;
}

sub _isvaliddate {
    XIMS::Debug( 5, "called" );
    my $self  = shift;
    my $input = shift;
    if ( $input =~
        m!^(\d\d\d\d)[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$! )
    {

        # At this point, $1 holds the year, $2 the month and $3 the day
        # of the date entered
        if ( $3 == 31 and ( $2 == 4 or $2 == 6 or $2 == 9 or $2 == 11 ) ) {
            return 0;    # 31st of a month with 30 days
        }
        elsif ( $3 >= 30 and $2 == 2 ) {
            return 0;    # February 30th or 31st
        }
        elsif (
                ( $2 == 2 )
            and ( $3 == 29 )
            and not(( ( $1 % 4 ) == 0 )
                and ( ( ( $1 % 100 ) != 0 ) or ( ( $1 % 400 ) == 0 ) ) )
          )
        {
            return 0;    # February 29th outside a leap year
        }
        else {
            return 1;    # Valid date
        }
    }
    else {
        return 0;        # Not a date
    }
}

sub _create_mapping_from_name {
    XIMS::Debug( 5, "called" );
    my $self          = shift;
    my $object        = shift;
    my $propertyname  = shift;
    my $propertyvalue = shift;
    my $propobject;

    my @vlpropvalues = split( ";", XIMS::trim( XIMS::decode($propertyvalue) ) );
    foreach my $value (@vlpropvalues) {
        my $parsed_name;
        my $propclass = "XIMS::VLib" . $propertyname;

        # XXX no code for publications?

        if ( $propertyname eq 'Subject' or $propertyname eq 'Keyword') {
            $propobject = $propclass->new(
                name        => $value,
                document_id => $object->parent_id()
            );
        }
        elsif ( $propertyname eq 'Author' ) {
            $parsed_name = XIMS::VLibAuthor::parse_namestring($value);
            $propobject =
              $propclass->new( %{$parsed_name},
                document_id => $object->parent_id() );
        }

        if ( not( defined $propobject and $propobject->id() ) ) {
            $propobject = $propclass->new();
            if ( $propertyname eq 'Author' ) {
                $propobject->lastname( $parsed_name->{lastname} );
                $propobject->firstname( $parsed_name->{firstname} )
                  if ( defined $parsed_name->{firstname}
                    and length $parsed_name->{firstname} );
                $propobject->middlename( $parsed_name->{middlename} )
                  if ( defined $parsed_name->{middlename}
                    and length $parsed_name->{middlename} );
                $propobject->suffix( $parsed_name->{suffix} )
                  if ( defined $parsed_name->{suffix}
                    and length $parsed_name->{suffix} );
                # refers to the *VLibrary*, thence parent_id()
                $propobject->document_id( $object->parent_id() );
            }
            else {
                $propobject->name($value);
                # refers to the *VLibrary*, thence parent_id()
                $propobject->document_id( $object->parent_id() );
            }
            
            if ( not $propobject->create() ) {
                XIMS::Debug( 3, "could not create $propclass $value" );
                next;
            }
        }
        my $propmapclass = $propclass . "Map";
        my $propid       = lc $propertyname . "_id";

        # refers to the *VLibraryItem*, thence document_id()
        my $propmapobject = $propmapclass->new(
            document_id => $object->document_id(),
            $propid     => $propobject->id()
        );
        if ( not( defined $propmapobject ) ) {
            $propmapobject = $propmapclass->new();
            $propmapobject->document_id( $object->document_id() );
            $propmapobject->$propid( $propobject->id() );
            if ( $propmapobject->create() ) {
                XIMS::Debug( 6, "created mapping for '$value'" );
            }
            else {
                XIMS::Debug( 2, "could not create mapping for '$value'" );
            }
        }
        else {
            XIMS::Debug( 4, "mapping for '$value' already exists" );
        }
    }
}

sub _create_mapping_from_id {
    XIMS::Debug( 5, "called" );
    my $self         = shift;
    my $object       = shift;
    my $propertyname = shift;
    my $value        = shift;
    my $propobject;
    my $propclass = "XIMS::VLib" . $propertyname;

    $propobject = $propclass->new(
        id          => $value,
        document_id => $object->parent_id()
    );

    if (
        not( defined $propobject
            and $propobject->id() )
      )
    {
        XIMS::Debug(
            3, "could not create $propclass
          $value"
        );
        return;
    }

    my $propmapclass = $propclass . "Map";
    my $propid       = lc $propertyname . "_id";

    # refers to the *VLibraryItem*, thence document_id()
    my $propmapobject = $propmapclass->new(
        document_id => $object->document_id(),
        $propid     => $propobject->id()
    );
    if ( not( defined $propmapobject ) ) {
        $propmapobject = $propmapclass->new();
        $propmapobject->document_id( $object->document_id() );
        $propmapobject->$propid( $propobject->id() );
        if ( $propmapobject->create() ) {
            XIMS::Debug( 6, "created mapping for '$value'" );
        }
        else {
            XIMS::Debug( 2, "could not create mapping for '$value'" );
        }
    }
    else {
        XIMS::Debug( 4, "mapping for '$value' already exists" );
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2007 The XIMS Project.

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
