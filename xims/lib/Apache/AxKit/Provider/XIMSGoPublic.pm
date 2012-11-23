
=head1 NAME

Apache::AxKit::Provider::XIMSGoPublic -- Proxy and cache gopublic-published
XIMS objects.

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    AxContentProvider Apache::AxKit::Provider::XIMSGoPublic

=head1 DESCRIPTION

This AxKit ContentProvider allows you to proxy and cache objects coming from
XIMS' gopublic publishing mechanism; thus, enabling better performance and
visible URLs for the published versions of these.

The AxKit server acting as a proxy needs access to the XIMS database via the
XIMS object API. GET requests will be cached by AxKit, POST requests will not
be cached.

Note that for customized output stylesheets of the XIMS objects, the output
method has to be set to XML since the proxy expects well-formed XML!

=head1 SUBROUTINES/METHODS

Implements methods as outlined in L<Apache::AxKit::Provider>.

=cut

package Apache::AxKit::Provider::XIMSGoPublic;

use strict;
use parent qw(Apache::AxKit::Provider);
use Apache::URI;
use Apache::AxKit::Cache;
use LWP;
use XML::LibXML;
use Time::Piece;
use XIMS::Object;
use XIMS::User;

our $VERSION = '1.0';
our $publicuser = XIMS::User->new( id => XIMS::PUBLICUSERID() );

=head2 get_dom()

