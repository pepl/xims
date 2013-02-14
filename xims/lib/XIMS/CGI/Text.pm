
=head1 NAME

XIMS::CGI::Text -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Text;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Text;

use common::sense;
use parent qw( XIMS::CGI );
use Text::Iconv;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
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
                                'obj_acllight',
                                @_
                                );
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes($ctxt);

    return $self->SUPER::event_edit($ctxt);
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    # This is actually used in the derived XIMS::CGI::JavaScript and
    # XIMS::CGI::CSS classes.
    if ( $self->param('minify') eq 'true' ) {
        $ctxt->object->attribute( minify => '1' );
    }
    else {
        $ctxt->object->attribute( minify => '0' );
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
        if ( defined $body and length $body ) {
            if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
                $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
            }
        }
    }

    if ( defined $body and length $body ) {
        my $object = $ctxt->object();
        $object->body( XIMS::xml_escape( $body ) );
    }

    return $self->SUPER::event_store( $ctxt );
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

