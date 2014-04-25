

=head1 NAME

XIMS::CGI::Markdown.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Markdown;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut


package XIMS::CGI::Markdown;

use common::sense;
use parent qw( XIMS::CGI::Text );
use Text::Markdown 'markdown';

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# (de)register events here
sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    $self->SUPER::registerEvents(
                                'create',
                                'edit',
                                'store',
                                'publish',
                                'publish_prompt',
                                'unpublish',
                                'obj_acllist',
                                'obj_aclgrant',
                                'obj_aclrevoke',
                                @_
                                );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;
    return 0 if $self->SUPER::event_default( $ctxt );

    $ctxt->properties->content->getchildren->objecttypes( [ qw( Text URLLink SymbolicLink ) ] );

    my $newbody = markdown( $ctxt->object->body() );
    $ctxt->object->body( $newbody );

    return 0;
}


=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );

    return 0;
}

=head2 event_create()

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );

    # check if a code editor is to be used based on cookie or config
    my $ed = $self->set_code_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

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
        my $object = $ctxt->object();
        $object->body( XIMS::xml_escape( $body ) );
    }

    return $self->SUPER::event_store( $ctxt );
}

1;



1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Write me.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

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

