
=head1 NAME

XIMS::CGI::Folder -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::CGI::Folder;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Folder;

use strict;
use base qw( XIMS::CGI );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    return $self->SUPER::registerEvents(
        (
          'create',
          'edit',
          'store',
          'obj_acllist',
          'obj_aclgrant',
          'obj_aclrevoke',
          'publish',
          'publish_prompt',
          'unpublish',
          'test_wellformedness',
          @_
          )
        );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $ctxt->properties->content->getformatsandtypes( 1 );

    my $defaultsortby = $ctxt->object->attribute_by_key( 'defaultsortby' );
    my $defaultsort = $ctxt->object->attribute_by_key( 'defaultsort' );

    # maybe put that into config values
    $defaultsortby ||= 'position';
    $defaultsort ||= 'asc';

    unless ( $self->param('sb') and $self->param('order') ) {
        $self->param( 'sb', $defaultsortby );
        $self->param( 'order', $defaultsort );
        $self->param( 'defsorting', 1 ); # tell stylesheets not to
                                         # pass 'sb' and 'order' params
                                         # when linking to children
    }
    # The params override attribute and default values
    else {
        $defaultsortby = $self->param('sb');
        $defaultsort = $self->param('order');
    }

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = XIMS::SEARCHRESULTROWLIMIT(); # Create XIMS::CHILDRENROWLIMIT for that?
    $offset = $offset * $rowlimit;

    my %sortbymap = ( date => 'last_modification_timestamp', position => 'position', title => 'title' );
    my $order = $sortbymap{$defaultsortby} . ' ' . $defaultsort;

    $ctxt->properties->content->getchildren->limit( $rowlimit );
    $ctxt->properties->content->getchildren->offset( $offset );
    $ctxt->properties->content->getchildren->order( $order );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    my $autoindex  = $self->param( 'autoindex' );
    if ( defined $autoindex and $autoindex eq 'false') {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        $object->attribute( autoindex => '0' );
    }
    else {
        $object->attribute( autoindex => '1' );
    }

    my $defaultsortby = $self->param( 'defaultsortby' );
    if ( defined $defaultsortby ) {
        XIMS::Debug( 6, "defaultsortby: $defaultsortby" );
        my $currentvalue = $object->attribute_by_key( 'defaultsortby' );
        if ( $defaultsortby ne 'position' or defined $currentvalue ) {
            $object->attribute( defaultsortby => $defaultsortby );
        }
    }

    my $defaultsort = $self->param( 'defaultsort' );
    if ( defined $defaultsort ) {
        XIMS::Debug( 6, "defaultsort: $defaultsort" );
        my $currentvalue = $object->attribute_by_key( 'defaultsort' );
        if ( $defaultsort ne 'asc' or defined $currentvalue ) {
            $object->attribute( defaultsort => $defaultsort );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

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

Copyright (c) 2002-2007 The XIMS Project.

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

