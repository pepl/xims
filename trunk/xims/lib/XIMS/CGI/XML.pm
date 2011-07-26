
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

use strict;
use base qw( XIMS::CGI );
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
          bxeconfig
          #simpleformedit
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

    # the request method 'PUT' is only used by BXE to save XML-code
    if ( $self->request_method() eq 'PUT' ) {
        XIMS::Debug( 5, "BXE is putting XML-data for saving." );
        if ( $self->save_PUT_data($ctxt) ) {
            print $self->header(-status => '204');
        }
        else {
            print $self->header();
        }
        $self->skipSerialization(1);
        return 0;
    }
    else {
        $self->SUPER::event_default( $ctxt );
        $ctxt->properties->content->escapebody( 1 );
    }
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

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
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
    #$self->expand_attributes( $ctxt );

	$ctxt->properties->content->escapebody( 1 );

	# event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';
	
	# check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );
	# $ctxt->properties->application->style( "edit" );

    #if ( XIMS::XMLEDITOR() eq 'bxe' ) {
    #   $self->param( -name=>"bxepresent", -value=>"1" );
    #}

    #if ( $self->param( "edit" ) eq "bxe" ) {
    #    $ctxt->properties->application->style( "edit_bxe" );
    #}
	
	# resolve document_ids to location_path after attributes have been expanded,
    # because bxeconfig_id is stored in the attributes
    #$self->resolve_content( $ctxt, [ qw( STYLE_ID CSS_ID SCHEMA_ID BXECONFIG_ID ) ] );
	$self->resolve_content( $ctxt, [ qw( CSS_ID ) ] );
    
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

    # BXE Config.xml template document_id is stored as an attribute
    my $bxeconfig = $self->param( 'bxeconfig' );
    if ( defined $bxeconfig and length $bxeconfig ) {
         XIMS::Debug( 6, "bxeconfig: $bxeconfig" );
        my $bxeconfigobj;
        if ( $bxeconfig =~ /^\d+$/
             and $bxeconfigobj = XIMS::Object->new( id => $bxeconfig )
             and ( $bxeconfigobj->object_type->name() eq 'XML' ) ) {
            $object->attribute( bxeconfig_id => $bxeconfigobj->id() );
        }
        elsif ( $bxeconfigobj = XIMS::Object->new( path => $bxeconfig )
                and ( $bxeconfigobj->object_type->name() eq 'XML' ) ) {
            $object->attribute( bxeconfig_id => $bxeconfigobj->id() );
        }
        else {
            XIMS::Debug( 3, "could not set attribute bxeconfig_id" );
        }
    }
    else {
        $object->attribute( bxeconfig_id => undef );
    }

    # The Node that is edited in BXE is stored as an attribute
    my $bxexpath = $self->param( 'bxexpath' );
    if ( defined $bxexpath and length $bxexpath ) {
        XIMS::Debug( 6, "bxexpath: $bxexpath" );
        $object->attribute( bxexpath => $bxexpath );
        }
    else {
        $object->attribute( bxexpath => undef );
    }

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

    my $body = $self->param( 'body' );

    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

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
            $self->sendError( $ctxt, __"Document body is not well-formed. Please consult the User's Reference for information on well-formed document bodies." );
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
        my $newencoding = ( XIMS::DBENCODING() || 'UTF-8' );
        XIMS::Debug( 6, "switching encoding attribute from '$encoding' to '$newencoding'");
        $body =~ s/^(<\?xml[^>]+)encoding="[^"]*"/$1encoding="$newencoding"/;
    }

    return $body;
}

=head2 save_PUT_data()

=cut

