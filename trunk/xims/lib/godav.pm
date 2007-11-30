

=head1 NAME

godav -- XIMS' mod_perl handler for WebDAV.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use godav;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package godav;

use strict;
use XIMS::Object;
use XIMS::Folder;
use XIMS::User;
use XIMS::Importer::Object;
use Encode;

use Apache;
use Apache::Constants qw(:common :response);
use Apache::File ();
use Apache::URI;
use URI::Escape;
use XML::LibXML;
use Time::Piece;
#use Data::UUID;
use Digest::MD5;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub handler {
    my $r = shift;

    XIMS::via_proxy_test($r) unless $r->pnotes('PROXY_TEST');
    XIMS::Debug( 5, "godav called from " .  $r->connection->remote_ip() );

    my $method = $r->method;
    my $path    = uri_unescape($r->uri);

    my $user =  $r->pnotes( 'ximsBasicAuthUser' );
    return (403) unless defined $user;

    $r->header_out( 'X-Server', 'XIMS::DAVServer ' . $VERSION );
    $r->header_out( 'MS-Author-Via', 'DAV' );

    #use Data::Dumper;
    #my %h = $r->headers_in();
    #warn Dumper \%h;
    #warn "This is a $method request";

    $method = lc $method;

    unless ( $method eq 'put' or $method eq 'mkcol' ) {
        # Slurp in XML body of request (and ignore it for now...)
        my $ctt;
        if ( $r->header_in('Content-Length') ) {
            $r->read( $ctt, $r->header_in( 'Content-Length') );
            my $p = XML::LibXML->new;
            eval {
                my $doc = $p->parse_string($ctt);
                #warn "xml-in" . $ctt;
            };
            if ($@) {
                return (400, undef);
            }
        }
    }
    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    my ($status_code, $content) = &{$method}( $r, $user );
    use strict 'refs';
    ## use critic
    #$r->header_out( 'Status', $status_code );
    $r->status( $status_code );
    if ( defined $content ) {
        my $bytes;
        do { use bytes; $bytes = length($content) };
        #$r->set_content_length( $bytes );
        #warn "Content-Length is $bytes";
        $r->header_out( 'Content-Length', $bytes );

        #$r->header_out( 'Content-Type', $r->content_type()); # hmmm
        #my %h = $r->headers_out();
        #use Data::Dumper;
        #warn Dumper \%h;
        #warn "$content" unless $method eq 'get';

        $r->send_http_header();
        $r->print( $content );
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

    $r->header_out( 'DAV', '1, 2, <http://apache.org/dav/propset/fs/1>' ); # 2 is needed here if WebFolder connections should work
    $r->header_out( 'Allow', 'OPTIONS, GET, HEAD, POST, DELETE, TRACE, PROPFIND, LOCK, UNLOCK, MOVE');
    return (200, undef);
}

sub proppatch {
    (403);
}

sub get {
    my $r = shift;
    my $user = shift;
    my $status_code;
    my $content;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404, undef) unless defined $object;

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::VIEW;

    if ( $object->object_type->is_fs_container() ) {
        my @children = $object->children_granted( properties => [ 'location', 'id', 'object_type_id' ], marked_deleted => undef );
        my $body;
        my $location;
        foreach my $child ( @children ) {
            $location = $child->location();
            if ( $child->object_type->is_fs_container() ) {
                $body .= qq|<a href="/godav$path/$location/">$location/</a><br>\n|;
            }
            else {
                $location =~ s{/$}{};
                $body .= qq|<a href="/godav$path/$location">$location</a><br>\n|;
            }
        }
        $r->content_type( 'text/html' );
        $content = $body;
        $status_code = 200;
    }
    else {
        my $charset;
        if (! ($charset = XIMS::DBENCODING )) { $charset = "UTF-8"; }
        $r->content_type( $object->data_format->mime_type() . "; charset=$charset" );
        $content = $object->body();
        my $t = Time::Piece->strptime( $object->last_modification_timestamp(), "%Y-%m-%d %H:%M:%S" );
        $r->set_last_modified( $t->epoch );
        $status_code = 200;
    }

    return ($status_code, $content);
}

