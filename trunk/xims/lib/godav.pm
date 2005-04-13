# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package godav;

use strict;
use warnings;

#
# Note: This module has PROOF OF CONCEPT status. Use at your own risk!
#       This module has been tested with cadaver, konqueror and Webdrive
#       and Novell's Netdrive DAV client software
#       http://host/godav/xims/
#
# TODO
#    * Implement lock() and unlock()
#    * Work on M$ web folder compatibility
#    * Add acceptance tests (HTTP::DAV)
#    * Add documentation
#    * Clean up (Store $object in a package variable?, ...)
#    * Things I forgot
#

use XIMS::Object;
use XIMS::Folder;
use XIMS::User;
use Time::Piece;
use XIMS::Importer::Object;

use Apache;
use Apache::Constants qw(:common :response);
#use Apache::File ();
#use Apache::Request;
use Apache::URI;
use URI::Escape;
use XML::LibXML;
our $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };;

sub handler {
    my $r = shift;
    XIMS::Debug( 5, "godav called from " . $r->get_remote_host );

    my $method = $r->method;
    my $path    = uri_unescape($r->uri);

    my $user =  $r->pnotes( 'ximsBasicAuthUser' );
    return (403) unless defined $user;

    #use Data::Dumper;
    #my %h = $r->headers_in();
    #warn Dumper \%h;

    $r->header_out( 'X-Server', 'XIMS::DAVServer ' . $VERSION );
    $r->header_out( 'MS-Author-Via', 'DAV' );

    $method = lc $method;
    no strict 'refs';
    my ($status_code, $content) = &{$method}( $r, $user );
    use strict 'refs';

    #$r->header_out( 'Status', $status_code );
    $r->status( $status_code );
    if ( defined $content ) {
        #$r->set_content_length( length($content) );
        $r->header_out( 'Content-Length', length($content) );
        $r->send_http_header();
        $r->print( $content );
        #%h = $r->headers_out();
        #warn Dumper \%h;
        #warn $content;
    }
    else {
        $r->send_http_header();
    }

    # return $status_code;
}

sub options {
    my $r = shift;
    my $user = shift;
    my $status_code;

    $r->header_out( 'DAV', 1 );
    $r->header_out( 'Allow', 'OPTIONS, GET, HEAD, POST, DELETE, TRACE, PROPFIND, PROPPATCH'); #, COPY, MOVE, LOCK, UNLOCK' );
    return (200, undef);
}

sub proppatch { (403) }

sub get {
    my $r = shift;
    my $user = shift;
    my $status_code;
    my $content;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::VIEW;

    if ( defined $object and defined $object->id() ) {
        if ( $object->object_type->is_fs_container() ) {
            my @children = $object->children_granted( properties => [ 'location', 'id', 'object_type_id' ], marked_deleted => undef );
            my $body;
            my $location;
            foreach my $child ( @children ) {
                $location = $child->location();
                if ( $child->object_type->is_fs_container() ) {
                    $body .= qq|<a href="./$location/">$location/</a><br>\n|;
                }
                else {
                    $location =~ s{/$}{};
                    $body .= qq|<a href="./$location">$location</a><br>\n|;
                }
            }
            $r->content_type( 'text/html' );
            $content = $body;
            $status_code = 200;
        }
        else {
            $r->content_type( $object->data_format->mime_type() );
            $content = $object->body();
            my $t = Time::Piece->strptime( $object->last_modification_timestamp(), "%d.%m.%Y %H:%M:%S" );
            #$r->set_last_modified( $t->epoch() );
            $status_code = 200;
        }
    }
    else {
        $status_code = 404;
    }

    return ($status_code, $content);
}

sub post { get( @_ ) }

