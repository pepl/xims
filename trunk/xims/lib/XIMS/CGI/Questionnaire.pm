
=head1 NAME

XIMS::CGI::Questionnaire -- A module introducing a poll system

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Questionnaire;

=head1 DESCRIPTION

This module introduces a simple poll system.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Questionnaire;

use common::sense;
use parent qw( XIMS::CGI );
use XIMS::QuestionnaireResult;
use File::Spec;
use File::Temp qw/ tempfile unlink0 /;
use Archive::Zip qw/ :ERROR_CODES :CONSTANTS /;
use Text::Iconv;
use XML::LibXSLT;
use Locale::TextDomain ('info.xims');


# (de)register events here

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
            answer
            download_results
            download_all_results
            download_raw_results
            download_results_pdf
            )
    );
}

#
# override or add event handlers here
#
# override SUPER::events

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();

    # check if user is coming in via /gopublic (if ximsPublicUserName is
    # configured)
    if ( $ctxt->session->auth_module() eq 'XIMS::Auth::Public' ) {
        XIMS::Debug( 6, "Answering of Questionnaire started." );
        $self->_default_public($ctxt);
    }
    else {
        $object->body( $object->body() );
        $object->set_statistics();
        $object->body( $object->body() );
    }
    $self->SUPER::event_default($ctxt);
}

=head2 private functions/methods

=over

=item _default_public()

=back

=cut

sub _default_public {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $user   = $ctxt->session->user;
    $object->body( $object->body() );
    my $tan_needed = $object->tan_needed();
    XIMS::Debug( 6,
        "User " . $user->name . " is answering the questionnaire" );

    # If a public users is starting to answer the questionnaire some
    # extra data has to be stored in the xml-body
    my %params = $self->Vars;
    my $tan    = $self->param('tan');
    if ( $tan_needed && ( !$object->tan_ok($tan) ) && $params{'q'} ) {
        XIMS::Debug( 5, "Start: TAN not valid!" );
        $object->set_answer_error(__"Your TAN is not valid!");

        # Set current_question back
        $params{'q'} = 0;
    }

    # If no TAN is submitted either use a random number as TAN
    # (kioskmode), or use the session id as TAN (unique value for
    # identifying answers)
    unless ($tan) {
        if ( $object->kioskmode() ) {
            $tan = int( rand(1000) ) . time();
        }
        else {
            $tan = $ctxt->session->id();
        }
    }

    $params{'tan'} = $tan;
    $object->set_answer_data(%params);
    $object->body( $object->body() );
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # if called from editing the edit parameter is always true because
    # edit is a hidden field in the html-form. So if the Save-button is
    # clicked this event has to be handled manually.
    if ( $self->param('store') ) {
        $self->event_store($ctxt);
        return 0;
    }
    my $object = $ctxt->object();
    $object->body( $object->body() )
        if defined $object->body();

    # a published questionnaire or a questionnaire which has already
    # been answered must not be edited
    if ( $object->has_answers() ) {
        XIMS::Debug( 5, "cannot edit answered questionnaire" );
        $self->sendError( $ctxt,
            __"Already answered questionnaires cannot be edited! You can copy the questionnaire and edit the copy."
        );
        return 0;
    }
    if ( $object->published() ) {
        XIMS::Debug( 5, "cannot edit published questionnaire" );
        $self->sendError( $ctxt,
            __"Published Questionnaires can not be edited! Unpublish first" );
        return 0;
    }
    my $method = $self->param('edit');
    XIMS::Debug( 4, "got method $method" );

    my $edit_id = $self->param('qid');
    my %params  = $self->Vars;
    my $q_dom   = $object->form_to_xml(%params);

    if ( defined $edit_id ) {

        # replace x between ids with ., except a tanlist is added
        # tanlists are added by path not id
        $edit_id =~ s/x/\./g unless $method eq 'add_tanlist';
    }

    # after the form has been processed to xml we don't need the
    # form-params anymore, to avoid problems with later serialization
    foreach ( $self->param() ) {
        $self->delete($_) if /^[question|answer]/;
    }
    $object->$method( $edit_id, $q_dom ) unless $method eq '1';
    $object->body( $object->body() )
        if defined $object->body();
    $self->resolve_content( $ctxt, [qw( STYLE_ID )] );
    $self->SUPER::event_edit($ctxt);
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $self->SUPER::event_create($ctxt);
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $body   = $object->body();
    return 0
        unless $self->init_store_object($ctxt)
        and defined $ctxt->object();
    if ( $body =~ /questionnaire/ ) {

        #build xml from HTML-Form. This is done before init_store,
        #because params have to be UTF-8
        my %params = $self->Vars;
        my $q_dom  = $object->form_to_xml(%params);
        $body = $q_dom->toString();
    }
    else {
        $ctxt->object()
            ->body( "<questionnaire><title>"
                . $self->param('title')
                . "</title><comment>"
                . $self->param('questionnaire_comment')
                . "</comment></questionnaire>" );
        $body = $ctxt->object()->body();
    }
    $object->body( $body, dontbalance => 1 );
    XIMS::Debug( 6, "body set, len: " . length($body) );
    $ctxt->object()
        ->title( $self->param('title') );
    return $self->SUPER::event_store($ctxt);
}