sub post { get( @_ ) }
sub head { get( @_ ) } # TODO

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
    if ( defined $object ) {
        my $privmask = $user->object_privmask( $object );
        return (403) unless $privmask & XIMS::Privileges::WRITE;

        # now that should be moved to run()....
        my $ot_fullname = $object->object_type->fullname();
        $object_class .= 'XIMS::' . $ot_fullname;
        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ( $@ ) {
            $status_code = 500;
        }
        ## use critic
        bless $object, $object_class;

        if ( $object->data_format->mime_type =~ /^text/ ) {
            # for those editors which did not get the encoding right...
            $body = XIMS::utf8_sanitize( $body ) unless XIMS::DBENCODING();
        }

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
        my ($object_type, $data_format) = $importer->resolve_filename( $path );

        # now that should be moved somewhere else....
        $object_class .= 'XIMS::' . $object_type->fullname;
        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ( $@ ) {
            $status_code = 500;
        }
        ## use critic
        my ( $location ) = ( $path =~ m|([^/]+)$| );
        $object = $object_class->new( User => $user, location => $location );
        $object->data_format_id( $data_format->id() ) if defined $data_format;

        if ( $object->data_format->mime_type =~ /^text/ ) {
            # for those editors which did not get the encoding right...
            $body = XIMS::utf8_sanitize( $body ) unless XIMS::DBENCODING();
        }

        $object->body( $body );
        # Ignore location for temporary file creation of some not-quite-DAV-aware applications
        my $id = $importer->import( $object, undef, _tmpsafe($location) );
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

    if ( defined $object ) {
        if ( $object->published() ) {
            $r->content_type( 'application/xml; charset="UTF-8"' );
            my $uri = $r->uri;
            my $response =<<EOS;
<?xml version="1.0" encoding="UTF-8"?>
<D:multistatus xmlns:D="DAV:">
    <D:response>
        <D:href>$uri</D:href>
        <D:status>HTTP/1.1 412 Precondition Failed</D:status>
        <D:responsedescription>Can not delete a published object.</D:responsedescription>
    </D:response>
</D:multistatus>
EOS
            return (424, $response);
        }

        if ( $object->locked() ) {
            $r->content_type( 'application/xml; charset="UTF-8"' );
            my $uri = $r->uri;
            my $response =<<EOS;
<?xml version="1.0" encoding="UTF-8" ?>
<d:multistatus xmlns:D="DAV:">
    <D:response>
        <D:href>$uri</D:href>
        <D:status>HTTP/1.1 423 Locked</D:status>
    </D:response>
</D:multistatus>
EOS
            return (207, $response);
        }

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
    return copymove( $r, $user, 'COPY' );
}

sub move {
    my $r = shift;
    my $user = shift;
    return copymove( $r, $user, 'MOVE' );
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
    elsif ( not defined $object ) {
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

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404, undef) unless defined $object;

    my $privmask = $user->object_privmask( $object );
    return (403) unless defined $privmask and ($privmask & XIMS::Privileges::VIEW);

    # TODO: xml in $doc is currently not checked, "allprop" is assumed

    $status_code = 207;
    $r->content_type( 'application/xml; charset="UTF-8"' );

    my $dom = XML::LibXML::Document->new("1.0", "utf-8");
    my $multistatus =  $dom->createElementNS( 'DAV:', 'D:multistatus' );

    # For MS WebFolder compatibility
    $multistatus->setAttribute("xmlns:b", "urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/");

    $dom->setDocumentElement($multistatus);

    my @objects;
    my $depth = $r->header_in('Depth');
    if ( not defined $depth or defined $depth and ($depth eq '1' or $depth eq 'infinity') ) {
        $depth = 1;
    }
    elsif ( defined $depth and $depth eq '0' ) {
        $depth = 0;
    }

    my %is_fs_container;
    my %mime_types;
    if ( $depth == 1 and $object->object_type->is_fs_container() ) {
        # Build mime type lookup table
        my @data_formats = $object->data_provider->data_formats();
        for ( @data_formats ) {
            $mime_types{$_->{id}} = $_->{mime_type};
        }

        my @object_types = $user->dav_object_types_granted();
        my @object_type_ids;
        for ( @object_types ) {
            push (@object_type_ids, $_->{id});
            $is_fs_container{$_->{id}} = $_->{is_fs_container};  # save db lookups later
        }

        @objects = $object->children_granted( marked_deleted => undef, object_type_id => \@object_type_ids );
	# do also provide requested object itself within the 207 response (fixes gnomevfs/nautilus issue)
        push (@objects, $object);
    }
    else {
        @objects = ($object);
        $is_fs_container{$object->{object_type_id}} = $object->object_type->{is_fs_container};
    }

    foreach my $o ( @objects ) {
        my $is_fs_container = $is_fs_container{$o->object_type_id};
        my $status = "HTTP/1.1 200 OK";
        my $t;

        my $nresponse = $dom->createElement("D:response");
        $nresponse->setAttribute("xmlns:lp1", "http://apache.org/dav/props/");
        $multistatus->addChild($nresponse);

        my $href = $dom->createElement("D:href");
        my $href_value = ( XIMS::encode( '/godav' . $o->location_path()) ) || '/';
        # append '/' for collections
        if ( $is_fs_container && $href_value ne '/' ) {
            $href->appendText($href_value . '/');
        }
        else {
            $href->appendText($href_value);
        }
        $nresponse->addChild($href);

        my $propstat = $dom->createElement("D:propstat");
	# propstat expects only one single 'prop' and 'status' child element
        $nresponse->addChild($propstat);

        my $prop = $dom->createElement("D:prop");
        $propstat->addChild($prop);

        $t = Time::Piece->strptime( $o->creation_timestamp(), "%Y-%m-%d %H:%M:%S" );
        my $creationdate = $dom->createElement("D:creationdate");
        $creationdate->setAttribute("b:dt", "dateTime.tz");
        #$creationdate->appendText($t->datetime());
        $creationdate->appendText($t->strftime("%Y-%m-%dT%T -0000")); # be IS8601 compliant
        $prop->addChild($creationdate);

        # put get* properties only for non-collections, as GET is unsupported for collections
        if ( not $is_fs_container ) {
            my $getcontenttype = $dom->createElement("D:getcontenttype");
            my $mime_type = exists $mime_types{$o->data_format_id} ? $mime_types{$o->data_format_id} : $o->data_format->mime_type;
            $getcontenttype->appendText($mime_type);
            $prop->addChild($getcontenttype);

            $t = Time::Piece->strptime( $o->last_modification_timestamp(), "%Y-%m-%d %H:%M:%S" );
            my $getlastmodified = $dom->createElement("D:getlastmodified");
            $getlastmodified->setAttribute("b:dt", "dateTime.rfc1123");
            $getlastmodified->appendText($t->strftime("%a, %d %b %Y %T -0000")); # be RFC(2)822 compliant
            $prop->addChild($getlastmodified);

            my $size = $o->content_length();
            $size = "" if (defined $size and $size == 0);
            my $getcontentlength = $dom->createElement("D:getcontentlength");
            $getcontentlength->setAttribute("b:dt", "int");
            $getcontentlength->appendText($size);
            $prop->addChild($getcontentlength);
        }
        else {
            ## we make our XIMS specific extension to 'prop'
            # <x:collectiontype xmlns:x="http://xims.info/webdav/collectiontype"/>
            # MS WebFolders get confused when adding our property to 'ressourcetype' property ;-(
            # so we add it here
            my $collection_type = $dom->createElement("x:collectiontype");
            $collection_type->setAttribute("xmlns:x", "http://xims.info/webdav/collectiontype");
            $collection_type->appendText("httpd/unix-directory");
            $prop->addChild($collection_type);
        }

        my $ndisplayname = $dom->createElement("D:displayname");
        #my $displayname = XIMS::encode($o->title());
        my $displayname = $o->location();
        $displayname =~ s#/#_#g;
        $ndisplayname->appendText($displayname);
        $prop->addChild($ndisplayname);

        my $resourcetype = $dom->createElement("D:resourcetype");
        if ( $is_fs_container ) {
            my $collection = $dom->createElement("D:collection");
            $resourcetype->addChild($collection);
        }
        $prop->addChild($resourcetype);

        if ( $o->locked ) {
            my $lockdiscovery = $dom->createElement("D:lockdiscovery");
            $prop->addChild($lockdiscovery);

            my $activelock = $dom->createElement("D:activelock");
            $lockdiscovery->addChild($activelock);

            my $locktype = $dom->createElement("D:locktype");
            $activelock->addChild($locktype);

            my $write = $dom->createElement("D:write");
            $locktype->addChild($write);

            my $lockscope = $dom->createElement("D:lockscope");
            $activelock->addChild($lockscope);

            my $exclusive = $dom->createElement("D:exclusive");
            $lockscope->addChild($exclusive);

            my $depth = $dom->createElement("D:depth");
            $depth->appendText('0');
            $activelock->addChild($depth);

            my $owner = $dom->createElement("D:owner");
            $owner->appendText($o->locker->name);
            $activelock->addChild($owner);

            my $timeout = $dom->createElement("D:timeout");
            $timeout->appendText('Infinite');
            $activelock->addChild($timeout);

            my $locktoken = $dom->createElement("D:locktoken");
            $activelock->addChild($locktoken);

            my $lthref = $dom->createElement("D:href");

            my $opaqelocktoken = 'opaquelocktoken:' . _pseudo_uuid( $user ); #Data::UUID->new->create_str();
            $lthref->appendText($opaqelocktoken);
            $locktoken->addChild($lthref);
        }

        my $nstatus = $dom->createElement("D:status");
        $nstatus->appendText($status);
	# propstat expects only one single 'prop' and 'status' child element
        $propstat->addChild($nstatus);

    }

    return ($status_code, $dom->toString(1));
}

sub lock {
    my $r = shift;
    my $user = shift;
    my $status_code;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404, undef) unless defined $object;

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::WRITE;

    # We do not support a Depth header here...
    my $depth = $r->header_in('Depth');
    if ( defined $depth and $depth eq 'infinity' ) {
        return (412, undef);
    }

    if ( not $object->lock() ) {
        XIMS::Debug( 2, "could not set lock" );
        return (412, undef);
    }

    $status_code = 200;
    $r->content_type( 'application/xml; charset="UTF-8"' );

    my $username = $user->name;

    my $locktoken = 'opaquelocktoken:' . _pseudo_uuid( $user ); # Data::UUID->new->create_str();

    # Much less typing than creating the response string using DOM calls
    my $response =<<EOS;
<?xml version="1.0" encoding="utf-8" ?>
   <D:prop xmlns:D="DAV:">
     <D:lockdiscovery>
          <D:activelock>
               <D:locktype><D:write/></D:locktype>
               <D:lockscope><D:exclusive/></D:lockscope>
               <D:depth>0</D:depth>
               <D:owner>$username</D:owner>
               <D:timeout>Second-604800</D:timeout>
               <D:locktoken>
                    <D:href>$locktoken</D:href>
               </D:locktoken>
          </D:activelock>
     </D:lockdiscovery>
   </D:prop>
EOS
    # MS-Office apps do not like a <D:timeout> value of 'Infinite', therefore we pass
    # a reasonable high timeout in seconds...

    # Cadaver wants a Lock-Token header...
    $r->header_out( 'Lock-Token', "<$locktoken>" );

    return ($status_code, $response);
}

