
=head1 NAME

XIMS -- the XIMS base class.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS;

=head1 DESCRIPTION

This is The XIMS baseclass, it provides access to the configuration and the data provider.
It also defines a set of utility methods used throughout XIMS.

Always C<require> or C<use> this first in scripts or modules!

=head1 SUBROUTINES/METHODS

=cut

package XIMS;

use strict;
use XIMS::Config;
use Text::Iconv;
use Encode ();

our $AUTOLOAD;
our $VERSION = 1.2;
our $_CONFIG_;
our $_DATAPROVIDER_;
our $_OBJECT_TYPES_;
our $_DATA_FORMATS_;

BEGIN {
    $_CONFIG_ = XIMS::Config->new();

    require XIMS::DataProvider;
    my $dp = XIMS::DataProvider->new();
    $dp->driver->dbh->SQLLogging(0);

    my @df = $dp->data_formats();
    foreach my $df (@df) {
        $_DATA_FORMATS_->{ $df->id() } = $df;
    }

    my @ot = $dp->object_types();
    foreach my $ot (@ot) {
        $_OBJECT_TYPES_->{ $ot->id() } = $ot;
    }
    foreach my $ot ( values %$_OBJECT_TYPES_ ) {
        $ot->{fullname} = _getOTFullName( $ot, $_OBJECT_TYPES_ );
    }

    # internal helper for building up fullname of entry of
    # XIMS::OBJECT_TYPES

    ## no critic (ProhibitNestedSubs)

    sub _getOTFullName {
        my $ot       = shift;
        my $ots      = shift;
        my $fullname = shift;

        $fullname ||= $ot->{name};

        if ( defined $ot->{parent_id} ) {
            my $parent = $ots->{ $ot->{parent_id} };
            $fullname = $parent->{name} . '::' . $fullname;
            return _getOTFullName( $parent, $ots, $fullname );
        }
        else {
            return $fullname;
        }
    }

    ## use critic

}

require XIMS::DataProvider;
require XIMS::Privileges;
require XIMS::Privileges::System;

=head2 DATAPROVIDER

Returns a XIMS::DataProvider instance.

=cut

sub DATAPROVIDER {
    $_DATAPROVIDER_ ||= XIMS::DataProvider->new();
    return $_DATAPROVIDER_;
}

=head2 OBJECT_TYPES

Returns the list of object types.

=cut

sub OBJECT_TYPES { $_OBJECT_TYPES_ }

=head2 DATA_FORMATS

Returns the list of data formats.

=cut

sub DATA_FORMATS { $_DATA_FORMATS_ }

=head2 HOME

Returns the path to XIMS' root directory.

=cut

sub HOME {
    $ENV{'XIMS_HOME'} || '/usr/local/xims';
}

=head2 XIMS::Config wrappers

=over

=item GOXIMS

=item DEBUGLEVEL

=item PUBROOT_URL

=item PUBROOT

=item DEFAULT_SKIN

=item FALLBACKSTARTPATH

=item DEFAULTXHTMLEDITOR

=item XMLEDITOR

=item TIDYPATH

=item TIDYOPTIONS

=item XIMSROOT_URL

=item XIMSROOT

=item AUTHSTYLE

=item AUTHSERVER

=item PROXYIP

=item CONTENTINTERFACE

=item DBMS

=item QBDRIVER

=item DBDSN

=item DBENCODING

=item UIFALLBACKLANG

=item PUBLICUSERID

=item AUTOINDEXFILENAME

=item AUTOINDEXEXPORTSTYLESHEET

=item RESOLVERELTOSITEROOTS

=item SEARCHRESULTROWLIMIT

=item UILANGUAGES

=back

=cut

sub GOXIMS                    { return $_CONFIG_->goxims(); }

sub DEBUGLEVEL                { return $ENV{XIMSDEBUGLEVEL}
                                    || $_CONFIG_->DebugLevel();
}
sub PUBROOT_URL               { return "/" . $_CONFIG_->PublicRoot(); }

sub PUBROOT                   { return $_CONFIG_->ApacheDocumentRoot()
                                     . "/"
                                     . $_CONFIG_->PublicRoot();
}
sub DEFAULT_SKIN              { return $_CONFIG_->DefaultSkin(); }

sub FALLBACKSTARTPATH         { return $_CONFIG_->FallbackStartPath(); }

sub DEFAULTXHTMLEDITOR        { return $_CONFIG_->DefaultXHTMLEditor(); }

sub XMLEDITOR                 { return $_CONFIG_->XMLEditor(); }

sub TIDYPATH                  { return $_CONFIG_->TidyPath(); }

sub TIDYOPTIONS               { return $_CONFIG_->TidyOptions(); }