=head2 event_answer()

=cut

sub event_answer {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $object->body( $object->body() )
        if defined $object->body();
    my $tan              = $self->param('tan');
    my $questionnaire_id = $object->document_id();
    my $tan_needed       = $object->tan_needed();

    # if no TAN is submitted check if one is needed
    if ( !$tan ) {
        XIMS::Debug( 6, "Result: no TAN submitted" );
        if ($tan_needed) {

            #if TAN is needed display message and restart questionnaire
            XIMS::Debug( 5, "Result: TAN needed" );
        }
        else {

            #if no TAN is needed take current session-id as unique
            #number
            XIMS::Debug( 6, "Result: no TAN needed" );
            $tan = $ctxt->session->id();
        }
    }
    XIMS::Debug( 6, "Result: TAN = $tan" );

    # if TAN is submitted and TAN is needed check in TAN_List
    if ($tan_needed) {
        if ( !$object->tan_ok($tan) ) {

            #if TAN does not match display message and restart
            #questionnaire
            XIMS::Debug( 6, "Result: TAN does not match" );
        }
    }

    # if question_id (top-level) and TAN are already in the
    # questionnaire, check if all needed answers are given if not all
    # answers are stored, display the question if all answers are stored
    # redirect to next question

    # Check if all necessary answers are given if the "mandatoryanswers"
    # option is set (TODO)

    # Store answer in Database
    my %params = $self->Vars;
    $params{'tan'} = $tan;
    $object->store_result(%params);
    $object->set_answer_data(%params);

    # after the form has been processed to xml we don't need the
    # form-params anymore, to avoid problems with later serialization
    foreach ( $self->param() ) {
        $self->delete($_) if /^[question|answer]/;
    }
    $object->body( $object->body() )
        if defined $object->body();
    $self->SUPER::event_default($ctxt);
}

=head2 event_download_results()

=cut

sub event_download_results {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # Only allow access to users with WRITE privilege (Privilege could
    # be replaced with a specific VIEW_RESULTS privilege
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    my $questionnaire_id = $object->document_id();

    # get count of answers for each Question from the Questionnaire
    my $fta = $self->param('full_text_answers');
    $fta ||= 0;
    $object->set_results( full_text_answers => $fta );
    if ( $self->param('download_results') eq 'html' ) {
        $ctxt->properties->application->style('download_results_html');
    }
    elsif ( $self->param('download_results') eq 'excel' ) {
        $ctxt->properties->application->style('download_results_excel');
    }
    return 0;
}

=head2 event_download_all_results()

=cut

