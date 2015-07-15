
=head1 NAME

XIMS::CGI::DepartmentRoot

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::DepartmentRoot;

=head1 DESCRIPTION

It is based on XIMS::CGI::Folder.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::DepartmentRoot;

use common::sense;
use parent qw( XIMS::CGI::Folder );
use Locale::TextDomain ('info.xims');


# #############################################################################
# GLOBAL SETTINGS

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          add_portlet:POST
          rem_portlet:POST
          )
        );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS


=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->expand_bodydeptinfo( $ctxt );
    $self->resolve_content( $ctxt, [ qw( STYLE_ID IMAGE_ID CSS_ID SCRIPT_ID FEED_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

# hmmm, really needed?

=head2 event_view()

=cut

sub event_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return $self->event_edit( $ctxt );
}

=head2 event_add_portlet()

=cut

sub event_add_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $path = $self->param( "portlet" );
    if ( defined $path ) {
        if ( not ($object->add_portlet( $path ) and $object->update() ) ) {
            $self->sendError( $ctxt, __"Could not add portlet." );
            return 0;
        }
    }
    else {
        $self->sendError( $ctxt, __"Path to portlet-target needed." );
        return 0;
    }

    return $self->event_edit( $ctxt );
}

=head2 event_rem_portlet()

=cut

sub event_rem_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $portlet_id = $self->param( "portlet_id" );
    if ( defined $portlet_id and $portlet_id > 0 ) {
        if ( not ( $object->remove_portlet( $portlet_id ) and $object->update() ) ) {
            $self->sendError( $ctxt, __"Could not remove portlet." );
            return 0;
        }
    }
    else {
        $self->sendError( $ctxt, __"Which portlet should be removed?" );
        return 0;
    }

    return $self->event_edit( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

=head2 expand_bodydeptinfo()

=cut

sub expand_bodydeptinfo {
    my $self = shift;
    my $ctxt = shift;

    eval "require XIMS::SAX::Filter::DepartmentExpander;";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load department-expander: $@" );
        return 0;
    }
    my $filter = XIMS::SAX::Filter::DepartmentExpander->new( Object   => $ctxt->object(),
                                                             User     => $ctxt->session->user(), );
    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    push @{$ctxt->sax_filter()}, $filter;
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