sub XIMSROOT_URL              { return "/" . $_CONFIG_->XIMSRoot(); }

sub XIMSROOT                  { return $_CONFIG_->ApacheDocumentRoot()
                                     . "/"
                                     . $_CONFIG_->XIMSRoot();
}

sub AUTHSTYLE                 { return $_CONFIG_->AuthStyle(); }

sub AUTHSERVER                { return $_CONFIG_->AuthServer(); }

sub PROXYIP                   { return $_CONFIG_->ProxyIP(); }

sub CONTENTINTERFACE          { return "/" . $_CONFIG_->ContentInterface(); }

sub DBMS                      { return $_CONFIG_->DBMS(); }

sub QBDRIVER                  { return $_CONFIG_->QBDriver(); }

sub DBDSN                     { return $_CONFIG_->DBdsn(); }

sub DBENCODING {
    (         defined $_CONFIG_->DBEncoding()
          and length $_CONFIG_->DBEncoding()
          and $_CONFIG_->DBEncoding() !~ /UTF-?8/i )
      ? return $_CONFIG_->DBEncoding()
      : return;
}

sub UIFALLBACKLANG            { return $_CONFIG_->UIFallbackLang(); }

sub PUBLICUSERID              { return $_CONFIG_->PublicUserID(); }

sub AUTOINDEXFILENAME         { return $_CONFIG_->AutoIndexFilename(); }

sub AUTOINDEXEXPORTSTYLESHEET { return $_CONFIG_->AutoindexExportStylesheet(); }

sub RESOLVERELTOSITEROOTS     { return $_CONFIG_->ResolveRelToSiteRoots(); }

sub SEARCHRESULTROWLIMIT      { return $_CONFIG_->SearchResultRowLimit(); }

sub UILANGUAGES {
    my %rv;
    foreach ( $_CONFIG_->UILanguages() ) {
        /^(\w{1,8})(?:-\w+)/;
        $rv{$_} = "\^$1\.\*";
    }
    return %rv;
}

# Provide access to custom config values using the XIMS::ConfigValueName
# interface
sub AUTOLOAD {
    my ( undef, $called_sub ) = ( $AUTOLOAD =~ /(.*)::(.*)/ );
    return if $called_sub eq 'DESTROY';
    return $_CONFIG_->$called_sub if $_CONFIG_->can($called_sub);
}

=head2 CONFIG

Provide access to the config itself.

=cut

sub CONFIG { return $_CONFIG_; }

#  Utility methods

=head2 Debug

=head3 Parameter

    $level: debuglevel
    @debug: message

=head3 Returns

    nothing

=head3 Description

    XIMS::Debug( $level, @debug )

If $level is below or equals the current threshold (XIMS::DEBUGLEVEL), print
the calling module, the method and @debug to Apache's F<error_log>

=cut

sub Debug {
    my $level = shift;
    if ( $level <= XIMS::DEBUGLEVEL() ) {
        if ( defined @_ and scalar(@_) == 1 ) {
            my @debug = @_;
            $debug[-1] =~ s/\n|\s+/ /g;
            my ( $module, $method );
            ( $module, undef, undef, $method ) = caller(1);
            if ( $ENV{MOD_PERL} and Apache->request ) {
                my $log = Apache->request->log();

                #$log->warn( "[Timed Interval] : "
                #           . int(1000 * Time::HiRes::tv_interval($XIMS::T0))
                #           . "ms" );
                $log->warn( "[$module, $method] " . join( '', @debug ) );
            }
            else {
                warn( "[$module, $method] " . join( '', @debug ) . "\n" );
            }
        }
    }
    return;
}

=head2 xml_escape

=head3 Parameter

    $text: string

=head3 Returns

    $text: escaped string

=head3 Description

    XIMS::xml_escape( $text )

XML-escape string.

=cut