sub save_PUT_data {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # Read PUT-request
    my $content_length = $ctxt->apache->header_in('Content-length');
    my $content;
    $ctxt->apache->read($content, $content_length);

    if ( XIMS::DBENCODING() ) {
        $content = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($content);
    }

    # we have to update the encoding attribute in the xml-decl to match
    # the encoding, the body will be saved in the db. that can't be done
    # parsing the body, doing a setEncoding() followed by a toString()
    # because we have to deal with the case that the body itself gets
    # send by the browser encoded in UTF-8 but still has different
    # encoding attributes from the user's document.
    #
    $content = update_decl_encoding( $content );

    $ctxt->object->body( $content );

    # Store in database
    if ( $ctxt->object->update() ) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 event_bxeconfig()

creates the config file for BXE

=cut

sub event_bxeconfig {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # get body from config template
    my $config_template = XIMS::XML->new( id => $ctxt->object->attribute_by_key( 'bxeconfig_id' ));

    # replace placeholders
    my $config_body = $config_template->body();
    my $XML_File = "/goxims/content?id=".$ctxt->object->id().";plain=1";
    my $RNG_File = "/goxims/content?id=".$ctxt->object->schema_id().";plain=1";
    my $CSS_File = "/goxims/content?id=".$ctxt->object->css_id().";plain=1";
    my $Exit_dest = "/goxims/content?id=".$ctxt->object->id().";edit=1";
    $config_body =~ s/\{\$xmlfile\}/$XML_File/;
    $config_body =~ s/\{\$validationfile\}/$RNG_File/;
    $config_body =~ s/\{\$css\}/$CSS_File/;
    $config_body =~ s/\{\$exitdestination\}/$Exit_dest/;

    # return xml
    my $df = XIMS::DataFormat->new( id => $config_template->data_format_id() );
    my $mime_type = $df->mime_type;

    my $charset;
    if ( !($charset = XIMS::DBENCODING() )) { $charset = "UTF-8"; }
    print $self->header( -Content_type => $mime_type."; charset=".$charset );
    print $config_body;
    $self->skipSerialization(1);

    return 0;

}


# If a simple RelaxNG schema with a specific structure has been assigned to the XML object, event simpleformedit
# can be used to edit the text values of the XML files elements via HTML form input controls.
# Note that the XML Document must not have an XML-Declaration!
#<grammar ns="" xmlns="http://relaxng.org/ns/structure/1.0" xmlns:s="http://xims.info/ns/xmlsimpleformedit"
#  datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
#  <start>
#    <element name="events">
#      <oneOrMore>
#        <element name="event">
#            <s:last_modified_attr>1</s:last_modified_attr>
#            <attribute name="id"/>
#            <optional>
#                <attribute name="last_modified"/>
#            </optional>
#            <element name="date">
#                <s:description show="1">Date</s:description>
#                <s:datatype>datetime</s:datatype>
#                <text/>
#            </element>
#            <element name="location">
#                <s:description>Location</s:description>
#                <text/>
#            </element>
#            <element name="description">
#                <s:description show="1">Description</s:description>
#                <text/>
#            </element>
#            <element name="public">
#              <s:description>The event is public?</s:description>
#              <s:datatype>boolean</s:datatype>
#              <text/>
#            </element>
#            <element name="type">
#              <s:description>Type of event</s:description>
#              <s:datatype>stringoptions</s:datatype>
#              <s:select>
#                  <s:option>seminar</s:option>
#                  <s:option>talk</s:option>
#              </s:select>
#              <text/>
#            </element>
#        </element>
#      </oneOrMore>
#    </element>
#  </start>
#</grammar>

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
    $sdoc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );

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
    $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
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
                my $value = XIMS::clean( XIMS::decode( $self->param( "sfe_" . $element->value ) ) );
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
                $self->redirect( $self->redirect_path( $ctxt ) . '?simpleformedit=1;message=Entry%20deleted' );
                return 1;
            }
            elsif ( $action =~ /^move/ ) {
                $self->redirect( $self->redirect_path( $ctxt ) . '?simpleformedit=1;message=Entry%20moved.' );
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

=item _set_wysiwyg_editor()

=cut

sub _set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor = $self->cookie($cookiename);
	# OVERRIDE for TESTING
	# $editor = 'codemirror';
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        # $editor = undef;
		$editor = 'codemirror';
    }
    elsif ($editor eq 'wepro') { 
        # we just dumped eWebEditPro, now change the remaining cookies
        # $editor = 'tinymce';
    	$editor = 'codemirror';
	}
	elsif ($editor eq 'tinymce') {
		# apply codemirror for syntax highlighting
		$editor = 'codemirror';
	}
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        # $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
		$editor = 'codemirror';
		if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
             # $editor = 'tinymce';
			 $editor = 'codemirror';
        }
        my $cookie = $self->cookie( -name    => $cookiename,
                                    -value   => $editor,
                                    -expires => "+2160h"); # 90 days
        $ctxt->properties->application->cookie( $cookie );
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
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