sub put {
    my $r = shift;
    my $user = shift;
    my $status_code;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );

    my $body;
    $r->read( $body, $r->header_in( 'Content-Length') );

    my $object_class;
    if ( defined $object and $object->id() ) {
        my $privmask = $user->object_privmask( $object );
        return (403) unless $privmask & XIMS::Privileges::WRITE;

        # now that should be moved to run()....
        my $ot_fullname = $object->object_type->fullname();
        $object_class .= 'XIMS::' . $ot_fullname;

        # load the object class
        eval "require $object_class;" if $object_class;
        if ( $@ ) {
            $status_code = 500;
        }
        bless $object, $object_class;

        # update existing object
        if ( $object->body( $body ) ) {
            if ( $object->update() ) {
                $status_code = 201;
            }
            else {
                $status_code = 500;
            }
        }
        else {
            $status_code = 500;
        }
    }
    else {
        # create new object
        my $parentpath = $path;
        $parentpath =~ s#[^/]+$##;
        my $parent = XIMS::Object->new( User => $user, path => $parentpath, marked_deleted => undef );
        return (409) unless defined $parent and defined $parent->id();

        my $privmask = $user->object_privmask( $parent );
        return (403) unless $privmask & XIMS::Privileges::CREATE;

        my $importer = XIMS::Importer::Object->new( User => $user, Parent => $parent );
        my ($object_type, undef) = $importer->resolve_filename( $path );

        # now that should be moved somewhere else....
        $object_class .= 'XIMS::' . $object_type->fullname;

        # load the object class
        eval "require $object_class;" if $object_class;
        if ( $@ ) {
            $status_code = 500;
        }
        my ( $location ) = ( $path =~ m|([^/]+)$| );
        $object = $object_class->new( User => $user, location => $location );
        $object->body( $body );
        my $id = $importer->import( $object );
        if ( defined $id ) {
            $status_code = 201;
        }
        else {
            $status_code = 500;
        }
    }

    return ($status_code);
}

sub delete {
    my $r = shift;
    my $user = shift;
    my $status_code;

    return (404) if defined $r->parsed_uri->fragment;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::DELETE;

    if ( defined $object and defined $object->id() ) {
        # test if object is locked and return 207 here in case
        #

        # honor Depth header here?

        if ( $object->trashcan() ) {
            $status_code = 204; # 'No Content'
        }
        else {
            $status_code = 500; # return 207 here instead
        }
    }
    else {
        $status_code = 404;
    }

    return ($status_code);
}

sub copy {
    my $r = shift;
    my $user = shift;
    my $status_code;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );

    my $parent_priv = $user->object_privmask( $object->parent );
    return (403) unless $parent_priv & XIMS::Privileges::CREATE;

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::COPY;

    my $destination = $r->header_in( 'Destination' );
    $destination = $r->lookup_uri( $destination )->path_info(); # or do a s/$godav//; ?
    my $depth = $r->header_in( 'Depth' );
    my $overwrite = $r->header_in( 'Overwrite' );

    # copy here, adjust XIMS::Object::clone to support parent_id (Destination) parameter

    return (501);
}

sub move {
    my $r = shift;
    my $user = shift;
    my $status_code;

    return (501);

    ($status_code, undef) = &copy( $r, $user );
    ($status_code, undef) = &delete( $r, $user ) if $status_code == 200;
    return (501);
}

sub mkcol {
    my $r = shift;
    my $user = shift;

    my $path = uri_unescape( $r->path_info() );
    $path =~ s#/$##;
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );

    if ( $r->header_in( 'Content-Length') ) {
        return (415);
    }
    elsif ( not defined $object->id() ) {
        my ($parentpath) = ( $path =~ m|^(.*)/[^/]+$| );
        my $parent = XIMS::Object->new( User => $user, path => $parentpath, marked_deleted => undef );
        return (409) unless (defined $parent and defined $parent->id());

        my $privmask = $user->object_privmask( $parent );
        return (403) unless $privmask & XIMS::Privileges::CREATE;

        my $importer = XIMS::Importer::Object->new( User => $user, Parent => $parent );
        my ($location) = ( $path =~ m|([^/]+)$| );
        my $folder = XIMS::Folder->new( User => $user, location => $location );
        if (not $importer->import( $folder )) {
            return (405);
        }
    }
    else {
        return (405);
    }
    return (201);
}

