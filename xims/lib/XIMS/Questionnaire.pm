
=head1 NAME

XIMS::Questionnaire -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Questionnaire;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Questionnaire;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::TAN_List;
use XIMS::QuestionnaireResult;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our $AUTOLOAD;



=head2    XIMS::Questionnaire->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $questionnaire: XIMS:: instance

=head3 Description

Constructor

=cut


sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'Questionnaire' )->id() unless defined $args{data_format_id};
    }

    my $q = $class->SUPER::new( %args );
    $q->{Parser} = XML::LibXML->new() if defined $q;
    return $q;
}



=head2    my $body = $object->body();
    my $boolean = $object->body( $body [, %args] );

=head3 Parameter

    $body                  (optional) :  Body string to save

=head3 Returns

    $body    : Body string from object
    $boolean : True or False for storing back body to object

=head3 Description

Overrides XIMS::Object::body().

=cut

sub body {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $body = shift;

    return $self->SUPER::body() unless $body;

    $self->SUPER::body( $body );
    $self->{_reparseQ} = 1;

    return 1;
}



=head2    my $q_dom = $questionnaire->questionnaire_dom();

=head3 Parameter

    none

=head3 Returns

    $q_dom   : XML::LibXML instance of Questionnaire (stored in body)

=head3 Description

Returns the XML::LibXML instance of the Questionnaire (stored in body). Helper
method to avoid redundant parsing of body.

=cut

sub questionnaire_dom {
    XIMS::Debug( 5, "called");
    my $self = shift;

    if ( defined $self->{_qdom} and (not exists $self->{_reparseQ} or $self->{_reparseQ} == 0) ) {
        return $self->{_qdom};
    }
    else {
        my $q_dom;
        eval { $q_dom = $self->_parser->parse_string( $self->body() ); };
        if ( $@ ) {
            XIMS::Debug( 2, "Could not parse body" );
            return;
        }
        else {
            $self->{_qdom} = $q_dom->documentElement();
            $self->{_reparseQ} = 0;
            return $self->{_qdom};
        }
    }
}




=head2    XIMS::Questionnaire->move_up( id, questionnaire )

=head3 Parameter

    node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

moves up a question or answer in the vertical hierarchy,
e.g. 1.2 -> 1.1 or 2->1, by changing the node with its
previous sibling on the same level.

=cut

