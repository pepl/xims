# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::QuestionnaireResult ;

use strict;
use XIMS::AbstractClass;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

sub resource_type {
    return 'QuestionnaireResult';
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;


sub store {
    XIMS::Debug ( 5, "called" );
    my $self = shift;

    $self->answer_timestamp( $self->data_provider->db_now() );
    $self->id();
    $self->answer( XIMS::decode( $self->answer() ) );
    my $id = $self->data_provider->createQuestionnaireResult( $self->data());
    $self->id( $id );

    return $id;
}

##
#
# SYNOPSIS
#    XIMS::QuestionnaireResult->get_result_count( $questionnaire_id, $last_question )
#
# PARAMETER
#    $questionnaire_id: Document-ID of the questionnaire
#    $last_question   : number of the last question that has
#                       to be answered (= total number of questions)
#
# RETURNS
#    $total_count: number of all answered questionnaires
#    $valid_count: number of valid answered questionnaires (all questions answered)
#    $total_count-$valid_count: number of invalid answered questionnaires
#
# DESCRIPTION
#
sub get_result_count {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $last_question = shift;
    my $sql = "SELECT count(*) AS c1 FROM (SELECT tan FROM ci_questionnaire_results WHERE document_id = ? GROUP BY tan ) sub1";
    my $total_count = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id ] );
    $sql = "SELECT count(*) AS c1 FROM (SELECT tan FROM ci_questionnaire_results WHERE document_id = ? AND question_id = ? GROUP BY tan) sub1";
    my $valid_count = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $last_question ] );

    return ($total_count, $valid_count, $total_count - $valid_count);
}

##
#
# SYNOPSIS
#    XIMS::QuestionnaireResult->get_answer_count( $questionnaire_id, $question_id, $answer )
#
# PARAMETER
#    $questionnaire_id: Document-ID of the questionnaire
#    $question_id     : ID of the question of which the number of answers should be returned
#    $answer          : text of the answer
#
# RETURNS
#    $answer_count: how many times was the specific answer given to the question
#
# DESCRIPTION
#
sub get_answer_count {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;
    my $answer = XIMS::decode(shift);
    
    my $sql = "SELECT count(*) AS answercount FROM ci_questionnaire_results WHERE document_id = ? AND question_id = ? AND answer= ? ";
    my $answer_count = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $question_id, $answer ] );

    return $answer_count;
}

##
#
# SYNOPSIS
#    XIMS::QuestionnaireResult->get_answers( $questionnaire_id, $question_id )
#
# PARAMETER
#    $questionnaire_id: Document-ID of the questionnaire
#    $question_id     : ID of the question of which the answers should be returned
#
#
# RETURNS
#    $answers: reference to an array with all answers to the question and how often each answer was given
#
# DESCRIPTION
#
sub get_answers {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;

    my $sql = "SELECT answer, count(answer) AS count FROM ci_questionnaire_results WHERE document_id = ? AND question_id = ? GROUP BY answer";
    my $answers = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $questionnaire_id, $question_id] );
    foreach my $answer_text ( @{$answers} ) {
        ${$answer_text}{'answer'} = XIMS::encode( ${$answer_text}{'answer'} );
    }

    return $answers;
}

##
#
# SYNOPSIS
#    XIMS::QuestionnaireResult->get_last_answer ( $questionnaire_id, $tan )
#
# PARAMETER
#    $questionnaire_id: Document-ID of the questionnaire
#    $tan             : TAN of questionnaire that should be checked
#
# RETURNS
#    $question_id: ID of the last answered question of the questionnaire
#
# DESCRIPTION
#    Before a question can be answered we check if the question has not been answered before
#    This function returns the ID of the last question the TAN has answered.
#    The answering of the questionnaire continues at the next question.
#    See XIMS::Questionnaire::set_answer_data()
#
sub get_last_answer {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $tan = shift;

    my $sql = "SELECT max(to_number(question_id,'999999')) AS lid FROM ci_questionnaire_results WHERE document_id = ? AND tan = ? AND answer = 'ANSWERED'";
    my $last_answered_question = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $tan ] );
    if ( !( $last_answered_question) ) {
        $last_answered_question = 0;
    }
    return $last_answered_question;
}

sub getResult {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my ($questionnaire_id, $tan, $question) = @_;
    my $sql = "SELECT answer FROM ci_questionnaire_results WHERE document_id = ? AND tan = ? AND question_id = ?";
    my $result = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $tan, $question] );
    return $result;
}

1;