sub propfind {
    my $r = shift;
    my $user = shift;
    my $status_code;
    my $content;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404, undef) unless defined $object and defined $object->id();

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::VIEW;

    if ( $r->header_in('Content-Length') ) {
        $r->read( $content, $r->header_in( 'Content-Length') );
        my $p = XML::LibXML->new;
        eval {
            my $doc = $p->parse_string($content);
            warn "xml-in" . $content;
        };
        if ($@) {
            return (400, undef);
        }
    }

    # TODO: $doc is currently not checked, "allprop" is assumed

    $status_code = 207;
    $r->content_type( 'text/xml; charset="utf-8"' );

    my $dom = XML::LibXML::Document->new("1.0", "utf-8");
    my $multistatus = $dom->createElement("D:multistatus");
    $multistatus->setAttribute("xmlns:D", "DAV:");

    $dom->setDocumentElement($multistatus);

    my @objects;
    my $depth = $r->header_in('Depth');
    if ( not defined $depth or defined $depth and ($depth eq '1' or $depth eq 'infinity') ) {
        $depth = 1;
    }
    elsif ( defined $depth and $depth eq '0' ) {
        $depth = 0;
    }
    if ( $depth == 1 and $object->object_type->is_fs_container() ) {
        #my $p = $path;
        #$p .= '/' unless $p =~ m{/$};

        # filter out "special"-non-GETable object types like URLLink, Questionnaire, ...

        @objects = $object->children_granted( marked_deleted => undef );
        push @objects, $object;
    }
    else {
        @objects = ($object);
    }

    foreach my $o ( @objects ) {
        my $status = "HTTP/1.1 200 OK";
        my $t;

        my $nresponse = $dom->createElement("D:response");
        $nresponse->setAttribute("xmlns:lp1", "http://apache.org/dav/props/");
        $multistatus->addChild($nresponse);

        my $href = $dom->createElement("D:href");
        $href->appendText(XIMS::encode('/godav' . $o->location_path()) || '/' );
        $nresponse->addChild($href);

        my $propstat = $dom->createElement("D:propstat");
        $nresponse->addChild($propstat);

        my $prop = $dom->createElement("D:prop");
        $propstat->addChild($prop);

        $t = Time::Piece->strptime( $o->creation_timestamp(), "%d.%m.%Y %H:%M:%S" );
        my $creationdate = $dom->createElement("D:creationdate");
        $creationdate->appendText($t->strftime());
        #$creationdate->appendText($t->datetime());
        $prop->addChild($creationdate);

        $t = Time::Piece->strptime( $o->last_modification_timestamp(), "%d.%m.%Y %H:%M:%S" );
        my $getlastmodified = $dom->createElement("D:getlastmodified");
        $getlastmodified->appendText($t->strftime());
        #$getlastmodified->appendText($t->datetime());
        $prop->addChild($getlastmodified);

        my $size = $o->content_length();
        $size = "" if (defined $size and $size == 0);
        my $getcontentlength = $dom->createElement("D:getcontentlength");
        $getcontentlength->appendText($size);
        $prop->addChild($getcontentlength);

        my $ndisplayname = $dom->createElement("D:displayname");
        $ndisplayname->appendText(XIMS::encode($o->title()));
        $prop->addChild($ndisplayname);

        my $resourcetype = $dom->createElement("D:resourcetype");
        if ( $o->object_type->is_fs_container() ) {
            my $collection = $dom->createElement("D:collection");
            $resourcetype->addChild($collection);
        }
        $prop->addChild($resourcetype);

        # additional XIMS specific properties here?

        my $nstatus = $dom->createElement("D:status");
        $nstatus->appendText($status);
        $propstat->addChild($nstatus);

        my $getcontenttype = $dom->createElement("D:getcontenttype");
        if ( $o->object_type->is_fs_container() ) {
            $getcontenttype->appendText("httpd/unix-directory");
        }
        else {
            $getcontenttype->appendText($o->data_format->mime_type);
        }
        $propstat->addChild($getcontenttype);
    }

    return ($status_code, $dom->toString(1));
}

#sub lock {
#
#}
#
#sub unlock {
#
#}

1;

