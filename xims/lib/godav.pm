

=head1 NAME

godav -- XIMS' handler for WebDAV.

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
use URI::Escape; # for uri_unescape
use XML::LibXML;
#use Data::UUID;
use Digest::MD5;
use HTTP::Exception;
#use Data::Dumper::Concise;
use HTTP::Date;
use POSIX qw(setlocale LC_ALL);


=head2 handler()

=cut

sub handler {
    XIMS::Debug(5, "called");
    my $env = shift;

    my $method = lc( $env->{REQUEST_METHOD} );
    my $user   = $env->{'xims.appcontext'}->session->user();

    HTTP::Exception->throw(403) unless defined $user;

    setlocale( LC_ALL, 'C' ); # intl date formats

    unless ( $method eq 'put' or $method eq 'mkcol' ) {

        # Slurp in XML body of request (and ignore it for now...)
        my $ctt;
        if ( $env->{CONTENT_LENGTH} ) {
            $env->{'psgi.input'}->read( $ctt, $env->{CONTENT_LENGTH} );
            my $p = XML::LibXML->new;
            eval {
                my $doc = $p->parse_string($ctt);
                #warn "xml-in" . $ctt;
            };
            if ($@) {
                HTTP::Exception->throw(400);
            }
        }
    }

    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    ## no critic (ProhibitNoStrict)
    my $resp = &{$method}( $env, $user );

    push $resp->[1],
        (
        'X-Server'      => "XIMS::DAVServer $XIMS::VERSION",
        'MS-Author-Via' => 'DAV'
        );
    ##use critic

    #warn $env->{REQUEST_METHOD} . ' ' . $env->{REQUEST_URI} . "\n\n" . Dumper($resp)  . "\n\n";
    return $resp;
}

=head2 options()

=cut

sub options {
    XIMS::Debug(5, "called");
    # old comment ad DAV header: "2 is needed here if WebFolder connections should work"
    return [
        '200',
        [   'DAV' => '1, 2, <http://apache.org/dav/propset/fs/1>',
            'Allow' =>
                'OPTIONS, GET, HEAD, POST, DELETE, TRACE, PROPFIND, LOCK, UNLOCK, MOVE'
        ],
        [] 
    ];
}

=head2 proppatch()

=cut

sub proppatch {
    HTTP::Exception->throw(403);
}

=head2 get()

=cut

sub get {
    my ( $env, $user ) = @_;

    my $godav = $env->{SCRIPT_NAME};
    my $path  = _get_path($env);


    XIMS::Debug(5, "called: $path");

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );
    HTTP::Exception->throw(404) unless defined $object;

    my $privmask = $user->object_privmask($object);
    HTTP::Exception->throw(403) unless $privmask & XIMS::Privileges::VIEW;

    if ( $object->object_type->is_fs_container() ) {
        my @children = $object->children_granted(
            properties     => [ 'location', 'id', 'object_type_id' ],
            marked_deleted => 0
        );
        my $titling = $object->location_path;
        my $body = "<html>\n  <head><title>$titling</title></head>\n  <body>\n     <h2>$titling</h2>\n     <ul>\n";
        my $location;
        $path =~ s#/$##;
        foreach my $child (@children) {
            $location = $child->location();
            if ( $child->object_type->is_fs_container() ) {
                $body
                    .= qq|      <li><a href="$godav$path/$location/">$location/</a></li>\n|;
            }
            else {
               
               # URLLinks  
               if ($location =~ /^https?:/) {
                   $body .= qq|      <li><a href="$location">$location</a></li>\n|;
               }
               elsif ($location =~ /^\//) {
                   $body .= qq|      <li><a href="$godav$location">$location</a></li>\n|
               }
               else {
                   $location =~ s#/$##;
                   $body .= qq|      <li><a href="$godav$path/$location">$location</a></li>\n|;
               }
            }
        }
        $body .= "    </ul>\n    <hr noshade><em>XIMS WebDAV</em>\n  </body>\n</html>";
        return [ '200', [ 'Content-Type' => 'text/html', ], [$body] ];
    }
    else {
        my $mime_type =  $object->data_format->mime_type();

        if ($mime_type =~ /^text/ ) {
            return [
                200,
                [   'Content-Type' => "$mime_type; charset=UTF-8",
                    'Last-Modified' => time2str( str2time( $object->last_modification_timestamp(), 'CET') )
                ],
                [  Encode::encode('UTF-8', $object->body()) ]
            ];
        }
        else {
            return [
                200,
                [   'Content-Type' => $mime_type,
                    'Last-Modified' => time2str( str2time( $object->last_modification_timestamp(), 'CET') )
                ],
                [  $object->body() ]
            ];
        }
    }
}

