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

use Text::Iconv;

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
    my $self = shift;

    $self->answer_timestamp( $self->data_provider->db_now() );
    $self->id();
    $self->answer( _decode( $self->answer() ) );
    my $id = $self->data_provider->createQuestionnaireResult( $self->data());
    $self->id( $id );

    return $id;
}

# if called in a list context it returns:
#    count of all answered questionnaires
#    count of valid answered questionnaires
#    count of invalid answered questionnaires
sub get_result_count {
    my $self = shift;
    my $questionnaire_id = shift;
    my $last_question = shift; # number of the last question that has to be answered (= total number of questions)

    my $sql = "SELECT count(*) AS c1 FROM (SELECT tan FROM ci_questionnaire_results WHERE document_id = $questionnaire_id GROUP BY tan ) sub1";
    my $total_count = $self->data_provider->driver->dbh->fetch_one_value( sql => $sql );
    $sql = "SELECT count(*) AS c1 FROM (SELECT tan FROM ci_questionnaire_results WHERE document_id = $questionnaire_id AND question_id = '$last_question' GROUP BY tan) sub1";
    my $valid_count = $self->data_provider->driver->dbh->fetch_one_value( sql => $sql );

    #  XIMS::Debug (6, "#### ".Dumper( $valid_count ) );
    return ($total_count, $valid_count, $total_count - $valid_count);
}

sub get_answer_count {
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;
    my $answer = shift;

    my $sql = "SELECT count(*) FROM ci_questionnaire_results WHERE document_id = $questionnaire_id AND question_id = '$question_id' AND answer='$answer' ";
    my $answer_count = $self->data_provider->driver->dbh->fetch_one_value( sql => $sql );

    #  XIMS::Debug (6, "#### ".Dumper( $answer_count ) );
    return $answer_count;
}

sub get_answers {
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;

    my $sql = "SELECT answer, count(answer) AS count FROM ci_questionnaire_results WHERE document_id = $questionnaire_id AND question_id = '$question_id' GROUP BY answer";
    my $answers = $self->data_provider->driver->dbh->fetch_select( sql => $sql );
    foreach my $answer_text ( @{$answers} ) {
        ${$answer_text}{'answer'} = _encode( ${$answer_text}{'answer'} );
    }

    return $answers;
}

sub _encode {
    my $string = shift;
    my $converter = Text::Iconv->new( XIMS::DBENCODING(), "UTF-8" );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

sub _decode {
    my $string = shift;
    my $converter = Text::Iconv->new( "UTF-8", XIMS::DBENCODING() );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

1;
