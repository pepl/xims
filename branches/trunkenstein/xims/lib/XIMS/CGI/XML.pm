
=head1 NAME

XIMS::CGI::XML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::XML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::XML;

use common::sense;
use parent qw( XIMS::CGI );
use Text::Iconv;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );


=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
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
          test_wellformedness
          pub_preview
          simpleformedit
          unescapebody
          )
        );
}

# #############################################################################
# RUNTIME EVENTS

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->SUPER::event_default( $ctxt );
    $ctxt->properties->content->escapebody( 1 );
    return 0;
}

=head2 event_unescapebody()

=cut

sub event_unescapebody {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->SUPER::event_default( $ctxt );
    $ctxt->properties->content->escapebody( 0 );
    return 0;
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );
	# $ctxt->properties->application->style( "create" );

    # look for inherited CSS assignments
    if ( not defined $ctxt->object->css_id() ) {
        my $css = $ctxt->object->css;
        $ctxt->object->css_id( $css->id ) if defined $css;
    }

    $self->resolve_content( $ctxt, [ qw( CSS_ID ) ] );

    return 0;
}


=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # expand the attributes to XML-nodes
    $self->expand_attributes( $ctxt );

    $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );
    # $ctxt->properties->application->style( "edit" );

    # resolve document_ids to location_path after attributes have been expanded
    $self->resolve_content( $ctxt, [ qw( STYLE_ID CSS_ID SCHEMA_ID ) ] );
    #$self->resolve_content( $ctxt, [ qw( CSS_ID ) ] );

    return 0;
}



=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    my $sfe  = $self->param( 'sfe' );
    if ( defined $sfe ) {
        XIMS::Debug( 6, "sfe: $sfe" );
        if ( $sfe eq 'true' ) {
            $object->attribute( sfe => '1' );
        }
        elsif ( $sfe eq 'false' ) {
            $object->attribute( sfe => '0' );
        }
    }

    my $body;
    my $fh = $self->upload( 'file' );

    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    else {
        $body = $self->param( 'body' );
    }
    if ( defined $body and length $body ) {
        # we have to update the encoding attribute in the xml-decl to match
        # the encoding, the body will be saved in the db. that can't be done
        # parsing the body, doing a setEncoding() followed by a toString()
        # because we have to deal with the case that the body itself gets
        # send by the browser encoded in UTF-8 but still has different
        # encoding attributes from the user's document.
        #
        $body = update_decl_encoding( $body );

        my $object = $ctxt->object();
        if ( $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "body is not well-formed" );
            $self->sendError( $ctxt, __"Document body is not well-formed XML." );
            return 0;
        }
    }

    return $self->SUPER::event_store( $ctxt );
}


=head2 update_decl_encoding()

=cut

sub update_decl_encoding {
    XIMS::Debug( 5, "called" );
    my $body = shift;

    my ( $encoding ) = ( $body =~ /^<\?xml[^>]+encoding="([^"]*)"/ );
    if ( $encoding ) {
        my $newencoding = ( 'UTF-8' );
        XIMS::Debug( 6, "switching encoding attribute from '$encoding' to 'UTF-8'");
        $body =~ s/^(<\?xml[^>]+)encoding="[^"]*"/$1encoding="UTF-8"/;
    }

    return $body;
}

=head2 event_simpleformedit()

=cut