sub event_download_all_results {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # Only allow access to users with WRITE privilege (Privilege could
    # be replaced with a specific VIEW_RESULTS privilege
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    my $questionnaire_id    = $object->document_id();
    my $body                = "";
    my $converter_to_Latin1 = Text::Iconv->new( "UTF-8", "ISO-8859-1" );

    # set filename and mime type of the file to download
    my $filename = $object->location;
    $filename =~ s/\.[^\.]*$//;

    my $type     = $self->param('download_all_results');
    my $encoding = $self->param('encoding');

    my $df = XIMS::DataFormat->new( name => $type );
    $filename .= "." . $df->suffix;
    my $mime_type = $df->mime_type;

    # get a list with all answers to the questionnaire
    my $sql = "SELECT tan, question_id, answer, answer_timestamp "
            . "FROM ci_questionnaire_results "
            . "WHERE answer <> 'ANSWERED' AND document_id = ?";
    my $answers = $object->data_provider->driver->dbh->fetch_select(
        sql => [ $sql, $questionnaire_id ] );

    # build all answers depending on the type
    my %question_titles = $object->get_full_question_titles();
    if ( $type =~ /xls/i ) {
        XIMS::Debug( 4, "Type is Excel" );
        foreach my $answer ( @{$answers} ) {
            my $answer_text = ${$answer}{'answer'};
            $answer_text =~ s/\015?\012/ /g; # replace newlines with
                                             # spaces.
            $answer_text =~ s/\t/ /g;        # although tabs are
                                             # filtered during storing,
                                             # you never know The "A" in
                                             # the Answer-id field is
                                             # neccessary because Excel
                                             # interprets eg 1.1.1 as a
                                             # date.
            $body .= ${$answer}{'tan'} . "\t"
                . $question_titles{ ${$answer}{'question_id'} } . "\tA "
                . ${$answer}{'question_id'} . "\t"
                . $answer_text . "\n";
        }

        if ( $encoding =~ /latin1/i ) {
            XIMS::Debug( 6, "Encoding is Latin1" );
            $encoding = 'ISO-8859-1';
        }
        else {
            $encoding = 'UTF-8';
            $body = Encode::encode('UTF-8', $body);
        }
    }
    elsif ( $type =~ /html/i ) {
        XIMS::Debug( 4, "Type is HTML" );

        # For compatibility with Mac-Browsers we have to cheat a bit
        # with the mime-type
        $mime_type = 'text/html';

        # Why not use DBIx::XHTML_Table here?
        $body = '<html><head><title>'
            . $filename
            . '</title></head><body><table border="1">';
        $body
            .= "<tr><td>Q ID</td><td>Q</td><td>A ID</td><td>A</td><td>Timestamp</td></tr>";
        foreach my $answer ( @{$answers} ) {
            $body .= "<tr><td>"
                . ${$answer}{'tan'}
                . "</td><td>"
                . $converter_to_Latin1->convert(
                $question_titles{ ${$answer}{'question_id'} } )
                . "</td><td>"
                . ${$answer}{'question_id'}
                . "</td><td>"
                . ${$answer}{'answer'}
                . "</td><td>"
                . ${$answer}{'answer_timestamp'}
                . "</td></tr>";
        }
        $body .= "</table></body></html>";
    }

    # older browsers use the suffix of the URL for content-type
    # sniffing, so we have to supply a content-disposition header
    return 0 unless $body;

 	$self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            '-charset'             => $encoding,
            '-type'                => $mime_type,
            '-Content-disposition' => "attachment; filename=$filename",
        ),
        $body
    );
    $self->skipSerialization(1);

    return 0;
}

=head2 event_download_raw_results()

=cut

sub event_download_raw_results {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # Only allow access to users with WRITE privilege (Privilege could
    # be replaced with a specific VIEW_RESULTS privilege
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    my ( $tmpfh, $tmpfilename ) = tempfile();

    # write header row
    my @columns = qw( id tan question_id answer answer_timestamp );
    print $tmpfh join( "\t", @columns );
    print $tmpfh "\r\n";

    # write data rows visit_select_rows() croaks for some reason here.
    # so, we can't do join("\t",@_) :-/
    $object->data_provider->driver->dbh->visit_select(
        sub {
            my $r = shift;
            $r->{answer} =~ s/\015?\012/ /g; # replace newlines with
                                             # spaces
            $r->{answer} =~ s/\t/ /g;        # although tabs are
                                             # filtered during storing,
                                             # you never know
            print $tmpfh "$r->{id}\t$r->{tan}\t$r->{question_id}\t$r->{answer}\t$r->{answer_timestamp}";
            print $tmpfh "\r\n";
        },
        table    => 'ci_questionnaire_results',
        columns  => \@columns,
        criteria => { 'document_id' => $object->document_id() }
    );

    # create zip file
    my $zip         = Archive::Zip->new();
    my $zipfilename = 'rawresults_' . $object->location();

    seek( $tmpfh, 0, 0 );    # make sure we read from the start of the file
    my $member = $zip->addFile( $tmpfilename, $zipfilename . '.txt' );

    # write zip to temporary file
    my $zipfilefh = IO::File->new_tmpfile();
    if ($zipfilefh) {
        if ( $zip->writeToFileHandle($zipfilefh) != AZ_OK ) {
            XIMS::Debug( 2, "Could not create temporary ZIP file." . $! );
            $self->sendError( $ctxt, __"Could not create temporary ZIP file" );
            return 0;
        }
        else {
            # make sure we read from the start of the file
            seek( $zipfilefh, 0, 0 );
        }
        if ( not unlink0( $tmpfh, $tmpfilename ) ) {
            XIMS::Debug( 2, "Could not unlink temporary file." . $! );
        }
    }
    else {
        XIMS::Debug( 2, "Could not write temporary ZIP file." . $! );
        $self->sendError( $ctxt, __"Could not write temporary ZIP file" );
        return 0;
    }

    my $mime_type = XIMS::DataFormat->new( suffix => 'zip' )->mime_type();

    $self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            '-charset'             => 'UTF-8',
            '-type'                => $mime_type,
            '-Content-disposition' => "attachment; filename=$zipfilename.zip",
        ),
        $zipfilefh
    );

    $self->skipSerialization(1);

    return 0;
}