=head2 post()

=cut

sub post {
    XIMS::Debug( 5, "called" );
    get(@_);
}

=head2 head()

=cut

sub head {
    XIMS::Debug( 5, "called" );
    get(@_);
}    # TODO

=head2 put()

=cut

sub put {
    my ( $env, $user ) = @_;

    my $path  = _get_path($env);
    my $godav = 'https://' . $env->{HTTP_HOST} . $env->{SCRIPT_NAME};

    XIMS::Debug( 5, "called: $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );

    my $body;
    $env->{'psgi.input'}->read( $body, $env->{'CONTENT_LENGTH'} );

    my $object_class;
    if ( defined $object ) {
        my $privmask = $user->object_privmask($object);
        HTTP::Exception->throw(403)
            unless $privmask & XIMS::Privileges::WRITE;

        # now that should be moved to run()....
        my $ot_fullname = $object->object_type->fullname();
        $object_class .= 'XIMS::' . $ot_fullname;
        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ($@) {
            XIMS::Debug( 3, "Cannot require $object_class." );
            HTTP::Exception->throw( 500,
                status_message => "Cannot require $object_class." );
        }
        ## use critic
        bless $object, $object_class;

        if ( $object->data_format->mime_type =~ /^text/ ) {

            # for those editors which did not get the encoding right...
            $body = XIMS::utf8_sanitize($body);
        }

        # update existing object
        if ( $object->body($body) ) {
            if ( $object->update() ) {
                return [ 201, ['Location' => $godav. $object->location_path()], [] ];
            }
            else {
                XIMS::Debug( 3,
                    "Cannot write body field into the database." );
                HTTP::Exception->throw( 500,
                    status_message =>
                        "Cannot write body field into the database." );
            }
        }
        else {
            XIMS::Debug( 3, "Cannot set the body field." );
            HTTP::Exception->throw( 500,
                status_message => "Cannot set the body field." );
        }
    }
    else {

        # create new object
        my $parentpath = $path;
        $parentpath =~ s#[^/]+$##;
        my $parent = XIMS::Object->new(
            User           => $user,
            path           => $parentpath,
            marked_deleted => 0
        );
        HTTP::Exception->throw(403)
            unless defined $parent and defined $parent->id();

        my $privmask = $user->object_privmask($parent);
        HTTP::Exception->throw(403)
            unless $privmask & XIMS::Privileges::CREATE;

        my $importer
            = XIMS::Importer::Object->new( User => $user, Parent => $parent );
        my ( $object_type, $data_format )
            = $importer->resolve_filename($path);

        # now that should be moved somewhere else....
        $object_class .= 'XIMS::' . $object_type->fullname;
        ## no critic (ProhibitStringyEval)
        # load the object class
        eval "require $object_class;" if $object_class;
        if ($@) {
            XIMS::Debug( 3, "Cannot require $object_class." );
            HTTP::Exception->throw( 500,
                status_message => "Cannot require $object_class." );
        }
        ## use critic
        my ($location) = ( $path =~ m|([^/]+)$| );
        $object = $object_class->new( User => $user, location => $location );
        $object->data_format_id( $data_format->id() ) if defined $data_format;

        if ( $object->data_format->mime_type =~ /^text/ ) {

            # for those editors which did not get the encoding right...
            $body = XIMS::utf8_sanitize($body);
        }

        $object->body($body);

        # Ignore location for temporary file creation of some
        # not-quite-DAV-aware applications
        my $id = $importer->import( $object, undef, _tmpsafe($location) );
        if ( defined $id ) {
            return [ 201, ['Location' => $godav. $object->location_path()], [] ];
        }
        else {
            XIMS::Debug( 3, "Import failed." );
            HTTP::Exception->throw( 500, status_message => "Import failed." );
        }
    }
    HTTP::Exception->throw( 500,
        status_message => "We shouldn’t have gotten here." );
}


=head2 delete()

=cut

sub delete {
    my ( $env, $user ) = @_;

    HTTP::Exception->throw(404) if $env->{REQUEST_URI} =~ m/#\w+/;

    my $path = _get_path($env);

    XIMS::Debug( 5, "called: $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );

    my $privmask = $user->object_privmask($object);
    HTTP::Exception->throw(403) unless $privmask & XIMS::Privileges::DELETE;

    my $status_code;
    if ( defined $object ) {
        if ( $object->published() ) {
            my $uri      = $env->{REQUEST_URI};
            my $response = <<EOS;
<?xml version="1.0" encoding="UTF-8"?>
<D:multistatus xmlns:D="DAV:">
    <D:response>
        <D:href>$uri</D:href>
        <D:status>HTTP/1.1 412 Precondition Failed</D:status>
        <D:responsedescription>Can not delete a published object.</D:responsedescription>
    </D:response>
</D:multistatus>
EOS
            return [
                '424',
                [ 'Content-Type' => 'application/xml; charset="UTF-8"' ],
                [$response]
            ];
        }

        if ( $object->locked() ) {
            my $uri      = $env->{REQUEST_URI};
            my $response = <<EOS;
<?xml version="1.0" encoding="UTF-8" ?>
<d:multistatus xmlns:D="DAV:">
    <D:response>
        <D:href>$uri</D:href>
        <D:status>HTTP/1.1 423 Locked</D:status>
    </D:response>
</D:multistatus>
EOS
            return [
                '207',
                [ 'Content-Type' => 'application/xml; charset="UTF-8"' ],
                [$response]
            ];
        }

        # honor Depth header here?
        if ( $object->trashcan() ) {
            return [ 204, [], [] ];    # 'No Content'
        }
        else {
            HTTP::Exception->throw(500);    # return 207 here instead
        }
    }
    else {
        HTTP::Exception->throw(404);
    }
}

=head2 copy()

=cut

sub copy {
    my ($env, $user) = @_;
    XIMS::Debug(5, "called");

    return copymove( $env, $user, 'COPY' );
}

=head2 move()

=cut

sub move {
    my ($env, $user) = @_;
    XIMS::Debug(5, "called");

    return copymove( $env, $user, 'MOVE' );
}

=head2 mkcol()

=cut

sub mkcol {
    my ( $env, $user ) = @_;

    my $path =  _get_path($env);
    $path    =~ s#/$##;
    my $godav = 'https://' . $env->{HTTP_HOST} . $env->{SCRIPT_NAME};

    XIMS::Debug( 5, "called: $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );

    if ( $env->{CONTENT_LENGTH} ) {
        HTTP::Exception->throw(415);
    }
    elsif ( not defined $object ) {
        my ($parentpath) = ( $path =~ m|^(.*)/[^/]+$| );
        my $parent = XIMS::Object->new(
            User           => $user,
            path           => $parentpath,
            marked_deleted => 0
        );
        HTTP::Exception->throw(409)
            unless ( defined $parent and defined $parent->id() );

        my $privmask = $user->object_privmask($parent);
        HTTP::Exception->throw(403)
            unless $privmask & XIMS::Privileges::CREATE;

        my $importer
            = XIMS::Importer::Object->new( User => $user, Parent => $parent );
        my ($location) = ( $path =~ m|([^/]+)$| );
        my $folder
            = XIMS::Folder->new( User => $user, location => $location );
        if ( not $importer->import($folder) ) {
            HTTP::Exception->throw(405);
        }
        return [ 201, ['Location' => $godav . $folder->location_path()], [] ];
    }
    else {
        HTTP::Exception->throw(405);
    }
}

=head2 propfind()

=cut

sub propfind {
    my ( $env, $user ) = @_;
    my $req = Plack::Request->new($env);

    my $path = _get_path($env);

    XIMS::Debug( 5, "called: $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );
    HTTP::Exception->throw(404) unless defined $object;

    my $privmask = $user->object_privmask($object);
    HTTP::Exception->throw(403)
        unless defined $privmask and ( $privmask & XIMS::Privileges::VIEW );

    # TODO: xml in $doc is currently not checked, "allprop" is assumed
    my $dom = XML::LibXML::Document->new( "1.0", "utf-8" );
    my $multistatus = $dom->createElementNS( 'DAV:', 'D:multistatus' );

    # For MS WebFolder compatibility
    $multistatus->setAttribute( "xmlns:b",
        "urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/" );

    $dom->setDocumentElement($multistatus);

    my @objects;
    my $depth = $req->header('Depth');
    if ( not defined $depth
        or defined $depth and ( $depth eq '1' or $depth eq 'infinity' ) )
    {
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
        for (@data_formats) {
            $mime_types{ $_->{id} } = $_->{mime_type};
        }

        my @object_types = $user->dav_object_types_granted();
        my @object_type_ids;
        for (@object_types) {
            push( @object_type_ids, $_->{id} );
            $is_fs_container{ $_->{id} }
                = $_->{is_fs_container};    # save db lookups later
        }
        @objects = $object->children_granted(
            marked_deleted => 0,
            object_type_id => \@object_type_ids
        );

        # do also provide requested object itself within the 207 response
        # (fixes gnomevfs/nautilus issue)
        push( @objects, $object );
    }
    else {
        @objects = ($object);
        $is_fs_container{ $object->{object_type_id} }
            = $object->object_type->{is_fs_container};
    }

    foreach my $o (@objects) {
        my $is_fs_container = $is_fs_container{ $o->object_type_id };
        my $status          = "HTTP/1.1 200 OK";
        my $t;

        my $nresponse = $dom->createElement("D:response");
        $nresponse->setAttribute( "xmlns:lp1",
            "http://apache.org/dav/props/" );
        $multistatus->addChild($nresponse);

        my $href       = $dom->createElement("D:href");
        my $href_value = ( $env->{SCRIPT_NAME} . $o->location_path() )
            || '/';

        # append '/' for collections
        if ( $is_fs_container && $href_value ne '/' ) {
            $href->appendText( $href_value . '/' );
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

        $t = Time::Piece->strptime( $o->creation_timestamp(),
            "%Y-%m-%d %H:%M:%S" );
        my $creationdate = $dom->createElement("D:creationdate");
        $creationdate->setAttribute( "b:dt", "dateTime.tz" );

        #$creationdate->appendText($t->datetime());
        $creationdate->appendText( $t->strftime("%Y-%m-%dT%T-00:00") )
            ;    # be IS8601 compliant
        $prop->addChild($creationdate);

        # put get* properties only for non-collections, as GET is unsupported
        # for collections
        if ( not $is_fs_container ) {
            my $getcontenttype = $dom->createElement("D:getcontenttype");
            my $mime_type
                = exists $mime_types{ $o->data_format_id }
                ? $mime_types{ $o->data_format_id }
                : $o->data_format->mime_type;
            $getcontenttype->appendText($mime_type);
            $prop->addChild($getcontenttype);

            $t = Time::Piece->strptime( $o->last_modification_timestamp(),
                "%Y-%m-%d %H:%M:%S" );
            my $getlastmodified = $dom->createElement("D:getlastmodified");
            $getlastmodified->setAttribute( "b:dt", "dateTime.rfc1123" );
            $getlastmodified->appendText(
                $t->strftime("%a, %d %b %Y %T GMT") )
                ;    # be RFC(2)822 compliant
            $prop->addChild($getlastmodified);

            my $size = $o->content_length();
            $size = "" if ( defined $size and $size == 0 );
            my $getcontentlength = $dom->createElement("D:getcontentlength");
            $getcontentlength->setAttribute( "b:dt", "int" );
            $getcontentlength->appendText($size);
            $prop->addChild($getcontentlength);
        }
        else {
            # we make our XIMS specific extension to 'prop'
            # <x:collectiontype xmlns:x="http://xims.info/webdav/collectiontype"/>
            # MS WebFolders get confused when adding our property to
            # 'ressourcetype' property ;-( so we add it here
            my $collection_type = $dom->createElement("x:collectiontype");
            $collection_type->setAttribute( "xmlns:x",
                "http://xims.info/webdav/collectiontype" );
            $collection_type->appendText("httpd/unix-directory");
            $prop->addChild($collection_type);
        }

        my $ndisplayname = $dom->createElement("D:displayname");

        my $displayname = $o->location();
        $displayname =~ s#/#_#g;
        $ndisplayname->appendText($displayname);
        $prop->addChild($ndisplayname);

        my $resourcetype = $dom->createElement("D:resourcetype");
        if ($is_fs_container) {
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
            $owner->appendText( $o->locker->name );
            $activelock->addChild($owner);

            my $timeout = $dom->createElement("D:timeout");
            $timeout->appendText('Infinite');
            $activelock->addChild($timeout);

            my $locktoken = $dom->createElement("D:locktoken");
            $activelock->addChild($locktoken);

            my $lthref = $dom->createElement("D:href");

            my $opaqelocktoken = 'opaquelocktoken:'
                . _pseudo_uuid($user);    #Data::UUID->new->create_str();
            $lthref->appendText($opaqelocktoken);
            $locktoken->addChild($lthref);
        }

        my $nstatus = $dom->createElement("D:status");
        $nstatus->appendText($status);

        # propstat expects only one single 'prop' and 'status' child element
        $propstat->addChild($nstatus);

    }

    return [
        '207',
        [ 'Content-Type' => 'application/xml; charset="UTF-8"' ],
        [ $dom->toString(1) ]
    ];
}

=head2 lock()

=cut

sub lock {
    my ( $env, $user ) = @_;
    my $req  = Plack::Request->new($env);
    my $path = _get_path($env);

    XIMS::Debug( 5, "called: $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );
    HTTP::Exception->throw(404) unless defined $object;

    my $privmask = $user->object_privmask($object);
    HTTP::Exception->throw(403) unless $privmask & XIMS::Privileges::WRITE;

    # We do not support a Depth header here...
    my $depth = $req->header('Depth');
    if ( defined $depth and $depth eq 'infinity' ) {
        HTTP::Exception->throw(412);
    }

    if ( not $object->lock() ) {
        XIMS::Debug( 2, "could not set lock" );
        HTTP::Exception->throw(412);
    }

    my $username = $user->name;

    my $locktoken = 'opaquelocktoken:'
        . _pseudo_uuid($user);    # Data::UUID->new->create_str();

    # Much less typing than creating the response string using DOM calls
    my $response = <<EOS;
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

    # MS-Office apps do not like a <D:timeout> value of 'Infinite', therefore
    # we pass a reasonable high timeout in seconds... [???]

    # Cadaver wants a Lock-Token header...
    return [
        '200',
        [   'Content-Type' => 'application/xml; charset="UTF-8"',
            'Lock-Token'   => "<$locktoken>",
        ],
        [$response]
    ];
}

=head2 unlock()

=cut

sub unlock {
    my ( $env, $user ) = @_;
    my $status_code;

    my $path = _get_path($env);

    XIMS::Debug( 5, "called: $path" );
    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );
    HTTP::Exception->throw(404) unless defined $object;

    my $privmask = $user->object_privmask($object);
    HTTP::Exception->throw(403) unless $privmask & XIMS::Privileges::WRITE;

    # Check if there is a lock and the lock has been set by the same user
    if (    $object->locked()
        and $object->locked_by_id() eq $user->id() )
    {
        if ( not $object->unlock() ) {
            XIMS::Debug( 2, "could remove lock" );
            HTTP::Exception->throw(412);
        }
        else {
            return [ 204, [], [] ];
        }
    }
    else {
        HTTP::Exception->throw(412);
    }
}

=head2 copymove()

=cut

sub copymove {
    my ( $env, $user, $method ) = @_;
    my $req   = Plack::Request->new($env);
    my $godav = 'https://' . $env->{HTTP_HOST} . $env->{SCRIPT_NAME};
    my $path  = _get_path($env);

    XIMS::Debug( 5, "called: $method $path" );

    my $object = XIMS::Object->new(
        User           => $user,
        path           => $path,
        marked_deleted => 0
    );
    HTTP::Exception->throw(404) unless defined $object;

    my $privmask = $user->object_privmask($object);
    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    HTTP::Exception->throw(403)
        unless $privmask & &{"XIMS::Privileges::$method"};
    use strict 'refs';
    ## use critic
    $method = lc $method;

    if ( $method eq 'move' and $object->published() ) {

        # Do not rename or move published objects
        HTTP::Exception->throw(412);
    }

    my $destination_path = Encode::decode( 'UTF-8', uri_unescape( $req->header('Destination') ) );
    $destination_path =~ s/^.*?$godav//;  # the cheap and pragmatic way to get the
    $destination_path =~ s#/$##;          # location_path

    my $depth     = $req->header('Depth');
    my $overwrite = $req->header('Overwrite');

    my $origlocation = $object->location;
    my $destination  = XIMS::Object->new(
        path           => $destination_path,
        marked_deleted => 0,
        User           => $user
    );
    if ( defined $destination ) {
        XIMS::Debug( 4, "Destination $destination_path exists" );

        # Cannot copy or move source to itself
        HTTP::Exception->throw(403) if ( $object->id eq $destination->id );

        # Do not copy or move locked objects
        HTTP::Exception->throw(423) if $destination->locked();

        # If the overwrite header is set to true, we overwrite the existing
        # object
        if ( defined $overwrite and $overwrite eq 'T' ) {
            $privmask = $user->object_privmask($destination);
            HTTP::Exception->throw(403)
                unless $privmask
                    and ( $privmask & XIMS::Privileges::DELETE() );
            if ( $destination->location ne $object->location ) {
                $privmask = $user->object_privmask($object);
                HTTP::Exception->throw(403)
                    unless $privmask
                        and ( $privmask & XIMS::Privileges::WRITE() );
            }
            my $privmask = $user->object_privmask( $destination->parent );
            HTTP::Exception->throw(403)
                unless $privmask & XIMS::Privileges::CREATE;

            $object->location( $destination->location() );
            if ($destination->trashcan()
                and $object->$method(
                    target => $destination->parent->document_id()
                )
                )
            {
                return [ 204, [], [] ];
            }
            else {
                XIMS::Debug( 3,
                    "$method failed, renaming source back to original location"
                );

                # Rename back
                $object->location($origlocation);
                $object->update( User => $user, no_modder => 1 );
                HTTP::Exception->throw(412);
            }
        }
        else {
            HTTP::Exception->throw(412);
        }
    }
    else {
        XIMS::Debug( 4, "Destination $destination_path does not exist yet" );
        my ( $destination_parentpath, $destination_location )
            = ( $destination_path =~ m#(.*)/(.*)# );
        my $destination = XIMS::Object->new(
            path           => $destination_parentpath,
            marked_deleted => 0,
            User           => $user
        );
        HTTP::Exception->throw(404) unless defined $destination;
        HTTP::Exception->throw(423) if $destination->locked();

        my $privmask = $user->object_privmask($destination);
        HTTP::Exception->throw(403)
            unless $privmask and ( $privmask & XIMS::Privileges::CREATE() );

        if ( $destination_location ne $object->location ) {
            $privmask = $user->object_privmask($object);
            HTTP::Exception->throw(403)
                unless $privmask
                    and ( $privmask & XIMS::Privileges::WRITE() );
            if ( $method eq 'move' ) {
                unless ( _tmpsafe($destination_location) ) {
                    $destination_location = XIMS::Importer::clean_location( 1,
                        $destination_location );
                }
                $object->location($destination_location);
                if (not
                    scalar $object->update( User => $user, no_modder => 1 ) )
                {
                    XIMS::Debug( 3,
                        "Could not rename to $destination_location" );
                    HTTP::Exception->throw(412);
                }
            }
        }
        my %args;
        if ( $method eq 'copy' ) {
            $args{target_location} = $destination_location;

            # Ignore location for temporary file creation of some
            # not-quite-DAV-aware applications
            $args{dontcleanlocation} = _tmpsafe($destination_location);
        }
        my $newobj;
        if ($newobj = $object->$method( target => $destination->document_id(), %args ) )
        {
            return [ 201, ['Location' => $godav . ($method eq 'copy' ? $newobj->location_path() : $object->location_path()) ], [] ];
        }
        else {
            XIMS::Debug( 3,
                "$method failed, renaming source back to original location" );

            # Rename back
            $object->location($origlocation);
            $object->update( User => $user, no_modder => 1 );
            HTTP::Exception->throw(412);
        }
    }
}

sub _pseudo_uuid {
    my $user = shift;

    # Instead of generating and storing a real Data::UUID per lock we
    # walk the poor man's path here..
    my $string = Digest::MD5::md5_hex( $user->id() );
    return
          substr( $string, 0, 8 ) . '-'
        . substr( $string, 9,  4 ) . '-'
        . substr( $string, 14, 4 ) . '-'
        . substr( $string, 18, 4 ) . '-'
        . substr( $string, 22, 10 )
        . substr( $string, 13, 2 );
}

sub _tmpsafe {
    my $location = shift;
    my $matched;
    my @tmpregexes = (
        qr/%7e$/,             # eldav does a "COPY $source $source%7e"
                              # when editing existing files
        qr/^~\$/,             # MS-Office-Apps if not in DAV-mode
                              # (eg using a NetDrive letter)
                              # A .tmp and an error message still will remain
                              # when saving, so please open the files
                              # via http://host/godav/path
        qr/^TMP\d+\.tmp$/,    # Textpad
        qr/^\.*\.swp$/,       # vi using DAVFS
    );

    # qr/~$/
    for (@tmpregexes) {
        $matched++ if $location =~ $_;
    }
    return $matched;
}

sub _get_path {
    my $path = uri_unescape( $_[0]->{PATH_INFO}) || '/';

    eval{
        $path = Encode::decode( 'UTF-8', $path, Encode::FB_CROAK );
    };
    if ($@) {
        HTTP::Exception->throw(400, status_message => "400 Bad Request\n\n$@.\n");
    }

    return $path;
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