sub xml_escape {
    my $text = shift;
    return unless defined $text;

    my %escapes = (
        '<'  => '&lt;',
        '>'  => '&gt;',
        '\'' => '&apos;',
        '&'  => '&amp;',
        '"'  => '&quot;',
    );

    $text =~ s/([<>\'&\"])
        /
        $escapes{$1}
        /egsx;

    return $text;
}

=head2 xml_unescape( $text )

=head3 Parameter

    $text: string

=head3 Returns

    $text: unescaped string

=head3 Description

    XIMS::xml_unescape( $text )

XML-unescape string.

=cut

sub xml_unescape {
    my $text = shift;
    return unless defined $text;

    my %escapes = (
        '&lt;'   => '<',
        '&gt;'   => '>',
        '&apos;' => '\'',
        '&amp;'  => '&',
        '&quot;' => '"',
    );

    $text =~ s/(&lt;|&gt;|&apos;|&amp;|&quot;)
        /
        $escapes{$1}
        /egsx;

    return $text;
}

=head2 xml_escape_noquot

=head3 Parameter

    $text: string

=head3 Returns

    $text: escaped string

=head3 Description

    XIMS::xml_escape_noquot( $text )

XML-escape string without escaping single- and doublequotes.

=cut

sub xml_escape_noquot {
    my $text = shift;
    return unless defined $text;

    my %escapes = (
        '<' => '&lt;',
        '>' => '&gt;',
        '&' => '&amp;',
    );

    $text =~ s/([<>&])
        /
        $escapes{$1}
        /egsx;

    return $text;
}

=head2 encode

=head3 Parameter

    $to_encode: string

=head3 Returns

    $encoded: string encoded from XIMS::DBENCODING to UTF-8

=head3 Description

    my $encoded = XIMS::encode( $to_encode )

Encodes a string from XIMS::DBENCODING to UTF-8

=cut

sub encode {
    my $string = shift;

    return $string unless XIMS::DBENCODING();

    my $converter = Text::Iconv->new( XIMS::DBENCODING(), "UTF-8" );
    $string = $converter->convert($string) if defined $string;

    return $string;
}

=head2 decode

=head3 Parameter

    $to_decode: string

=head3 Returns

    $decoded: string encoded from UTF-8 to XIMS::DBENCODING

=head3 Description

    my $decoded = XIMS::decode( $to_decode )

Decodes a string from UTF-8 to XIMS::DBENCODING.

=cut

sub decode {
    my $string = shift;

    return $string unless XIMS::DBENCODING();

    my $converter = Text::Iconv->new( "UTF-8", XIMS::DBENCODING() );
    $string = $converter->convert($string) if defined $string;

    return $string;
}

=head2 nodevalue

=head3 Parameter

    $node: XML::LibXML::Node instance

=head3 Returns

    $value: String value of node. If the node has child nodes, toString is
            called on them

=head3 Description

    my $value = XIMS::nodevalue( $node )

Returns a string value of a XML::LibXML::Node including potential child nodes

=cut

sub nodevalue {
    my $node = shift;

    if ( defined $node ) {
        my $value = "";
        if ( $node->hasChildNodes() ) {
            foreach ( $node->childNodes ) {
                $value .= $_->toString( 0, 1 );
            }
        }
        else {
            $value = $node->textContent();
        }
        if ( length $value ) {

# $value = XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$value) : $value;
            return $value;
        }
    }
}

=head2 trim

=head3 Parameter

    $string: string

=head3 Returns

    $trimmed: String with stripped leading and trailing whitespace

=head3 Description

    my $trimmed = XIMS::trim( $string )

Trims leading and trailing whitespace from a string

=cut

sub trim {
    my $string = shift;

    return unless $string;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

=head2 unquot

=head3 Parameter

    $string: string

=head3 Returns

    $unquotted: String with literal quotes.

=head3 Description

    my $unquotted = XIMS::unquot( $string )

Replace C<&apos;> and C<&quot;> entities with their literal values.

=cut

sub unquot {
    my $string = shift;

    return unless $string;

    $string =~ s/&apos;/'/g;
    $string =~ s/&quot;/"/g;

    return $string;
}

=head2 clean

=head3 Parameter

    $string: string

=head3 Returns

    $clean: Unquoted and trimmed string

=head3 Description

    my $clean = XIMS::clean( $string )

Unquots and trims a string.

=cut

sub clean {
    my $string = shift;

    return unless $string;

    $string = XIMS::unquot( XIMS::trim($string) );

    return $string;
}

=head2 escapewildcard

=head3 Parameter

    $string: string

=head3 Returns

    $escaped: String with SQL-escaped '%' strings.

=head3 Description

    my $escaped = XIMS::escapewildcard( $string )

SQL-escapes '%' inside a string by replacing them with '%%'.

=cut

sub escapewildcard {
    my $string = shift;

    return unless $string;

    $string =~ s/%/%%/g;

    return $string;
}

=head2  tokenize_string

=head3 Parameter

    $string: string

=head3 Returns

    $blocks: Array reference holding the string split spaces and honoring
             double quotes.

=head3 Description

    my $blocks = XIMS::tokenize_string( $string )

Tokenizes a string along spaces, while honoring double quotes.

=cut

sub tokenize_string {
    my $search = shift;
    my $retval = [];
    my @blocks = split( / *\" */, $search );

    # deal with quotes
    my $in_quote = 0;
    for my $part (@blocks) {
        if ( $in_quote == 0 ) {
            push( @{$retval}, split( ' ', $part ) ) if $part;
        }
        else {
            push( @{$retval}, $part ) if $part;
        }
        $in_quote = ++$in_quote % 2;
    }
    return $retval;
}



=head2 utf8_sanitize

=head3 Parameter

    $string: string

=head3 Returns

    $utf8_string: UTF-8 encoded string

=head3 Description

    my $utf8_string = XIMS::utf8_sanitize( $string )

Tests, whether input string is utf-8 or iso-8859-1 encoded and will utf-8
encode in case.

=cut

sub utf8_sanitize {
    my $string = shift;

    if ( defined XIMS::is_notutf8($string) ) {
        return Encode::decode_utf8( Encode::encode_utf8($string) );
    }
    else {
        Encode::_utf8_on($string);
        return $string;
    }
}



=head2 is_notutf8

=head3 Parameter

    $string: string

=head3 Returns

    $boolean: True if string is not utf-8 and false if it is utf-8 encoded

=head3 Description

    my $boolean = XIMS::is_notutf8( $string )

Tests whether a string is utf-8 encoded or not.

=cut

sub is_notutf8 {
    eval { Encode::decode_utf8( shift, 1 ); };
    return $@ ? 1 : undef;
}



=head2 is_known_proxy

=head3 Parameter

    $remote_host: IP-address.

=head3 Returns

    1 or nothing.

=head3 Description

    XIMS::is_known_proxy( $remote_host )

Compares the given IP-Adress to the configured known proxyservers. Returns 1
on success, nothing otherwise.

=cut

sub is_known_proxy {
    my $remote_host = shift;

    map { return 1 if defined $_ and $remote_host eq $_ } PROXYIP();

    return;
}



=head2 via_proxy_test

=head3 Parameter

    $r: Apache::Request object

=head3 Returns

    nothing

=head3 Description

    XIMS::via_proxy_test( $r )

If the Request appears to come from a known proxy, replace the IP-address with
the one from the X-Forwarded-For header, and flag the request in pnotes.

=cut

sub via_proxy_test {
    my $r = shift;

    if ( my ($ip) = $r->headers_in->{'X-Forwarded-For'} =~ /([^,\s]+)$/
        and is_known_proxy( $r->connection->remote_ip() ) )
    {
        $r->connection->remote_ip($ip);
        XIMS::Debug( 6, "Remote IP taken from X-Forwarded-For-header\n" );
    }
    $r->pnotes( 'PROXY_TEST' => 1 );

    return;
}

=head1 NAME

XIMS::Helpers

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Helpers;

=head1 DESCRIPTION

Some helpers that live in their own namespace.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Helpers;

=head2 privmask_to_hash( $privmask )

=head3 Parameter

    $privmask: integer bitmask.

=head3 Returns

    Returns a hash-reference with the corresponding XIMS::Privileges to
    $privmask as keys set to 1.

=head3 Description

Used, to get a more readable representation of the integer bitmask.

=cut

sub privmask_to_hash {
    my $privmask  = shift;
    my $privclass = shift;
    $privclass ||= '';

    ## no critic (ProhibitNoStrict)

    no strict 'refs';

    ## use critic

    my $listclass = "XIMS::Privileges::" . $privclass . "list";
    my %privs =
      map { ( lc($_), 1 ) }
      grep { $privmask & &{"XIMS::Privileges::$privclass$_"} } &{$listclass}();

    return \%privs;
}

=head2  system_privmask_to_hash

=head3 Parameter

    $privmask: integer bitmask

=head3 Returns

Returns a hash-reference with the corresponding XIMS::Privileges::System to
$privmask as keys set to 1.

=head3 Description

    system_privmask_to_hash( $privmask )

Used, to get a more readable representation of the integer bitmask.

=cut

sub system_privmask_to_hash { privmask_to_hash( shift, 'System::' ) }



=head2    dav_otprivmask_to_hash( $privmask, $object_types )

=head3 Parameter

    $privmask     : integer bitmask
    $object_types : Reference to array of XIMS::ObjectType instances

=head3 Returns

Returns a hash-reference with the corresponding DAV object type privileges as
keys set to 1.

=head3 Description

Used, to get a more readable representation of the integer bitmask.

=cut

sub dav_otprivmask_to_hash {
    my $privmask     = shift;
    my $object_types = shift;

    # cast $privmask to an integer, so that the bitwise operation will work as
    # expected.
    1 if $privmask == 1;

    my %privs =
      map { ( $_->name(), 1 ) }
      grep { $privmask & $_->davprivval() } @{$object_types};

    return \%privs;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

This module wraps access to F<ximsconfig.xml>: See also L<XIMS::Config>.

It also instantiates a XIMS::DataProvider, which, in turn, may be affected by
environment variables. (E. g., ORACLE_HOME)

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

