# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: godav.pm 1483 2006-04-23 21:46:59Z pepl $
package Apache::AxKit::Provider::XIMSGoPublic;

use strict;
use base qw(Apache::AxKit::Provider);
use Apache::URI;
use Apache::AxKit::Cache;
use LWP;
use XML::LibXML;
use Time::Piece;
use XIMS::Object;
use XIMS::User;

our $VERSION = '1.0';
our $publicuser = XIMS::User->new( id => XIMS::PUBLICUSERID() );

sub get_dom {
    my $self = shift;
    my $string;

    return $self->{dom} if defined $self->{dom};

    my $r = $self->{apache};    

    # 
    # TODO: subrequests for internal URIs
    #
    my $baseuri = $r->dir_config('ProxyObject');
    unless ( defined $baseuri ) {
        throw Apache::AxKit::Exception::Error( -text => "ProxyObject has to be configured." );
    }

    my $uri = $baseuri . $r->path_info();
    my $proxied_uri = Apache::URI->parse( $r, $uri );

    # Pass in the querystring
    my $args = $r->args();
    $proxied_uri->query( $args );

    # Prepare the request, pass in the request headers
    my $request = HTTP::Request->new( $r->method, $proxied_uri->unparse() );
    my (%headers_in) = $r->headers_in();
    while ( my ($key,$val) = each %headers_in ) {
        $request->header($key,$val);
    }

    # Append to X-Forwarded and Via headers for in case
    my $forwarded_for = $r->headers_in->{'X-Forwarded-For'};
    $forwarded_for .= ', '  if defined $forwarded_for;
    $forwarded_for .= $r->connection->remote_ip();
    #warn "Set X-Forwarded-For $forwarded_for";
    $request->header('X-Forwarded-For', $forwarded_for);
    
    my $via = $r->headers_in->{'Via'};
    $via .= ', '  if defined $via;
    my ($proto_version) = ( $r->protocol =~ m#HTTP/(.*)$# );
    $via .= "$proto_version " . $r->server->server_hostname . ":" . $r->get_server_port . " (XIMSGoPublic)";
    #warn "Set Via $via";
    $request->header('Via', $via);

    # Pass through POST content in case
    if ( $r->method eq 'POST' ) {
        $request->content( scalar $r->content );
    }

    my $ua = LWP::UserAgent->new();
    $ua->timeout( $r->dir_config('ProxyObjectTimeout') || 10 );
    push @{ $ua->requests_redirectable }, 'POST'; # anonforums do that - naughty
   
    my $response = $ua->request( $request );
    if ( $response->is_success() ) {
        $string = $response->content();
    }
    else {
        $r->status(502);
        throw Apache::AxKit::Exception::Error( -text => "Request to backend server failed." );
    }

    # Remove the Doctype declaration because XML::LibXML WILL validate despite validate set to 0
    $string =~ s#<!DOCTYPE.+?>##;

    # Replace absolute links
    my $requesturi = Apache::URI->parse( $r );
    $requesturi->query( undef );
    $requesturi->hostname( $r->header_in('X-Forwarded-Host') ) if length $r->header_in('X-Forwarded-Host');
    my $replacement = $requesturi->unparse();
    $replacement =~ s#/$##;

    my $tobereplaced = $baseuri;
    $tobereplaced =~ s#/$##;
    #warn "replacing $tobereplaced with $replacement inside href and action";
    $string =~ s/((href|action)=")$tobereplaced/$1 . $replacement/eg;

    # Replace relative links
    $replacement = $requesturi->path();
    $proxied_uri = Apache::URI->parse( $r, $baseuri );
    $tobereplaced = $proxied_uri->path();
    #warn "replacing $tobereplaced with $replacement inside href and action";
    $string =~ s/((href|action)=")$tobereplaced/$1 . $replacement/eg;

    # Replace relative links using content id redirect
    $replacement = $requesturi->path();
    #warn "replacing /gopublic/content?id= with $replacement";
    $string =~ s#href="/gopublic/content\?id=(\d+)"#'href="' . $replacement . '?id=' . $1 . '"'#eg;

    # Replace form actions
    $replacement = $requesturi->path();
    $tobereplaced = $proxied_uri->scheme() . '://' . $proxied_uri->hostname();
    $tobereplaced .= ':' . $proxied_uri->port() if defined $proxied_uri->port();
    $tobereplaced .= '/gopublic/content';
    #warn "replacing $tobereplaced with $replacement inside action";
    $string =~ s#action="$tobereplaced"#'action="' . $replacement . '"'#eg;


    my $parser = XML::LibXML->new();
    $parser->validation(0); # this does not work unfortunately with XML::LibXML 1.58
    $parser->load_ext_dtd(0);
    $parser->expand_xinclude(0);
    #$parser->expand_entities(0);
    #$parser->clean_namespaces( 1 ); only for libxml2.6.x

    my $dom;
    eval {
        $dom = $parser->parse_string($string);
    };
    if ($@) {
        throw Apache::AxKit::Exception::Error( -text => "Input must be well-formed XML: $@" );
    }

    # Pass through the response headers - now as we have a valid dom
    $r->content_type( $response->header('Content-type') );
    $r->status( $response->code() );
    $r->status_line( $response->status_line );
    my $table = $r->headers_out();
    $response->scan( sub {$table->add(@_);} );

    $self->{dom} = $dom; # save for later
    return $dom;
}

sub get_strref {
    my $self = shift;
    my $dom = $self->get_dom();
    return \ $dom->toString() if defined $dom;
}

sub process {
    my $self = shift;
    my $r = $self->{apache};

    # Since we are caching, only answer to GET, HEAD, and POST requests
    return 0 unless ( $r->method() eq 'GET' or $r->method() eq 'HEAD' or $r->method() eq 'POST' );
    # Do not cache POST requests
    if ( $r->method() eq 'POST' ) {
        $r->dir_config->set(AxNoCache => 1);
        $AxKit::Cache = Apache::AxKit::Cache->new($r, 'post', '', '', '');
    }

    my $location = $r->location();
    my $path_info = $r->path_info();
    my ($pseudo_path_info) = ( $location =~ m#^/[^/]+(/.+)$# );
    $path_info = substr($path_info,length($pseudo_path_info),length($path_info)) if defined $pseudo_path_info;
    $r->path_info($path_info); # set the real one

    # Only look up containers or html, xml files -> no binaries
    unless ( $path_info !~ m#\.# or $path_info =~ m#(\.html|\.xml)$# ) {
        return 0;
    }        

    # Look up the object to be proxied
    my $baseuri = $r->dir_config('ProxyObject');
    unless ( defined $baseuri ) {
        throw Apache::AxKit::Exception::Error( -text => "ProxyObject has to be configured." );
    }

    my $uri = $baseuri . $path_info;
    my ($ximspath) = ( $uri =~ m#/gopublic/content(.+)$# );
    #warn "looking up object $ximspath";
    return 0 unless defined $ximspath;

    # Fetch the object from the database
    my $object = XIMS::Object->new( User => $publicuser, path => $ximspath ); 
    return 0 unless defined $object and $object->published();

    $self->{object} = $object;
    
    return 1;
}

sub key {
    my ($self) = shift;
    return $self->apache_request->uri();
}

sub mtime {
    my $self = shift;

    # Invalidate cache in case of a POST request
    my $r = $self->{apache};
    return time() if $r->method() eq 'POST';

    my $object = $self->{object};
    return $self->{mtime}->{$object->id()} if defined $self->{mtime}->{$object->id()};

    # Get last publication timestamp of descendants, or from the current object if 
    # that timestamp is more recent
    my (undef, undef, $last_published) = $object->data_provider->get_descendant_infos( parent_id => $object->document_id() );
    my $t;
    if ( not defined $last_published ) {
        $last_published ||= $object->last_publication_timestamp();
        $t = Time::Piece->strptime( $last_published, "%Y-%m-%d %H:%M:%S" );
    }
    else {
        my $t1 = Time::Piece->strptime( $last_published, "%Y-%m-%d %H:%M:%S" );        
        my $t2 = Time::Piece->strptime( $object->last_publication_timestamp(), "%Y-%m-%d %H:%M:%S" );
        if ( $t2 > $t1 ) {
            $t = $t2;
        }
        else {
            $t = $t1;
        }
    }
    #warn "checking for " . $t->datetime;

    # Cache the timestamp since mtime() is called twice per request
    $self->{mtime}->{$object->id()} = $t->epoch;
    
    return $t->epoch();
}

sub exists {
    return 1;
}

sub get_fh {    
    throw Apache::AxKit::Exception::IO(
        -text => "not implemented"
   );
}

# Dummy
sub get_styles {
   my $self = shift;
   my ($pref_media, $pref_style) = @_;
   my @styles = (
       { type => 'text/xsl', href => 'NULL' },
   );
   return \@styles;
}
1;

__END__

=head1 NAME

Apache::AxKit::Provider::XIMSGoPublic - Proxy and cache XIMS objects that are
published via gopublic

=head1 DESCRIPTION

This module allows you to use proxy and cache XIMS objects through a XIMS server
via HTTP. Thus, enabling better performance and visible URLs for the published 
versions of these object types.
The AxKit Server acting as a proxy needs access to the XIMS database
vi the XIMS object API. GET requests will be cached by AxKit, POST requests will
not be cached.
Use this module for objects that are published using the XIMS 'gopublic' interface.
If you are configuring an object type, where it is not possible to determine the
last publication timestamp, like 'SQLReport' for example, make sure to set 
the 'AxNoCache' directive to on.
The 'ProxyObject' PerlVar needs to be set and point to the proxied XIMS object.
In the example in the SYNOPSIS below, it will point to an imaginary SimpleDB object
used as a simple staff data base.
Note that for customized output stylesheets of the XIMS objects, the output method
has to be set to XML since the proxy expects well-formed XML!

=head1 SYNOPSIS

<Location /people/staff>
    SetHandler axkit
    AxContentProvider Apache::AxKit::Provider::XIMSGoPublic
    AxIgnoreStylePI On
    AxAddPlugin Apache::AxKit::Plugin::QueryStringCache
    AxGzipOutput On
    AxResetProcessors
    AxResetPlugins
    AxResetStyleMap
    AxResetOutputTransformers
    AxAddStyleMap text/xsl Apache::AxKit::Language::Passthru
    PerlSetVar ProxyObject http://xims.acme.com/gopublic/content/acme.com/people/staff
    # Optional timeout on fetching the ProxyObject. Defaults to 10 seconds.
    PerlSetVar ProxyObjectTimeout 20
</Location>


=cut    