sub event_simpleformedit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # expand the attributes to XML-nodes
    $self->expand_attributes( $ctxt );

    # resolve document_ids to location_path after attributes have been expanded,
    $self->resolve_content( $ctxt, [ qw( STYLE_ID CSS_ID SCHEMA_ID ) ] );

    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $ctxt->properties->application->style( "simpleformedit" );
    $ctxt->properties->content->escapebody( 0 ); # do not escape the body

    my $schema = $ctxt->object->schema( explicit => 1 );
    my $schemaroot;
    if ( not defined $schema ) {
        XIMS::Debug( 3, "A schema is needed for simple form editing" );
        $self->sendError( $ctxt, __"A schema is needed for simple form editing" );
        return 0;
    }
    elsif ( defined $schema and not $schema->published() ) {
        XIMS::Debug( 3, "The schema needs to be published." );
        $self->sendError( $ctxt, __"The schema needs to be published. Please publish it." );
        return 0;
    }

    # Parse and test the assigned schema
    my $parser = XML::LibXML->new();
    my $sdoc;
    eval {
        $sdoc = $parser->parse_string( $schema->body() );
    };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not parse: $@" );
        $self->sendError( $ctxt, __"Could not parse schema." );
        return 0;
    }
    $sdoc->setEncoding( 'UTF-8' );

    $schemaroot = $sdoc->documentElement();
    $schemaroot->setNamespace('http://relaxng.org/ns/structure/1.0','r',0);
    $schemaroot->setNamespace('http://xims.info/ns/xmlsimpleformedit','s',0);

    # Test the schema structure
    my %validation_checks = (
        'count(r:start/r:element/r:oneOrMore/r:element)' => '1',
        'count(r:start/r:element/r:oneOrMore/r:element/r:element/r:element)' => '0',
        'r:start/r:element/r:oneOrMore/r:element/r:attribute/@name' => 'id',
        'count(r:start/r:element/*)' => '1',
        'name(r:start/r:element/*)' => 'oneOrMore',
                            );
    while ( my ($xpath, $result) = each %validation_checks ) {
        if ( $schemaroot->findvalue($xpath) ne $result ) {
            XIMS::Debug( 3, "The schema does not meet the simpleformedit validation checks." );
            $self->sendError( $ctxt, __"The schema does not meet the simpleformedit validation checks. Please update the schema as described in the documentation." );
            return 0;
        }
    }

    # Parse the body
    my $doc;
    eval {
        $doc = $parser->parse_string( $ctxt->object->body() );
    };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not parse: $@" );
        $self->sendError( $ctxt, __"Could not parse body." );
        return 0;
    }
    $doc->setEncoding( 'UTF-8' );
    my $root = $doc->documentElement();

    #
    # TODO: Check if object's body is valid according to the schema here
    #

    # Check which kind of action should happen
    my $elementid = $self->param( 'eid' );
    my $action = $self->param( 'seid' );
    if ( $action ) {
        my $rootelementname = $schemaroot->findvalue("r:start/r:element/\@name");
        my $elementname = $schemaroot->findvalue("r:start/r:element/r:oneOrMore/r:element/\@name");

        my $eid;
        my $oldelement;

        # Check if we are updating or deleting an existing entry
        if ( defined $elementid ) {
            $eid = $elementid;
            $oldelement = $root->findnodes('//'.$elementname.'[@id=\''.$elementid."']")->[0];
            if ( not defined $oldelement or not $oldelement->isa('XML::LibXML::Element') ) {
                XIMS::Debug( 2, "Could not find element to update" );
                $self->sendError( $ctxt, __"Could not find element to update." );
                return 0;
            }
        }
        else {
            $eid = $root->findvalue("count(//$elementname)")+1 || 1;
        }

        if ( $action eq 'delete' ) {
            $root->removeChild( $oldelement );
            $self->_updateIDs( $root, $elementname );
        }
        elsif ( $action eq 'moveup' ) {
            my $parent = $oldelement->parentNode();
            my $previous = $oldelement->previousSibling();
            return 0 unless defined $previous;
            $oldelement->unbindNode();
            $parent->insertBefore( $oldelement, $previous );
            $self->_updateIDs( $root, $elementname );
        }
        elsif ( $action eq 'movedown' ) {
            my $parent = $oldelement->parentNode();
            my $next = $oldelement->nextSibling();
            return 0 unless defined $next;
            $oldelement->unbindNode();
            $parent->insertAfter( $oldelement, $next );
            $self->_updateIDs( $root, $elementname );
        }
        else {
            my $entryelement = XML::LibXML::Element->new( $elementname );
            $entryelement->setAttribute( 'id', $eid );
            my $last_modified_attr = $schemaroot->findvalue("r:start/r:element/r:oneOrMore/r:element/s:last_modified_attr");
            if ( $last_modified_attr eq '1' ) {
                $entryelement->setAttribute( 'last_modified', $ctxt->object->data_provider->db_now() );
            }
            foreach my $element ( $schemaroot->findnodes("r:start/r:element/r:oneOrMore/r:element/r:element/\@name") ) {
                my $value = XIMS::clean( $self->param( "sfe_" . $element->value ) );
                $entryelement->appendTextChild( $element->value, $value );
            }
            if ( defined $elementid ) {
                $root->replaceChild( $entryelement, $oldelement );
            }
            else {
                $root->insertBefore( $entryelement, $root->firstChild );
            }
        }

        # After having done the work, prepare a message and/or redirect
        if ( $ctxt->object->body( $root->toString() ) and $ctxt->object->update( User => $ctxt->session->user ) ) {
            my $message;
            if ( $action eq 'delete' ) {
                $self->redirect( $self->redirect_uri( $ctxt ) . '?simpleformedit=1;message=Entry%20deleted' );
                return 1;
            }
            elsif ( $action =~ /^move/ ) {
                $self->redirect( $self->redirect_uri( $ctxt ) . '?simpleformedit=1;message=Entry%20moved.' );
                return 1;
            }
            elsif ( $elementid ) {
                $message = __"Changes saved";
            }
            else {
                $message = __"Entry created";
            }
            $ctxt->session->message( $message );
            XIMS::Debug( 4, "Body updated" );
        }
        else {
            XIMS::Debug( 2, "Could not update body" );
            $self->sendError( $ctxt, __"Could not update body." );
            return 0;
        }
    }
    else {
        # We do not want to see the default "Obtained Lock..." message here, so set it to the empty string
        $ctxt->session->message( '' );
    }

    return 0;
}

=head2 private functions/methods

=over

=item _updateIDs()

=cut

sub _updateIDs {
    my $self = shift;
    my $root = shift;
    my $elementname = shift;

    # First element in the Document gets the highest ID
    my $maxid = $root->findvalue("count(//$elementname)");
    foreach my $e ( $root->findnodes("//$elementname") ) {
        $e->setAttribute( 'id', $maxid-- );
    }
}

1;

__END__

=back

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