sub unlock {
    my $r = shift;
    my $user = shift;
    my $status_code;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404, undef) unless defined $object;

    my $privmask = $user->object_privmask( $object );
    return (403) unless $privmask & XIMS::Privileges::WRITE;

    # Check if there is a lock and the lock has been set by the same user
    if ( $object->locked() and
         $object->locked_by_id() eq $user->id() ) {
        if ( not $object->unlock() ) {
            XIMS::Debug( 2, "could not set lock" );
            return (412, undef);
        }
        else {
            return (204, undef);
        }
    }
    else {
        return (412, undef);
    }
}

sub copymove {
    my $r = shift;
    my $user = shift;
    my $method = shift;

    my $path = uri_unescape( $r->path_info() );
    $path ||= '/';
    my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => undef );
    return (404) unless defined $object;

    my $privmask = $user->object_privmask( $object );
    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    return (403) unless $privmask & &{"XIMS::Privileges::$method"};
    use strict 'refs';
    ## use critic
    $method = lc $method;

    if ( $method eq 'move' and $object->published() ) {
        # Do not rename or move published objects
        return (412);
    }

    my $destination_path = $r->header_in( 'Destination' );
    $destination_path =~ s/^.*?\/godav//; # the cheap and pragmatic way to get the location_path
    $destination_path =~ s#/$##; # the cheap and pragmatic way to get the location_path

    my $depth = $r->header_in( 'Depth' );
    my $overwrite = $r->header_in( 'Overwrite' );

    my $origlocation = $object->location;
    my $destination = XIMS::Object->new( path => $destination_path, marked_deleted => undef, User => $user );
    if ( defined $destination ) {
        XIMS::Debug( 4, "Destination $destination_path exists" );

        # Cannot copy or move source to itself
        return (403) if ($object->id eq $destination->id);

        # Do not copy or move locked objects
        return (423) if $destination->locked();

        # If the overwrite header is set to true, we overwrite the existing object
        if ( defined $overwrite and $overwrite eq 'T' ) {
            $privmask = $user->object_privmask( $destination );
            return (403) unless $privmask and ($privmask & XIMS::Privileges::DELETE());
            if ( $destination->location ne $object->location ) {
                $privmask = $user->object_privmask( $object );
                return (403) unless $privmask and ($privmask & XIMS::Privileges::WRITE());
            }
            my $privmask = $user->object_privmask( $destination->parent );
            return (403) unless $privmask & XIMS::Privileges::CREATE;

            $object->location( $destination->location() );
            if ( $destination->trashcan() and $object->$method( target => $destination->parent->document_id() ) ) {
                return (204);
            }
            else {
                XIMS::Debug( 3, "$method failed, renaming source back to original location" );
                # Rename back
                $object->location( $origlocation );
                $object->update( User => $user, no_modder => 1 );
                return (412);
            }
        }
        else {
            return (412);
        }
    }
    else {
        XIMS::Debug( 4, "Destination $destination_path does not exist yet" );
        my ($destination_parentpath, $destination_location) = ($destination_path =~ m#(.*)/(.*)#);
        my $destination = XIMS::Object->new( path => $destination_parentpath, marked_deleted => undef, User => $user );
        return (404) unless defined $destination;
        return (423) if $destination->locked();

        my $privmask = $user->object_privmask( $destination );
        return (403) unless $privmask and ($privmask & XIMS::Privileges::CREATE());

        if ( $destination_location ne $object->location ) {
            $privmask = $user->object_privmask( $object );
            return (403) unless $privmask and ($privmask & XIMS::Privileges::WRITE());
            if ( $method eq 'move' ) {
                unless ( _tmpsafe($destination_location) ) {
                    $destination_location = XIMS::Importer::clean_location( 1, $destination_location );
                }
                $object->location( $destination_location );
                if ( not scalar $object->update( User => $user, no_modder => 1 ) ) {
                    XIMS::Debug( 3, "Could not rename to $destination_location" );
                    return (412);
                }
            }
        }
        my %args;
        if ( $method eq 'copy' ) {
            $args{target_location} = $destination_location;
            # Ignore location for temporary file creation of some not-quite-DAV-aware applications
            $args{dontcleanlocation} = _tmpsafe($destination_location);
        }

        if ( $object->$method( target => $destination->document_id(), %args ) ) {
            return (201);
        }
        else {
            XIMS::Debug( 3, "$method failed, renaming source back to original location" );
            # Rename back
            $object->location( $origlocation );
            $object->update( User => $user, no_modder => 1 );
            return (412);
        }
    }
}

