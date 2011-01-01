
=head1 NAME

XIMS::CGI::Folder -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

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

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->SUPER::registerEvents(
        (
            'create',       'edit',
            'store',        'obj_acllist',	'obj_acllight',
            'obj_aclgrant', 'obj_aclrevoke',
            'publish',      'publish_prompt',
            'unpublish',    'test_wellformedness',
            @_
        )
    );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default($ctxt);

    $ctxt->properties->content->getformatsandtypes(1);

    my $display_params = $self->get_display_params($ctxt);

    $ctxt->properties->content->getchildren->limit( $display_params->{limit} );
    $ctxt->properties->content->getchildren->offset(
        $display_params->{offset} );
    $ctxt->properties->content->getchildren->order( $display_params->{order} );

    # not needed ATM, kept for reference.
    #     if ( defined $display_params->{style} ) {
    #         $ctxt->properties->application->style($display_params->{style});
    #     }

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving
    # some ms...
    $ctxt->properties->content->escapebody(1);

    return 0;
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

    return 0
      unless $self->init_store_object($ctxt)
      and defined $ctxt->object();

    my $object = $ctxt->object();

    my $autoindex = $self->param('autoindex');

    if ( defined $autoindex and $autoindex eq 'false' ) {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        $object->attribute( autoindex => '0' );
    }
    else {
        $object->attribute( autoindex => '1' );
    }

    my $pagerowlimit = $self->param('pagerowlimit');

    #empty or up to 2 figures.
    if ( defined $pagerowlimit and $pagerowlimit =~ /^\d{0,2}$/ ) {
        XIMS::Debug( 6, "pagerowlimit: $pagerowlimit" );
        $object->attribute( pagerowlimit => $pagerowlimit );
    }

    my $defaultsortby = $self->param('defaultsortby');

    if ( defined $defaultsortby ) {
        XIMS::Debug( 6, "defaultsortby: $defaultsortby" );
        my $currentvalue = $object->attribute_by_key('defaultsortby');
        if ( $defaultsortby ne 'position' or defined $currentvalue ) {
            $object->attribute( defaultsortby => $defaultsortby );
        }
    }

    my $defaultsort = $self->param('defaultsort');

    if ( defined $defaultsort ) {
        XIMS::Debug( 6, "defaultsort: $defaultsort" );
        my $currentvalue = $object->attribute_by_key('defaultsort');
        if ( $defaultsort ne 'asc' or defined $currentvalue ) {
            $object->attribute( defaultsort => $defaultsort );
        }
    }

    return $self->SUPER::event_store($ctxt);
}

# END RUNTIME EVENTS
# #############################################################################

=head2   get_display_params()

=head3 Parameter

    $ctxt: AppContext object.

=head3 Returns

A reference to a hash:

    {
        offset => $offset,
        limit  => $limit,
        order  => $order,
        style  => $style,
    }

=head3 Description
    
    my $display_params = $self->get_display_params($ctxt);

A common method to get the values for display-styles (ordering, pagination,
custom stylesheet names) merged from defaults, container attributes, and
CGI-parameters.

=cut

sub get_display_params {
    my ( $self, $ctxt ) = @_;
    my $defaultsortby = $ctxt->object->attribute_by_key('defaultsortby');
    my $defaultsort   = $ctxt->object->attribute_by_key('defaultsort');

    # maybe put that into config values
    $defaultsortby ||= 'position';
    $defaultsort   ||= 'asc';

    unless ( $self->param('sb') and $self->param('order') ) {
        $self->param( 'sb',    $defaultsortby );
        $self->param( 'order', $defaultsort );
        $self->param( 'defsorting', 1 );    # tell stylesheets not to pass
                                            # 'sb' and 'order' params when
                                            # linking to children
    }

    # The params override attribute and default values
    else {
        $defaultsortby = $self->param('sb');
        $defaultsort   = $self->param('order');
    }

    my %sortbymap = (
        date     => 'last_modification_timestamp',
        position => 'position',
        title    => 'title',
        location    => 'location'
    );

    my $order = $sortbymap{$defaultsortby} . ' ' . $defaultsort;

    my $style = $self->param('style');

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;

    my $limit;
    if ( defined $self->param('onepage') or defined $style ) {
        $limit = undef;
    }
    else {
        $limit = $self->param('pagerowlimit');
        unless ($limit) {
            $limit ||= $ctxt->object->attribute_by_key('pagerowlimit');
            $limit ||= XIMS::SEARCHRESULTROWLIMIT();

            # set for stylesheet consumation;
            $self->param( 'searchresultrowlimit', $limit );
        }
        $offset ||= 0;
        $offset = $offset * $limit;
    }

    return (
        {
            offset => $offset,
            limit  => $limit,
            order  => $order,
            style  => $style,
        }
    );
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