sub move_up {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;

    my $node = $self->_qnode( $node_id, $questionnaire);
    my $parent_node = $node->parentNode();
    my $previous_node = $node->previousSibling();
    $node->unbindNode();
    $parent_node->insertBefore( $node, $previous_node );
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->move_down( node_id, questionnaire )

=head3 Parameter

    node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

moves down a question or answer in the vertical hierarchy,
e.g. 1.1 -> 1.2 or 1->2, by changing the node with its
next sibling on the same level.

=cut

sub move_down {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;

    my $node = $self->_qnode( $node_id, $questionnaire);
    my $parent_node = $node->parentNode();
    my $next_node = $node->nextSibling();
    $node->unbindNode();
    $parent_node->insertAfter( $node, $next_node );
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->add_question( node_id, questionnaire )

=head3 Parameter

    node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Adds an empty question to the end of the current branch

=cut

sub add_question {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;
    my $new_id;
    my $new_node;

    my $node = $self->_qnode( $node_id, $questionnaire);

    XIMS::Debug ( 6, "Node is a ".$node );
    #new node-id is the actual node-id, a dot and the number of the
    #children of the actual node incremented by one.
    #If the node is a top level question, then there is no dot
    $new_id = $node->find( 'count(*[@id])' )->value();
    $new_id++;
    $new_id = $node_id.".".$new_id if ( $node_id );
    XIMS::Debug ( 6, "New id: $new_id" );
    $new_node = XML::LibXML::Element->new( "question" );
    $new_node->setAttribute( "id", $new_id );
    $new_node->setAttribute( "edit", "1");
    $new_node->setAttribute( "alignment", "top");
    $new_node->setAttribute( "type", "none" );
    $new_node->appendTextChild( "title" , "");
    $new_node->appendTextChild( "comment" );
    $node->appendChild( $new_node );
    XIMS::Debug ( 6, "Added Question: $new_id" );
    $questionnaire = _set_top_question_edit ($questionnaire, $new_id);
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->edit_question( $node_id, $questionnaire )

=head3 Parameter

    $node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Sets the edit attribute of the question to "1" to make the
question editable

=cut

sub edit_question{
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;
    my $node;

    my $nodes = $questionnaire->find( "//question[\@id='".$node_id."']"  );
    XIMS::Debug ( 6, "Found ".$nodes->size()." Nodes" );
    if ( defined( $nodes ) && ( $nodes->size() == 1 ) ) {
        $node = $nodes->get_node( 1 );
    }
    else {
        XIMS::Debug ( 5, "Could not find node with id ".$node_id );
        return 0;
    }

    $node->setAttribute( "edit", "1" );
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}




=head2    XIMS::Questionnaire->delete_node( $node_id, $questionnaire )

=head3 Parameter

    $node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Deletes the question or answer with the node_id

=cut

sub delete_node {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;

    my $node = $self->_qnode( $node_id, $questionnaire);
    if ( $node != $questionnaire ) {
        $node = $node->parentNode->removeChild( $node );
    }
    $questionnaire = _set_top_question_edit ($questionnaire, $node_id);
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->copy_question( node_id, questionnaire )

=head3 Parameter

    node_id: id of node to copy in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Adds an empty question to the end of the current branch

=cut

sub copy_question {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;
    my $new_id;
    my $new_node;

    my $node = $self->_qnode( $node_id, $questionnaire);

    #new node-id is the actual node-id, a dot and the number of the
    #children of the actual node incremented by one.
    #If the node is a top level question, then there is no dot
    $new_id = $node->find( 'count(*[@id])' )->value();
    $new_id++;
    $new_id = $node_id.".".$new_id if ( $node_id );
    $new_node = $node->cloneNode( 1 );
    $node->addSibling( $new_node );
    $questionnaire = _set_top_question_edit ($questionnaire, $new_id);
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->add_answer( node_id, questionnaire )

=head3 Parameter

    node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Adds an empty answer to the end of the current branch

=cut

sub add_answer {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;
    my $new_id;
    my $new_node;

    my $node = $self->_qnode( $node_id, $questionnaire);

    #new node id is the actal node id, a dot and the number of the
    #children of the actual node incremented by one.
    #If the node is a top level question, then there is no dot
    $new_id = $node->find( 'count(*[@id])' )->value();
    $new_id++;
    $new_id = $node_id.".".$new_id if ( $node_id );
    $new_node = XML::LibXML::Element->new( "answer" );
    $new_node->setAttribute( "id", $new_id );
    $new_node->setAttribute( "alignment", "vertical");
    $new_node->setAttribute( "type", "radio" );
    $new_node->appendTextChild( "title" , "");
    $new_node->appendTextChild( "comment" );
    $node->appendChild( $new_node );
    $questionnaire = _set_top_question_edit ($questionnaire, $new_id);
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->delete_answer( $node_id, $questionnaire )

=head3 Parameter

    $node_id: id of node in the xsl:number multiple format
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Deletes the answer with the node_id

=cut

sub delete_answer {
    XIMS::Debug ( 5, "called" );
    my ($self, $node_id, $questionnaire) = @_;

    my $node = $self->_qnode( $node_id, $questionnaire);

    $node = $node->parentNode->removeChild( $node );
    $questionnaire = _set_top_question_edit ($questionnaire, $node_id);
    my $xml_string = $questionnaire->toString();
    #  $xml_string =~ s/^<body>(.*|\n*)<\/body>/\1/i;
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->get_value( XPath )

=head3 Parameter

    $XPath: XPath to the node we wish the value of

=head3 Returns

    Text value of the first node found

=head3 Description

only XPath expressions that return a node-list
should be used, because of get_node(). Will be
changed, so that any XPath returns the value of
of the found node.
At this time only used to get the title and comment
of the questionnaire.

=cut

sub get_value {
    my $self = shift;
    my $XPath = shift;
    XIMS::Debug( 5, "Called" );
    my $questionnaire = $self->questionnaire_dom();
    # replace 'questionnaire' in XPath, because it is the actual node
    $XPath =~ s/questionnaire/\./;
    my $node = $questionnaire->find( $XPath )->get_node( 1 );
    if ( defined $node ) {
        return $node->textContent();
    }
    else {
        return;
    }
}



=head2    XIMS::Questionnaire->get_option( $optionname )

=head3 Parameter

    $optionname: Name of the option stored in /questionnaire/options

=head3 Returns

    1 if option is set, undef if not.

=head3 Description

Checks if a Questionnaire option is set

=cut

sub get_option {
    my $self = shift;
    my $optionname = shift;
    my $option = $self->get_value( "options/$optionname" );
    if ( defined $option and $option eq '1' ) {
        return 1;
    }
    else {
        return;
    }
}



=head2    XIMS::Questionnaire->get_full_question_title( $question_id )

=head3 Parameter

    $question_id: Id of the question the title should be returned

=head3 Returns

    Title of all the Questions in the Question id - hierarchy

=head3 Description

The titles of all question in the id-hierarchy are returned,
seperated by ":"

=cut

sub get_full_question_title {
    my $self = shift;
    my $question_id = shift;
    XIMS::Debug( 5, "Called" );
    my $full_question_title = "";
    my $full_id = "";
    my $question_title = "";
    foreach my $split_id ( split(/\./, $question_id ) ) {
        $full_id .= $split_id;
        $question_title = $self->get_question_title( $full_id );
        if ($question_title) {
            $full_question_title .= " - " if $full_question_title;
            $full_question_title .= $question_title;
            $full_id .= "." if $full_id;
        }
    }
    return $full_question_title;
}



=head2    XIMS::Questionnaire->get_full_question_titles( )

=head3 Parameter


=head3 Returns

    A hash with the question titles to all answers

=head3 Description



=cut

sub get_full_question_titles {
    my $self = shift;
    my $question_id = shift;
    XIMS::Debug( 5, "Called" );
    my $questionnaire = $self->questionnaire_dom();
    my $answer_nodes = $questionnaire->find( '//answer' );
    my $full_question_title = "";
    my $full_id = "";
    my $question_title = "";
    my %question_titles;
    foreach my $node ($answer_nodes->get_nodelist) {
        foreach my $split_id ( split(/\./, $node->getAttribute('id') ) ) {
            $full_id .= $split_id;
            $question_title = $questionnaire->findvalue( '//question[@id="' . $full_id . '"]/title' );
            if ($question_title) {
                $question_titles{$full_id} = $question_title unless length $full_question_title > 0;
                $full_question_title .= " - " if $full_question_title;
                $full_question_title .= $question_title;
                $full_id .= "." if $full_id;
            }
        }
        $question_titles{$full_id} = $full_question_title;
        $full_id = ""; $full_question_title = "";
    }
    return %question_titles;
}



=head2    XIMS::Questionnaire->get_answer_ids( [ $question_id ] )

=head3 Parameter


=head3 Returns

    Arrayref of answer ids

=head3 Description



=cut

sub get_answer_ids {
    XIMS::Debug( 5, "Called" );
    my $self = shift;
    my $question_id = shift;
    my @answer_ids;

    my $questionnaire = $self->questionnaire_dom();

    my $question_xpath = '//question';
    $question_xpath .= '[@id=' . $question_id . ']' if defined $question_id;
    foreach my $attrib ( $questionnaire->findnodes( $question_xpath . "//answer[contains(\@id,'.')]/\@id" ) ) {
        push( @answer_ids, $attrib->value() );
    }
    return \@answer_ids;
}



=head2    XIMS::Questionnaire->get_question_title( $question_id )

=head3 Parameter

    $question_id: Id of the question the title should be returned

=head3 Returns

    Title of the Question with the Question id

=head3 Description



=cut

sub get_question_title {
    my $self = shift;
    my $question_id = shift;
    XIMS::Debug( 5, "Called" );
    my $questionnaire = $self->questionnaire_dom();
    my $question_title = $questionnaire->findvalue( '//question[@id="' . $question_id. '"]/title' );
    return $question_title;
}



=head2    XIMS::Questionnaire->form_to_xml( %params )

=head3 Parameter

    %params: all parameters given to the script

=head3 Returns

    xml-document

=head3 Description

parses the html-form in %params to a
xml-questionnaire-document.

=cut

sub form_to_xml {
    XIMS::Debug ( 5, "called" );
    my ($self, %params ) = @_;

    my $questionnaire_document = XML::LibXML::Document->new();
    my $questionnaire = XML::LibXML::Element->new( "questionnaire" );
    $questionnaire->appendTextChild( "title", $params{'title'} ) if $params{'title'};
    $questionnaire->appendTextChild( "comment", $params{'questionnaire_comment'} ) if $params{'questionnaire_comment'};
    $questionnaire->appendTextChild( "intro", $params{'questionnaire_intro'} ) if $params{'questionnaire_intro'};
    $questionnaire->appendTextChild( "exit", $params{'questionnaire_exit'} ) if $params{'questionnaire_exit'};

    # Deal with options
    my $options = XML::LibXML::Element->new( "options" );
    my $kioskmode = $params{'questionnaire_opt_kioskmode'};
    if ( defined $kioskmode ) {
        XIMS::Debug( 6, "kioskmode: $kioskmode" );
        if ( $kioskmode eq 'true' ) {
            $kioskmode = 1;
        }
        elsif ( $kioskmode eq 'false' ) {
            $kioskmode = 0;
        }
    }
    $options->appendTextChild( "kioskmode", $kioskmode ) if $kioskmode;

    my $mandatoryanswers = $params{'questionnaire_opt_mandatoryanswers'};
    if ( defined $mandatoryanswers ) {
        XIMS::Debug( 6, "mandatoryanswers: $mandatoryanswers" );
        if ( $mandatoryanswers eq 'true' ) {
            $mandatoryanswers = 1;
        }
        elsif ( $mandatoryanswers eq 'false' ) {
            $mandatoryanswers = 0;
        }
    }
    $options->appendTextChild( "mandatoryanswers", $mandatoryanswers ) if $mandatoryanswers;

    $questionnaire->appendChild( $options );

    # recursively create childnodes
    $questionnaire = _create_tanlists( $questionnaire, %params );
    $questionnaire = _create_children( $questionnaire, %params );
    $questionnaire_document->setDocumentElement( $questionnaire );

    return $questionnaire_document->documentElement();
}



=head2    XIMS::Questionnaire->set_answer_data( %params )

=head3 Parameter

    %params: all parameters given to the script

=head3 Returns


=head3 Description

Adds the tan and current question information
to the questionnaire. If no tan is needed, the
session_id is taken as unique number

=cut

sub set_answer_data {
    XIMS::Debug( 5, "called");
    my ($self, %params) = @_;

    my $questionnaire = $self->questionnaire_dom();
    my $question_id = $params{'q'};
    my $tan = $params{'tan'};
    if ( $question_id ) {
        $question_id = XIMS::QuestionnaireResult->get_last_answer($self->document_id, $tan) + 1;
        XIMS::Debug(6, "question_id: $question_id") if defined $question_id;
        $questionnaire->appendTextChild( 'current_question', $question_id );
    }
    $questionnaire->appendTextChild( 'tan', $tan );
    $self->body( $questionnaire->toString() );

    return 1
}

=head2 set_answer_error()

=cut

sub set_answer_error {
    XIMS::Debug( 5, "called");
    my ($self, $error_message, $q) = @_;

    my $questionnaire = $self->questionnaire_dom();
    $questionnaire->appendTextChild( 'error_message', $error_message );
    $self->body( $questionnaire->toString() );

    return 1
}

# don't know why Joachim put prototypes on these four subs...
## no critic (ProhibitSubroutinePrototypes)

=head2 kioskmode()

=cut

sub kioskmode () {
    XIMS::Debug( 5, "called");
    my $self = shift;

    return $self->get_option( 'kioskmode' );
}

=head2 mandatoryanswers()

=cut

sub mandatoryanswers () {
    XIMS::Debug( 5, "called");
    my $self = shift;

    return $self->get_option( 'mandatoryanswers' );
}

=head2 tan_needed()

=cut

sub tan_needed () {
    XIMS::Debug( 5, "called");
    my $self = shift;

    my $result;
    my $questionnaire = $self->questionnaire_dom();
    my $nodes = $questionnaire->find( "/questionnaire/tanlist" );
    if ( defined( $nodes ) && ( $nodes->size() >= 1 ) ) {
      $result = 1;
    }
    else {
      $result = 0;
    }

    return $result;
}

=head2 tan_ok()

=cut

sub tan_ok() {
    XIMS::Debug( 5, "called" );
    my ( $self, $tan ) = @_;

    my $tan_ok        = 0;
    my $questionnaire = $self->questionnaire_dom();

    # get TAN-Lists from Questionnaire
    my @nodes = $questionnaire->findnodes("/questionnaire/tanlist");

    # look if TAN is in one of the TAN-Lists
    # for each TAN-List look if given TAN is in it
    my $TAN_List;
    my $a_single_tan;

    foreach my $tan_listnode (@nodes) {
        $TAN_List = XIMS::TAN_List->new(
            document_id    => $tan_listnode->getAttribute("id"),
            marked_deleted => 0
        );

        next unless defined $TAN_List;

        $a_single_tan = "," . $TAN_List->body() . ",";
        last if $tan_ok = ( $a_single_tan =~ /,$tan,/ );
    }

    # Return result
    return $tan_ok;
}

## use critic

=head2 store_result

=cut

sub store_result {
    XIMS::Debug( 5, "called" );
    my ($self, %params) = @_ ;
    my $docid = $params{'docid'};
    my $tan = $params{'tan'};
    my $question = $params{'q'} - 1;
    my @results;
    my $answered = 0;
    my $mandatoryanswers = $self->mandatoryanswers();
    # Check if question already has been answered
    # ToDo: Questionnaire-setting if answer update is allowed.
    my $rv = XIMS::QuestionnaireResult->getResult( $docid, $tan, $question);
    return 0 if ( defined $rv and $rv eq "ANSWERED" );

    # Walk through the answer_ids and check for answers
    my @answer_ids = @{$self->get_answer_ids( $question )};
    foreach my $answer_id ( @answer_ids ) {
        my $paramval = $params{'answer_' . $answer_id};
        next unless defined $paramval;
        foreach my $answer (split( /\0/, $paramval ) ) {
            if ( defined $mandatoryanswers and not defined $answer ) {
                return 0;
            }
            # since we dump the raw result data tab-separated, we do not
            # want to store tab characters here
            $answer =~ s/\t/    /g;
            my $result = XIMS::QuestionnaireResult->new() ;
            $result->document_id( $docid );
            $result->tan( $tan );
            $result->question_id( $answer_id );
            $result->answer( $answer );
            push( @results, $result );
            $answered++;
        }
    }
    if ( defined $mandatoryanswers and $answered != scalar @answer_ids ) {
        return 0;
    }

    # Store the answers
    for ( @results ) {
        $_->store();
    }
    # Set the whole question as answered
    my $result = XIMS::QuestionnaireResult->new() ;
    $result->document_id( $docid );
    $result->tan( $tan );
    $result->question_id( $question );
    $result->answer( 'ANSWERED' );
    $result->store();
    return 1;
}

sub _create_tanlists {
    XIMS::Debug( 5, "called" );
    my ( $node, %params ) = @_;

    foreach my $param ( keys( %params ) ) {
        if ( $param =~ /^tanlist/ ) {
            my ( $element, $tanlist_id ) = split( /_/, $param );
            my $new_node = XML::LibXML::Element->new( $element );
            $new_node->setAttribute( 'id', $tanlist_id );
            $new_node->appendText(  $params{$param} );
            $node->appendChild( $new_node );
        }
    }
    return $node;
}


sub _create_children {
    # create one node after the other, change this!
    my ( $node, %params ) = @_;

    XIMS::Debug( 6, "Creating children of ".$node->nodeName() );
    my $old_id = $node->getAttribute( 'id' );
    my $new_id = 1;
    my %new_element;
    my $element;
    my $id;
    my $child_or_attribute;
    my $all_fields = 0;
    my $helper_node;
    do {
        # loop until the element title is empty, after that all children are created
        # if an element title is empty processing stops.
        if (defined $old_id) {
          $new_element{'id'}=$old_id.".".$new_id;
        }
        else {
          $new_element{'id'}=$new_id;
        }
        foreach my $key ( keys( %params ) ) {
            ( $element, $id, $child_or_attribute ) = split ( /_/, $key );
            next if ( $element !~ /(question|answer)$/ );
            # In the HTML Form then middle part of the Elementname is the id
            # instead of a point between the numbers there is a x (JavaScript Compability)
            # This x is removed here.
            $id =~ s/x/\./g;
            if ( $id eq $new_element{'id'} ) {
                $new_element {'element'} = $element;
                $new_element {$child_or_attribute} = $params{$key};
                $all_fields++;
            #        last if ( $all_fields == 3 );
            }
            elsif ( $all_fields == 0) {
                $new_element{'title'} = undef;
                $new_element{'type'} = undef;
            }
        }
        if ( defined $new_element{'title'} or defined $new_element{'type'} and $new_element{'type'} eq 'Textarea' or defined $new_element{'type'} and $new_element{'type'} eq 'Text' ) {
            $helper_node = _make_element(
                                       $new_element{'element'},
                                       $new_element{'id'},
                                       $new_element{'comment'},
                                       $new_element{'alignment'},
                                       $new_element{'type'},
                                       $new_element{'title'} );
            #XIMS::Debug( 6, "Making $new_id. Sibling." );
            $helper_node = _create_children( $helper_node, %params );
            $node->appendChild( $helper_node );
        }
        $new_id++;
        $all_fields = 0;
    } while ( defined $new_element{'title'} or defined $new_element{'type'} and $new_element{'type'} eq 'Textarea' or defined $new_element{'type'} and $new_element{'type'} eq 'Text' );
    #  XIMS::Debug( 6, "Making a Party, no time for children." );

    return $node;
}

sub _make_element {
    my ( $element, $id, $comment, $alignment, $type, $titles ) = @_;

    XIMS::Debug( 6,
        "Making Element with values: $element, $id, $comment, $alignment, $type, $titles"
    );
    $element = XML::LibXML::Element->new($element);
    my @titles = split( /####/, $titles );

    foreach my $title (@titles) {
        $element->appendTextChild( "title", $title );
    }
    $element->appendTextChild( "comment", $comment );
    $element->setAttribute( "id",        $id );
    $element->setAttribute( "type",      $type );
    $element->setAttribute( "alignment", $alignment );

    return $element;
}

sub _set_top_question_edit {
    my ($questionnaire, $node_id) = @_;

    my @top_id = split(/\./,$node_id);
    my @top_node = $questionnaire->findnodes( "//question[\@id = \"${top_id[0]}\"]");
    $top_node[0]->setAttribute("edit","1") if $top_node[0];

    return $questionnaire;
}



=head2    XIMS::Questionnaire->add_tanlist( tanlist_path, questionnaire )

=head3 Parameter

    tanlist_path: location_path of the TAN_List to be added to the Questionnaire
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns

    Updated body of the Questionnaire on success
    Undef on failure

=head3 Description

Adds a TAN-List to the Questionnaire

=cut

sub add_tanlist {
    XIMS::Debug ( 5, "called" );
    my ($self, $tanlist_path, $questionnaire) = @_;
    #get TAN-List Object
    my $TAN_List = XIMS::TAN_List->new( path => $tanlist_path );
    if ( defined $TAN_List and $TAN_List->number() ) {
        XIMS::Debug( 4, "adding TAN-List: $TAN_List");
        my $new_node = XML::LibXML::Element->new( "tanlist" );
        $new_node->setAttribute( "id", $TAN_List->document_id() );
        # XXXX This looks like a (parens) bug!
        # $new_node->appendText(  $TAN_List->title() ) ." (".$TAN_List->number().")"  );
        $new_node->appendText(  $TAN_List->title() ." (".$TAN_List->number().")" );
        $questionnaire->appendChild( $new_node );
    }
    else {
        XIMS::Debug( 4, "Could not find TAN_List using path '$tanlist_path'" );
        return;
    }
    $self->body( $questionnaire->toString() );
}



=head2    XIMS::Questionnaire->remove_tanlist( tanlist_id, questionnaire )

=head3 Parameter

    tanlist_id: id of the TAN_List to be removed from the Questionnaire
    questionnaire: XML-Document representing the Questionnaire

=head3 Returns



=head3 Description

Removes a TAN-List from the Questionnaire

=cut

sub remove_tanlist {
    XIMS::Debug ( 5, "called" );
    my ($self, $tanlist_id, $questionnaire) = @_;

    my $node;
    #  XIMS::Debug ( 6, "Removing TAN-List with ID $tanlist_id" );
    my $nodes = $questionnaire->find( "/questionnaire/tanlist[\@id='".$tanlist_id."']"  );
    if ( defined( $nodes ) && ( $nodes->size() == 1 ) ) {
        $node = $nodes->get_node( 1 );
    }
    else {
        $node = $questionnaire;
    }

    $node = $node->parentNode->removeChild( $node );
    # XIMS::Debug ( 6, "Deleted TAN_List: $tanlist_id" );
    my $xml_string = $questionnaire->toString();
    $self->body( $xml_string );
}



=head2    XIMS::Questionnaire->set_statistics()

=head3 Parameter


=head3 Returns


=head3 Description

Gets the total number of answered questionnaires
and the number of valid answered questionnaires

=cut

sub set_statistics {
    XIMS::Debug( 5, "called");
    my ($self) = @_;
    my $questionnaire = $self->questionnaire_dom();
    # get statistic from database-table
    my $result_object = XIMS::QuestionnaireResult->new();
    my ($total, $valid, $invalid) = $result_object->get_result_count( $self->document_id(), _last_question($questionnaire) );
    # add statistics to xml-structure
    $questionnaire->setAttribute( 'total_answered', $total );
    $questionnaire->setAttribute( 'valid_answered', $valid );
    $self->body( $questionnaire->toString() );
    #  XIMS::Debug( 6, "### xml=".$self->body());

    return 1
}

sub _last_question {
    my $questionnaire = shift;
    my $result = $questionnaire->findvalue( 'count(question)' );
    return $result;
}



=head2    XIMS::Questionnaire->set_results()

=head3 Parameter


=head3 Returns


=head3 Description

Gets the answers to each question and inserts them
into the xml-structure

=cut

sub set_results {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my %args     = @_;
    my $answered = 1;
    $answered = 0
        if defined $args{full_text_answers} and $args{full_text_answers} == 1;

    my $questionnaire = $self->questionnaire_dom();
    my $result_object = XIMS::QuestionnaireResult->new();
    my $answer_nodes;
    my $title_nodes;
    $answer_nodes = $questionnaire->find('//answer');

    #step through each answer
    foreach my $answer_node ( $answer_nodes->get_nodelist() ) {

        # if answer type is "Checkbox", "Radio" or "Select" step through each
        # title and get the answer count
        my $title_nodes = $answer_node->find('title');
        my $question_id = $answer_node->findvalue('@id');
        my $answer_type = $answer_node->findvalue('@type');
        if ( !( $answer_type =~ /^Text/ ) ) {
            foreach my $title_node ( $title_nodes->get_nodelist() ) {
                my $answer = $title_node->textContent();
                my $answer_count
                    = $result_object->get_answer_count( $self->document_id(),
                    $question_id, $answer );
                $title_node->setAttribute( 'count', $answer_count );
            }
        }
        else {

            # if answer type is "Text" or "Textarea" get each answer from the
            # database

            # get all default answers and delete them from the body
            map { $answer_node->removeChild($_) }
                $title_nodes->get_nodelist();
            my $all_answers;
            if ($answered) {
                $all_answers
                    = $result_object->get_answers( $self->document_id(),
                    $answer_node->parentNode->findvalue('@id'), $answered );
            }
            else {
                $all_answers
                    = $result_object->get_answers( $self->document_id(),
                    $answer_node->findvalue('@id'), $answered );
            }
            foreach my $answer_text ( @{$all_answers} ) {
                my $new_title = XML::LibXML::Element->new("title");
                $new_title->setAttribute( "count", ${$answer_text}{'count'} );
                $new_title->appendText( ${$answer_text}{'answer'} );
                $answer_node->appendChild($new_title);
            }
        }
    }
    $self->body( $questionnaire->toString() );
    return 1;
}



=head2    XIMS::Questionnaire->has_answers()

=head3 Parameter


=head3 Returns

    number of answered questionnaires

=head3 Description



=cut

sub has_answers {
    XIMS::Debug( 5, "called");
    my ($self) = @_;

    my $questionnaire = $self->questionnaire_dom();
    # get statistic from database-table
    my $result_object = XIMS::QuestionnaireResult->new();
    my ($total, $valid, $invalid) = $result_object->get_result_count( $self->document_id(), _last_question($questionnaire) );
    return $total
}

sub _parser {
    my $self = shift;

    return $self->{Parser} if defined $self->{Parser};

    $self->{Parser} = XML::LibXML->new();
    return $self->{Parser};
}

sub _qnode {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $node_id = shift;
    my $questionnaire = shift;

    my $node;
    my $nodes = $questionnaire->find( "//question[\@id='".$node_id."'] | //answer[\@id='".$node_id."']"  );
    if ( defined( $nodes ) && ( $nodes->size() == 1 ) ) {
        $node = $nodes->get_node( 1 );
    }
    else {
        $node = $questionnaire;
    }
    return $node;
}

=head2 AUTOLOAD()

=cut

sub AUTOLOAD {
    my $self = shift;
    my (undef, $called_sub) = ($AUTOLOAD =~ /(.*)::(.*)/);
    XIMS::Debug (6, "Questionnaire-Method $called_sub not implemented!") unless $called_sub eq 'DESTROY';
    return 1;
}

=head2 private functions/methods

=over

=item _create_tanlists()

=item _create_childrin()

=item _make_element()

=item _set_top_question_edit()

=item _last_question()

=item _parser()

=item _qnode()

=back

=cut

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