sub _pseudo_uuid {
    my $user = shift;
    # Instead of generating and storing a real Data::UUID per lock we
    # walk the poor man's path here..
    my $string = Digest::MD5::md5_hex( $user->id() );
    return substr($string,0,8).'-'.substr($string,9,4).'-'.substr($string,14,4).'-'.substr($string,18,4).'-'.substr($string,22,10).substr($string,13,2);
}

sub _tmpsafe {
    my $location = shift;
    my $matched;
    my @tmpregexes = ( qr/%7e$/,  # eldav does a "COPY $source $source%7e"
                                  # when editing existing files
                       qr/^~\$/,  # MS-Office-Apps if not in DAV-mode
                                  # (eg using a NetDrive letter)
                                  # A .tmp and an error message still will remain
                                  # when saving, so please open the files
                                  # via http://host/godav/path
                       qr/^TMP\d+\.tmp$/, # Textpad
                       qr/^\.*\.swp$/, # vi using DAVFS
                    );
    # qr/~$/
    for ( @tmpregexes ) {
        $matched++ if $location =~ $_;
    }
    return $matched;
}

1;


__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

This module has beta status. All Litmus tests besides some of the props tests
do pass.

This DAV handler has been tested with cadaver, konqueror, Webdrive, Novell's
Netdrive DAV client software and MS WebFolders

Body-less or dynamic object types like URLLink or Questionnaire are filtered
out.

It is not possible to rename/move or delete published objects.

Under Windows: Do not create objects with Explorer using the right mouse
button. "New Text Document.txt" will be created as "new_text_document.txt" and
not found again right away...

http://host/godav/xims/

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 TODO

=over

=item *

Add acceptance tests (HTTP::DAV)

=item *

Add documentation with nice screenshots

=item *

PROPPATCH?

=back

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

