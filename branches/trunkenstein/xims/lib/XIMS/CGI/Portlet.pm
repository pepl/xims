
=head1 NAME

XIMS::CGI::Portlet

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Portlet;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Portlet;

use common::sense;
use parent qw( XIMS::CGI );
use XIMS::Portlet;
use Locale::TextDomain ('info.xims');


# #############################################################################
# GLOBAL SETTINGS

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          publish
          publish_prompt
          unpublish
          obj_acllist
          obj_acllight
          obj_aclgrant
          obj_aclrevoke
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
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->expand_portletinfo( $ctxt );
    $ctxt->properties->content->getformatsandtypes( 1 );

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );
    $ctxt->properties->content->getformatsandtypes( 1 );

    return 0;
}

=head2 event_create()

=cut

sub event_create {
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes( 1 );

    return $self->SUPER::event_create( $ctxt );
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
    my $target = $self->param('target');

    if ( defined $target and length $target ) {
        XIMS::Debug( 6, "target: $target" );
        my $targetobj;
        if (    $target =~ /^\d+$/
            and $target ne '1'
            and $targetobj = XIMS::Object->new(
                document_id => $target,
                language    => $object->language_id
            )
            )
        {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        elsif (
                $target ne '/'
            and $target ne '/root'
            and $targetobj = XIMS::Object->new(
                path     => $target,
                language => $object->language_id
            )
            )
        {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        else {
            XIMS::Debug( 2,
                "Could not find or set target (SYMNAME_TO_DOC_ID)" );
            $self->sendError( $ctxt, __"Could not find or set target" );
            return 0;
        }

        if (    $object->document_id
            and $object->document_id == $object->symname_to_doc_id )
        {
            XIMS::Debug( 2, "Will not store a self-referencing link" );
            $self->sendError( $ctxt,
                __"Will not store a self-referencing link" );
            return 0;
        }
    }
    else {
        XIMS::Debug( 2, "No target specified!" );
        $self->sendError( $ctxt, __"No target specified!" );
        return 0;
    }

    my $body = $self->generate_body($ctxt);
    $ctxt->object->body($body);

    return $self->SUPER::event_store($ctxt);
}



=head2    event_test_filter( $app, $ctxt );

=head3 Parameter

    $ctxt: The applocation context

=head3 Returns

    allways 0

=head3 Description

this littly event tests the wellformedness of the extra data filter
information. ( not used yet )

=cut

sub event_test_filter {
    my $self = shift;
    my $ctxt = shift;

    if ( $self->param( "extra-filters" ) ) {
        require XML::LibXML;

        my $filter = $self->param( "extra-filters" );
        eval {
            my $chunk  = XML::LibXML->new->parse_balanced_chunk( $filter );
        };
        if ( $@ ) {
            $ctxt->session->error_msg( __"bad formed filter conditions: " . $@ );
        }
        else {
            $ctxt->session->message( __"filter xml looks ok" );
        }
    }

    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

=head2 expand_portletinfo()

=cut

sub expand_portletinfo {
    my $self = shift;
    my $ctxt = shift;

    $ctxt->properties->content->childrenbybodyfilter( 1 );

    eval "require XIMS::SAX::Filter::PortletCollector;";
    if ( $@ ) {
        XIMS::Debug( 3, "could not require portletcollector : $@" );
        return;
    }

    my $filter = XIMS::SAX::Filter::PortletCollector->new( Provider => $ctxt->data_provider(),
                                                           Object   => $ctxt->object(),
                                                           User     => $ctxt->session->user(),);
    $ctxt->sax_filter( [$filter] );
}

=head2 generate_body()

=cut

sub generate_body {
    my $self = shift;
    my $ctxt = shift;
    my $body = "";

    # code to be rewritten follows
    # parse the fragment and work with it using the DOM API...

    $body = "<content>";
    # pepl: *ouch*; this should not be HERE!
    foreach my $p ( qw( created_by_fullname creation_timestamp
                        last_modified_by_fullname
                        owned_by_fullname last_modification_timestamp
                        valid_from_timestamp valid_to_timestamp
                        last_publication_timestamp status attributes
                        marked_new abstract image_id body ) ) {
        if ( defined $self->param( 'col_' . $p ) ) {
            if ( $p =~ /(.+)fullname/ ) {
                my ( $p1, $p2, $p3 ) = map { $1 . $_ } qw(firstname middlename lastname);
                $body .= qq{<column name="$p1"/>};
                $body .= qq{<column name="$p2"/>};
                $body .= qq{<column name="$p3"/>};
            }
            else {
                $body .= qq{<column name="$p"/>};
            }
        }

    }

    if ( $self->param( "f_depth" ) eq 'true'  and $self->param( "depth" ) ) {
        $body .= '<depth>' . $self->param( "depth" ) . '</depth>';
    }

    if ( $self->param( "f_latest" ) eq 'true'  and $self->param( "latest" ) ) {
        $body .= '<latest>' . $self->param( "latest" ) . '</latest>';
    }

    my $latest_sortkey = $self->param( 'f_latest_sortkey' );
    if ( defined $latest_sortkey ) {
        XIMS::Debug( 6, "latest_sortkey: $latest_sortkey" );
        if ( $latest_sortkey ne 'last_modification_timestamp' ) { # default value
            $body .= '<latest_sortkey>' . $latest_sortkey . '</latest_sortkey>';
        }
    }

    if ( $self->param( "documentlinks" ) ) {
        $body .= '<documentlinks>1</documentlinks>';
    }

    foreach my $type ( map { $_->name() } $ctxt->data_provider->object_types() ) {
        next unless defined $type;
        my $name = "ot_$type";
        my $v    = $self->param( $name );
        next unless defined $v;
        $body .= '<object-type name="' . $type . '"/>';
    }

    $body .= "</content>\n";
    $body .= "<filter>\n";
    if ( $self->param( "filternews" ) ) {
        $body .= qq{<marked_new>1</marked_new>\n};
    }

    if ( $self->param( "filterpublished" ) ) {
        $body .= qq{<published>1</published>\n};
    }

    if ( $self->param( 'filterlocation' )) {
        $body .= '<location>'
              . XIMS::xml_escape( $self->param( 'filterlocation' ) )
              . "</location>\n";
    }

    if ( $self->param( 'filtertitle' )) {
        $body .= '<title>'
              . XIMS::xml_escape( $self->param( 'filtertitle' ) )
              . "</title>\n";
    }

    if ( $self->param( "extra_filters" ) ) {
        XIMS::Debug( 5, "add additional xims filter!" );
        require XML::LibXML;

        my $filter = $self->param( "extra_filters" );
        XIMS::Debug( 5, "filter is $filter" );
        eval {
            my $chunk  = XML::LibXML->new->parse_balanced_chunk( $filter );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "bad formed filter conditions : $@" );
        }
        else {
            $body .= $filter . "\n";
        }
    }

    $body .= "</filter>\n";

    return $body;
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

