
=head1 NAME

XIMS::QuestionnaireResult

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QuestionnaireResult;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::QuestionnaireResult ;

use common::sense;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );

our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    return 'QuestionnaireResult';
}

__PACKAGE__->mk_accessors( @Fields );

=head2 store()

=cut

sub store {
    XIMS::Debug ( 5, "called" );
    my $self = shift;

    $self->answer_timestamp( $self->data_provider->db_now() );
    $self->id();
    $self->answer( $self->answer() );
    my $id = $self->data_provider->createQuestionnaireResult( $self->data());
    $self->id( $id );

    return $id;
}



=head2    XIMS::QuestionnaireResult->get_result_count( $questionnaire_id, $last_question )

=head3 Parameter

    $questionnaire_id: Document-ID of the questionnaire
    $last_question   : number of the last question that has
                       to be answered (= total number of questions)

=head3 Returns

    $total_count: number of all answered questionnaires
    $valid_count: number of valid answered questionnaires (all questions
                  answered)
    $total_count-$valid_count: number of invalid answered questionnaires

=head3 Description


=cut

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



=head2    XIMS::QuestionnaireResult->get_answer_count( $questionnaire_id, $question_id, $answer )

=head3 Parameter

    $questionnaire_id: Document-ID of the questionnaire
    $question_id     : ID of the question of which the number of answers should
                       be returned
    $answer          : text of the answer

=head3 Returns

    $answer_count: how many times was the specific answer given to the question

=head3 Description


=cut

sub get_answer_count {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;
    my $answer = shift;
    my $sql = "SELECT count(*) AS answercount FROM ci_questionnaire_results WHERE document_id = ? AND question_id = ? AND answer= ? ";
    my $answer_count = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $question_id, $answer ] );

    return $answer_count;
}



=head2    XIMS::QuestionnaireResult->get_answers( $questionnaire_id, $question_id, $answered )

=head3 Parameter

    $questionnaire_id: Document-ID of the questionnaire
    $question_id     : ID of the question of which the answers should be
                       returned


=head3 Returns

    $answers: reference to an array with all answers to the question and how
              often each answer was given

=head3 Description


=cut

sub get_answers {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $question_id = shift;
    my $answered = shift;

    if ( defined $answered and $answered == 1 ) {
        $answered = "AND answer = 'ANSWERED'";
    }
    else {
        $answered = '';
    }

    my $sql = "SELECT answer, count(answer) AS count FROM ci_questionnaire_results WHERE document_id = ? AND question_id = ? $answered GROUP BY answer";
    return $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $questionnaire_id, $question_id] );
}



=head2    XIMS::QuestionnaireResult->get_last_answer ( $questionnaire_id, $tan )

=head3 Parameter

    $questionnaire_id: Document-ID of the questionnaire
    $tan             : TAN of questionnaire that should be checked

=head3 Returns

    $question_id: ID of the last answered question of the questionnaire

=head3 Description

Before a question can be answered we check if the question has not been
answered before.
This function returns the ID of the last question the TAN has answered.
The answering of the questionnaire continues at the next question.
See XIMS::Questionnaire::set_answer_data()

=cut

sub get_last_answer {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $questionnaire_id = shift;
    my $tan = shift;

    my $sql = "SELECT coalesce(max(to_number(question_id,'999999')),0) AS lid FROM ci_questionnaire_results WHERE document_id = ? AND tan = ? AND answer = 'ANSWERED'";
    my $last_answered_question = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $tan ] );
    return $last_answered_question;
}

=head2 getResult()

=cut

sub getResult {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my ($questionnaire_id, $tan, $question) = @_;
    my $sql = "SELECT answer FROM ci_questionnaire_results WHERE document_id = ? AND tan = ? AND question_id = ?";
    my $result = $self->data_provider->driver->dbh->fetch_one_value( sql => [ $sql, $questionnaire_id, $tan, $question] );
    return $result;
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