=cut

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
        throw Apache::AxKit::Exception::Error(
            -text => "ProxyObject has to be configured." );
    }

    # work around lost path_info part 1 of 2 :-/
    my $l = $r->location();
    my $p = $r->path_info();
    my $u = $r->uri();
    my $workaround = 0;

    unless ("$l$p" eq $u) {
        #warn "location: $l, path_info: $p, uri: $u\n";
        $u =~ s!$l!!;
        #warn "re-setting path_info to: $u\n";
        $r->path_info($u);
        $workaround = 1;
    }
    # end workaround part 1 of 2   

    my $uri = $baseuri . $r->path_info();
    my $proxied_uri = Apache::URI->parse( $r, $uri );

    # Pass in the querystring
    my $args = $r->args();
    $proxied_uri->query($args);

    # Prepare the request, pass in the request headers
    my $request = HTTP::Request->new( $r->method, $proxied_uri->unparse() );
    my (%headers_in) = $r->headers_in();
    while ( my ( $key, $val ) = each %headers_in ) {
        $request->header( $key, $val ) unless $key eq 'Host';
    }
    $request->header( 'Host', $proxied_uri->hostname() )
        ;    # Update the Host header

    # Append to X-Forwarded and Via headers for in case
    my $forwarded_for = $r->headers_in->{'X-Forwarded-For'};
    $forwarded_for .= ', ' if defined $forwarded_for;
    $forwarded_for .= $r->connection->remote_ip();

    #warn "Set X-Forwarded-For $forwarded_for";
    $request->header( 'X-Forwarded-For', $forwarded_for );

    my $via = $r->headers_in->{'Via'};
    $via .= ', ' if defined $via;
    my ($proto_version) = ( $r->protocol =~ m#HTTP/(.*)$# );
    $via .= "$proto_version "
        . $r->server->server_hostname . ":"
        . $r->get_server_port
        . " (XIMSGoPublic)";

    #warn "Set Via $via";
    $request->header( 'Via', $via );

    # Pass through POST content in case
    if ( $r->method eq 'POST' ) {
        $request->content( scalar $r->content );
    }

    my $ua = LWP::UserAgent->new();
    $ua->timeout( $r->dir_config('ProxyObjectTimeout') || 10 );
    push @{ $ua->requests_redirectable },
        'POST';    # anonforums do that - naughty

    my $response = $ua->request($request);
    if ( $response->is_success() ) {
        $string = $response->content();
    }
    else {
        $r->status(502);
        throw Apache::AxKit::Exception::Error(
            -text => "Request to backend server failed." );
    }

    # Remove the Doctype declaration before parsing because XML::LibXML WILL
    # validate despite validate set to 0 Add it back later after parsing...
    # :-|
    my ( $rootnode, $public, $system )
        = $string =~ /<!DOCTYPE\s+(\w+)\s+PUBLIC\s+"(.+)"\s+"(.+)">/;

    # warn "$rootnode, $public, $system";
    $string =~ s#<!DOCTYPE.+?>##;

    # Replace absolute links
    my $requesturi = Apache::URI->parse($r);
    $requesturi->query(undef);
    if ( length $r->header_in('X-Forwarded-Host') ) {
        $requesturi->hostname( $r->header_in('X-Forwarded-Host') );
    }

    $requesturi->path($r->location) if $workaround; # work around lost path_info part 2 of 2

    my $replacement = $requesturi->unparse();
    $replacement =~ s#/$##;

    my $tobereplaced = $baseuri;
    $tobereplaced =~ s#/$##;

    #warn "replacing $tobereplaced with $replacement inside href and action";
    $string =~ s/((href|action)=")$tobereplaced/$1 . $replacement/eg;

    # Replace relative links
    $replacement  = $requesturi->path();
    $proxied_uri  = Apache::URI->parse( $r, $baseuri );
    $tobereplaced = $proxied_uri->path();

    #warn "replacing $tobereplaced with $replacement inside href and action";
    $string =~ s/((href|action)=")$tobereplaced/$1 . $replacement/eg;

    # Replace relative links using content id redirect
    $replacement = $requesturi->path();

    #warn "replacing /gopublic/content?id= with $replacement";
    $string
        =~ s#href="/gopublic/content\?id=(\d+)"#'href="' . $replacement . '?id=' . $1 . '"'#eg;

    # Replace form actions
    $replacement  = $requesturi->path();
    $tobereplaced = $proxied_uri->scheme() . '://' . $proxied_uri->hostname();
    if ( defined $proxied_uri->port() ) {
        $tobereplaced .= ':' . $proxied_uri->port();
    }
    $tobereplaced .= '/gopublic/content';

    #warn "replacing $tobereplaced with $replacement inside action";
    $string =~ s#action="$tobereplaced"#'action="' . $replacement . '"'#eg;

    my $parser = XML::LibXML->new();
    $parser->validation(0);    # this does not work with XML::LibXML 1.58
    $parser->load_ext_dtd(0);
    $parser->expand_xinclude(0);

    #$parser->expand_entities(0);
    #$parser->clean_namespaces( 1 ); only for libxml2.6.x

    my $dom;
    eval { $dom = $parser->parse_string($string); };
    if ($@) {
        throw Apache::AxKit::Exception::Error(
            -text => "Input must be well-formed XML: $@" );
    }

    # Re-add the DTD line if there was one
    if ( defined $rootnode and defined $public and defined $system ) {
        my $dtd = $dom->createInternalSubset( $rootnode, $public, $system );
        $dom->setInternalSubset($dtd);
    }

    # Check if the content type should be overwritten (MSIE may need text/html)
    my $content_type = $r->dir_config('ProxyOutputContentType');
    $content_type ||= $response->header('Content-type');

    # Pass through the rest of the response headers - now as we have a valid dom
    $r->content_type( $content_type );
    $r->status( $response->code() );
    $r->status_line( $response->status_line );
    my $table = $r->headers_out();
    $response->scan( sub { $table->add(@_); } );

    $self->{dom} = $dom;    # save for later
    return $dom;
}

=head2 get_strref()

=cut

sub get_strref {
    my $self = shift;
    my $dom  = $self->get_dom();
    return \$dom->toString() if defined $dom;
}

=head2 process()

=cut

sub process {
    my $self = shift;
    my $r    = $self->{apache};

    # Since we are caching, only answer to GET, HEAD, and POST requests
    unless (   $r->method() eq 'GET'
            or $r->method() eq 'HEAD'
            or $r->method() eq 'POST'
        ) {
        return 0;
    }

    # Do not cache POST requests
    if ( $r->method() eq 'POST' ) {
        $r->dir_config->set( AxNoCache => 1 );
        $AxKit::Cache = Apache::AxKit::Cache->new( $r, 'post', '', '', '' );
    }

    my $location  = $r->location();
    my $path_info = $r->path_info();
    my ($pseudo_path_info) = ( $location =~ m#^/[^/]+(/.+)$# );
    if ( defined $pseudo_path_info ) {
        $path_info = substr( $path_info, length($pseudo_path_info),
            length($path_info) );
    }
    $r->path_info($path_info);    # set the real one

    # Only look up containers or html, xml files -> no binaries
    unless ( $path_info !~ m#\.# or $path_info =~ m#(\.html|\.xml)$# ) {
        return 0;
    }

    # Look up the object to be proxied
    my $baseuri = $r->dir_config('ProxyObject');
    unless ( defined $baseuri ) {
        throw Apache::AxKit::Exception::Error(
            -text => "ProxyObject has to be configured." );
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

=head2 key()

=cut

sub key {
    my ($self) = shift;
    return $self->apache_request->uri();
}

=head2 mtime()

=cut

sub mtime {
    my $self = shift;

    # Invalidate cache in case of a POST request
    my $r = $self->{apache};
    return time() if $r->method() eq 'POST';

    my $object = $self->{object};
    return $self->{mtime}->{ $object->id() }
        if defined $self->{mtime}->{ $object->id() };

    # Get the most recent publication timestamp of the object, its
    # descendants, or of the descendants of an assigned stylesheet directory
    my ( $last_published_desc, $last_published_style, $stylesheet );
    ( undef, undef, $last_published_desc )
        = $object->data_provider->get_descendant_infos(
        parent_id => $object->document_id() );
    $stylesheet = $object->stylesheet();
    if ( defined $stylesheet ) {
        ( undef, undef, $last_published_style )
            = $object->data_provider->get_descendant_infos(
            parent_id => $stylesheet->document_id() );
    }

    my @times = (
        Time::Piece->strptime(
            $object->last_publication_timestamp(),
            "%Y-%m-%d %H:%M:%S"
        )
    );
    if ( defined $last_published_desc ) {
        push(
            @times,
            Time::Piece->strptime(
                $last_published_desc, "%Y-%m-%d %H:%M:%S"
            )
        );
    }
    if ( defined $last_published_style ) {
        push(
            @times,
            Time::Piece->strptime(
                $last_published_style, "%Y-%m-%d %H:%M:%S"
            )
        );
    }

    my @sorted_times = sort { $a <=> $b } @times;
    my $latest = $sorted_times[-1];

    #warn "checking for " . $latest->datetime;

    # Time::Piece believes this to be UTC
    $latest -= localtime->tzoffset;

    # Cache the timestamp since mtime() is called twice per request
    $self->{mtime}->{ $object->id() } = $latest->epoch();

    return $latest->epoch();
}

=head2 exists()

=cut

sub exists {
    return 1;
}

=head2 get_fh()

=cut

sub get_fh {
    throw Apache::AxKit::Exception::IO( -text => "not implemented" );
}

# Dummy
sub get_styles {
    my $self = shift;
    my ( $pref_media, $pref_style ) = @_;
    my @styles = ( { type => 'text/xsl', href => 'NULL' }, );
    return \@styles;
}
1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Use this module for objects that are published using the XIMS `gopublic'
interface. If you are configuring an object type, where it is not possible to
determine the last publication timestamp, like `SQLReport' for example, make
sure to set the `AxNoCache' directive to 'on'.

The `ProxyObject' PerlVar needs to point and be set to the proxied XIMS
object. In the example below, it will point to an imaginary SimpleDB object
used as a simple staff data base.

in F<httpd.conf> or F<ximshttpd.conf>:

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
       # Mandatory: the object to cache:
       PerlSetVar ProxyObject http://xims.acme.com/gopublic/content/acme.com/people/staff
       # Optional timeout on fetching the ProxyObject. Defaults to 10 seconds.
       PerlSetVar ProxyObjectTimeout 20
       # Maybe the output content type should be overwritten (MSIE may need text/html)
       #PerlSetVar ProxyOutputContentType 'text/html; charset=utf-8'
 </Location>

=head1 DEPENDENCIES

mod_perl, XIMS and AxKit, obviously.

=head1 BUGS AND LIMITATION

The proxy expects well-formed XML and it doesn't fail exactly graceful on
this.

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


