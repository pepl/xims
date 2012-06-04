
=head1 NAME

XIMS::CGI::Gallery

=head1 VERSION

$Id: Gallery.pm 2239 2009-08-03 09:35:54Z haensel $

=head1 SYNOPSIS

    use XIMS::CGI::Gallery;

=head1 DESCRIPTION

It is based on XIMS::CGI::Folder.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Gallery;

use strict;
use base qw( XIMS::CGI::Folder );
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision: 2239 $ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          preview
          )
        );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS


=head2 event_preview()

=cut

sub event_preview {
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );
    
    $self->expand_attributes($ctxt);

    # Emulate request.uri CGI param, set by Apache::AxKit::Plugin::AddXSLParams::Request
    $self->param( 'request.uri', $ctxt->object->location_path_relative() );

    $ctxt->properties->application->style("preview");

    return 0;
}

# hmmm, really needed?

=head2 event_view()

=cut

sub event_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    
    $self->expand_attributes($ctxt);

    return $self->event_edit( $ctxt );
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

#    my $autoindex = $self->param('autoindex');
#    if ( defined $autoindex and $autoindex eq 'false' ) {
#        XIMS::Debug( 6, "autoindex: $autoindex" );
#        $object->attribute( autoindex => '0' );
#    }
#    else {
#        $object->attribute( autoindex => '1' );
#    }
    $object->attribute( autoindex => '0' );

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
    
    my $imgwidth = $self->param('imgwidth');   
    if ( defined $imgwidth) {
        $object->attribute( imgwidth => $imgwidth );
    } 
    
    my $thumbpos = $self->param('thumbpos');
    if ( defined $thumbpos ) {
        $object->attribute( thumbpos => $thumbpos );
    }
    
    my $shownav = $self->param('shownavigation');
    if ( defined $shownav and $shownav eq 'on' ) {
        $object->attribute( shownavigation => '1' );
    }
    else {
        $object->attribute( shownavigation => '0' );
    }
    
    my $showcaption = $self->param('showcaption');
    if ( defined $showcaption and $showcaption eq 'on' ) {
        $object->attribute( showcaption => '1' );
    }
    else {
        $object->attribute( showcaption => '0' );
    }

    return $self->SUPER::event_store($ctxt);
}

# END RUNTIME EVENTS
# #############################################################################

#=head2 expand_bodydeptinfo()
#
#=cut
#
#sub expand_bodydeptinfo {
#    my $self = shift;
#    my $ctxt = shift;
#
#    eval "require XIMS::SAX::Filter::DepartmentExpander;";
#    if ( $@ ) {
#        XIMS::Debug( 2, "could not load department-expander: $@" );
#        return 0;
#    }
#    my $filter = XIMS::SAX::Filter::DepartmentExpander->new( Object   => $ctxt->object(),
#                                                             User     => $ctxt->session->user(), );
#    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
#    push @{$ctxt->sax_filter()}, $filter;
#}

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