=head2 event_download_results_pdf()

=cut

sub event_download_results_pdf {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # Only allow access to users with WRITE privilege (Privilege could
    # be replaced with a specific VIEW_RESULTS privilege
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    my $questionnaire_id = $object->document_id();

    # get count of answers for each Question from the Questionnaire
    my $fta = $self->param('full_text_answers');
    $fta ||= 0;
    $object->set_results( full_text_answers => $fta );

    $ctxt->properties->application->style('download_results_html');

    my $xml_doc    = $self->getDOM($ctxt);
    my $stylesheet = $self->selectStylesheet($ctxt);

    my ( $xsl_dom, $style, $res );
    my $parser = XML::LibXML->new();
    my $xslt   = XML::LibXSLT->new();

    $xsl_dom = $parser->parse_file($stylesheet);
    $style   = $xslt->parse_stylesheet($xsl_dom);
    $res     = $style->transform($xml_doc);

    my $out_string = $style->output_string($res);

    # htmldoc wants an 8-bit character set.
    my $converter = Text::Iconv->new( "UTF-8", "ISO-8859-15" );
    my $converted = $converter->convert($out_string);
    $out_string = $converted if defined $converted;

    my ( $tmpfh, $tmpfilename ) = tempfile();
    binmode( $tmpfh, 'ISO-8859-15' );
    $tmpfh->print($out_string);

    my $htmldoc = XIMS::Config::htmldocPath();
    unless ( -e $htmldoc and -x $htmldoc ) {
        XIMS::Debug( 2, "could not find/execute $htmldoc" );
        $self->sendError( $ctxt, __"Could not find or execute htmldoc." );
        return 0;
    }

    $ENV{HTMLDOC_NOCGI} = 1;
    my $pdf = `$htmldoc -t pdf13 --size a4 --no-jpeg --quiet --no-strict --webpage --no-toc $tmpfilename`;

    if ( not unlink0( $tmpfh, $tmpfilename ) ) {
        XIMS::Debug( 2, "Could not unlink temporary file." . $! );
    }

    if ( $pdf =~ m/^%PDF-1.3/ ) {
        my $resultfile = $object->title() . '.pdf';
        $self->{RES} = $self->{REQ}->new_response(
            $self->psgi_header(
                '-type'        => "application/pdf",
                '-attachment'  => $resultfile,
                '-disposition' => "attachment; filename=$resultfile;"
            ),
            $pdf
        );
        $self->skipSerialization(1);
        return 0;
    }
    else {
        XIMS::Debug( 2, "failed to create pdf: $pdf" );
        $self->sendError( $ctxt, __"Could not create PDF file!" );
        return 0;
    }
}

=head2 event_publish()

=cut

sub event_publish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->publish_gopublic(@_);
}

=head2 event_unpublish()

=cut

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->unpublish_gopublic(@_);
}

=head2 event_exit()

=cut

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $self->SUPER::event_exit($ctxt);
    $ctxt->properties->content->escapebody(0);    # do not escape body
    return 0;
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

Copyright (c) 2002-2017 The XIMS Project.

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

