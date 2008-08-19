# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS;

use strict;
use XIMS::Config;
use Text::Iconv;
use Encode ();

our $AUTOLOAD;
our $VERSION = 1.1;
our $_CONFIG_ = XIMS::Config->new();
our $_DATAPROVIDER_;

require XIMS::DataProvider;
sub DATAPROVIDER {
    $_DATAPROVIDER_ ||= XIMS::DataProvider->new();
    return $_DATAPROVIDER_;
}

sub HOME {
    $ENV{'XIMS_HOME'} || '/usr/local/xims'
}

# XIMS::Config wrappers
sub GOXIMS()                    { $_CONFIG_->goxims() }
sub DEBUGLEVEL()                { $ENV{XIMSDEBUGLEVEL} || $_CONFIG_->DebugLevel() }
sub PUBROOT_URL()               { "/" . $_CONFIG_->PublicRoot() }
sub PUBROOT()                   { $_CONFIG_->ApacheDocumentRoot() . "/" . $_CONFIG_->PublicRoot()  }
sub DEFAULT_SKIN()              { $_CONFIG_->DefaultSkin() }
sub FALLBACKSTARTPATH()         { $_CONFIG_->FallbackStartPath() }
sub DEFAULTXHTMLEDITOR()        { $_CONFIG_->DefaultXHTMLEditor() }
sub XMLEDITOR()                 { $_CONFIG_->XMLEditor() }
sub TIDYPATH()                  { $_CONFIG_->TidyPath() }
sub TIDYOPTIONS()               { $_CONFIG_->TidyOptions() }
sub XIMSROOT_URL()              { "/" . $_CONFIG_->XIMSRoot() }
sub XIMSROOT()                  { $_CONFIG_->ApacheDocumentRoot() . "/" . $_CONFIG_->XIMSRoot() }
sub AUTHSTYLE()                 { $_CONFIG_->AuthStyle() }
sub AUTHSERVER()                { $_CONFIG_->AuthServer() }
sub PROXYIP()                   { $_CONFIG_->ProxyIP() }
sub CONTENTINTERFACE()          { "/" . $_CONFIG_->ContentInterface() }
sub DBMS()                      { $_CONFIG_->DBMS() }
sub QBDRIVER()                  { $_CONFIG_->QBDriver() }
sub DBUSER()                    { $_CONFIG_->DBUser() }
sub DBPWD()                     { $_CONFIG_->DBPassword() }
sub DBSESSIONOPT()              { $_CONFIG_->DBSessionOpt() }
sub DBDOPT()                    { $_CONFIG_->DBDOpt() }
sub DBDSN()                     { $_CONFIG_->DBdsn() }
sub DBENCODING()                { (defined $_CONFIG_->DBEncoding() and length $_CONFIG_->DBEncoding() and $_CONFIG_->DBEncoding() !~ /UTF-?8/i) ? return $_CONFIG_->DBEncoding() : return undef }
sub UIFALLBACKLANG()            { $_CONFIG_->UIFallbackLang() }
sub PUBLICUSERID()              { $_CONFIG_->PublicUserID() }
sub AUTOINDEXFILENAME()         { $_CONFIG_->AutoIndexFilename() }
sub AUTOINDEXEXPORTSTYLESHEET() { $_CONFIG_->AutoindexExportStylesheet() }
sub RESOLVERELTOSITEROOTS()     { $_CONFIG_->ResolveRelToSiteRoots() }
sub SEARCHRESULTROWLIMIT()      { $_CONFIG_->SearchResultRowLimit() }
sub UILANGUAGES() {
    my %rv;
    foreach ( $_CONFIG_->UILanguages() ) {
        /^(\w{1,8})(?:-\w+)/;
        $rv{$_} = "\^$1\.\*";
    }
    return %rv;
}

# Provide access to custom config values using the XIMS::ConfigValueName interface
sub AUTOLOAD {
    my (undef, $called_sub) = ($AUTOLOAD =~ /(.*)::(.*)/);
    return if $called_sub eq 'DESTROY';
    return $_CONFIG_->$called_sub if $_CONFIG_->can($called_sub);
}

# Provide access to the config itself
sub CONFIG {
    return $_CONFIG_;
}

#  Utility methods

##
#
# SYNOPSIS
#    XIMS::Debug( $level, @debug )
#
# PARAMETER
#    $level: debuglevel
#    @debug: message
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    checks if $level is below or equal to the current threshold (XIMS::DEBUGLEVEL)
#    and if so, the calling module, method and @debug are passed to Apache's errorlog
#
sub Debug {
    my $level = shift;
    if ($level <= XIMS::DEBUGLEVEL() ) {
        if ( defined @_ and scalar(@_) == 1 ) {
            my @debug = @_;
            $debug[-1] =~ s/\n|\s+/ /g;
            my ( $module, $method ) ;
            ($module, undef, undef, $method) = caller(1);
            if ( $ENV{MOD_PERL} and Apache->request ) {
                my $log = Apache->request->log();
                #$log->warn( "[Timed Interval] : " . int(1000 * Time::HiRes::tv_interval($XIMS::T0)) . "ms" );
                $log->warn("[$module, $method] " . join('', @debug));
            }
            else {
                warn("[$module, $method] " . join('', @debug) ."\n");
            }
        }
    }
}

##
#
# SYNOPSIS
#    XIMS::xml_escape( $text )
#
# PARAMETER
#    $text: string
#
# RETURNS
#    $text: escaped string
#
# DESCRIPTION
#    xml-escape string
#
sub xml_escape {
    my $text = shift;

    my %escapes = (
                   '<' => '&lt;',
                   '>' => '&gt;',
                   '\'' => '&apos;',
                   '&' => '&amp;',
                   '"' => '&quot;',
                  );

    $text =~ s/([<>\'&\"])
        /
        $escapes{$1}
        /egsx;

    return $text;
}

##
#
# SYNOPSIS
#    XIMS::xml_unescape( $text )
#
# PARAMETER
#    $text: string
#
# RETURNS
#    $text: unescaped string
#
# DESCRIPTION
#    xml-unescape string
#
sub xml_unescape {
    my $text = shift;

    my %escapes = (
                   '&lt;' => '<',
                   '&gt;' => '>',
                   '&apos;' => '\'',
                   '&amp;' => '&',
                   '&quot;' => '"',
                  );

    $text =~ s/(&lt;|&gt;|&apos;|&amp;|&quot;)
        /
        $escapes{$1}
        /egsx;

    return $text;
}

##
#
# SYNOPSIS
#    XIMS::xml_escape_noquot( $text )
#
# PARAMETER
#    $text: string
#
# RETURNS
#    $text: escaped string
#
# DESCRIPTION
#    xml-escape string without escaping single- and doublequotes
#
sub xml_escape_noquot {
    my $text = shift;

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

##
#
# SYNOPSIS
#    my $encoded = XIMS::encode( $to_encode )
#
# PARAMETER
#    $to_encode: string
#
# RETURNS
#    $encoded: string encoded from XIMS::DBENCODING to UTF-8
#
# DESCRIPTION
#    Encodes a string from XIMS::DBENCODING to UTF-8
#
sub encode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( XIMS::DBENCODING(), "UTF-8" );
    $string = $converter->convert($string) if defined $string;
    return $string;
}


##
#
# SYNOPSIS
#    my $decoded = XIMS::decode( $to_decode )
#
# PARAMETER
#    $to_decode: string
#
# RETURNS
#    $decoded: string encoded from UTF-8 to XIMS::DBENCODING
#
# DESCRIPTION
#    Decodes a string from UTF-8 to XIMS::DBENCODING
#
sub decode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( "UTF-8", XIMS::DBENCODING() );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

##
#
# SYNOPSIS
#    my $value = XIMS::nodevalue( $node )
#
# PARAMETER
#    $node: XML::LibXML::Node instance
#
# RETURNS
#    $value: String value of node. If the node has child nodes, toString is called on them
#
# DESCRIPTION
#    Returns a string value of a XML::LibXML::Node including potential child nodes
#
sub nodevalue {
    my $node = shift;

    if ( defined $node ) {
        my $value = "";
        if ( $node->hasChildNodes() ) {
            map { $value .= $_->toString(0,1) } $node->childNodes;
        }
        else {
            $value = $node->textContent();
        }
        if ( length $value ) {
#            $value = XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$value) : $value;
            return $value;
        }
    }
}

##
#
# SYNOPSIS
#    my $trimmed = XIMS::trim( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $trimmed: String with stripped leading and trailing whitespace
#
# DESCRIPTION
#    Trims leading and trailing whitespace from a string
#
sub trim {
    my $string = shift;

    return undef unless $string;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

##
#
# SYNOPSIS
#    my $unquotted = XIMS::unquot( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $unquotted: String with literal quotes
#
# DESCRIPTION
#    Converts apos and quot entities to its string literal values inside a string
#
sub unquot {
    my $string = shift;

    return undef unless $string;

    $string =~ s/&apos;/'/g;
    $string =~ s/&quot;/"/g;

    return $string;
}

##
#
# SYNOPSIS
#    my $clean = XIMS::clean( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $clean: Unquoted and trimmed string
#
# DESCRIPTION
#    Unquots and trims a string
#
sub clean {
    my $string = shift;

    return undef unless $string;

    $string = XIMS::unquot( XIMS::trim( $string ) );

    return $string;
}

##
#
# SYNOPSIS
#    my $escaped = XIMS::escapewildcard( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $escaped: String with SQL-escaped '%' strings
#
# DESCRIPTION
#    SQL-escapes '%' inside a string by replacing them with '%%'
#
sub escapewildcard {
    my $string = shift;

    return undef unless $string;
    $string =~ s/%/%%/g;

    return $string;
}

##
#
# SYNOPSIS
#    my $utf8_string = XIMS::utf8_sanitize( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $utf8_string: UTF-8 encoded string
#
# DESCRIPTION
#    Tests, whether input string is utf-8 or iso-8859-1 encoded and will utf-8 encode in case
#
sub utf8_sanitize {
    my $string = shift;
    if ( defined XIMS::is_notutf8( $string ) ) {
        return Encode::decode_utf8(Encode::encode_utf8($string));
    }
    else {
        Encode::_utf8_on( $string );
        return $string;
    }
}

##
#
# SYNOPSIS
#    my $boolean = XIMS::is_notutf8( $string )
#
# PARAMETER
#    $string: string
#
# RETURNS
#    $boolean: True if string is not utf-8 and false if it is utf-8 encoded
#
# DESCRIPTION
#    Tests whether a string is utf-8 encoded or not.
#
sub is_notutf8 {
    eval { Encode::decode_utf8(shift,1); };
    return $@ ? 1 : undef;
}


##
#
# SYNOPSIS
#    XIMS::is_known_proxy( $remote_host )
#
# PARAMETER
#    $remote_host: IP-Adress
#
# RETURNS
#    1 or undef
#
# DESCRIPTION
#    Compares the given IP-Adress to the configured known proxyservers.
#    Returns 1 on success, undef otherwise.
#
sub is_known_proxy($) {
    my $remote_host = shift;

    map {return 1 if defined $_ and $remote_host eq $_} PROXYIP();

    return undef;
}

##
#
# SYNOPSIS
#    XIMS::via_proxy_test( $r )
#
# PARAMETER
#    $r: Apache::Request object
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    If the Request appears to come from a known proxy, replace
#    the IP-adress with the one from the X-Forwarded-For header,
#    and flag the request in pnotes.
#
sub via_proxy_test($){
    my $r = shift;

    if ( my ($ip) = $r->headers_in->{'X-Forwarded-For'} =~ /([^,\s]+)$/
         and is_known_proxy($r->connection->remote_ip()) ) {
        $r->connection->remote_ip($ip);
        XIMS::Debug(6, "Remote IP taken from X-Forwarded-For-header\n");
    }
    $r->pnotes('PROXY_TEST' => 1);
}


# ##########################################################################
# Package XIMS::Privileges

package XIMS::Privileges;
#
# this package defines all privilege methods!
#
sub list {
    #
    # example usage:
    #
    #{
    #  no strict 'refs';
    #  for (XIMS::Privileges::list()) {
    #   print $_ . ": " . &{"XIMS::Privileges::$_"} . "\n";
    #  }
    #}
    #
    return qw(DENIED VIEW WRITE DELETE PUBLISH ATTRIBUTES TRANSLATE CREATE MOVE COPY LINK PUBLISH_ALL ATTRIBUTES_ALL
              DELETE_ALL GRANT GRANT_ALL OWNER MASTER);
}


# userrights allow a user to ...
#
sub DENIED()          { return 0x00000000; } # explicit denial of content

# CATEGORY a) 0x01 - 0x80: primitive user rights on content
#
sub VIEW()          { return 0x00000001; } # view content
#
sub WRITE()         { return 0x00000002; } # edit content
#
sub DELETE()        { return 0x00000004; } # delete content
#
sub PUBLISH()       { return 0x00000008; } # publish content
#
sub ATTRIBUTES()    { return 0x00000010; } # change attributes for content
#
# CATEGORY b) 0x100 - 0x8000: document related rights
#
sub TRANSLATE()       { return 0x00000100; } # create new contents
#
sub CREATE()          { return 0x00000200; } # create new child
#
sub MOVE()            { return 0x00000400; } # move document to another location
#
sub LINK()            { return 0x00000800; } # create a symlink on document
#
sub PUBLISH_ALL()     { return 0x00001000; } # publish all content
#
sub ATTRIBUTES_ALL()  { return 0x00002000; } # change attributes for document
#
sub COPY()            { return 0x00004000; } # copy object to another location
#
# CATEGORY c) 0x10000 - 0x80000: administrative subtree privileges
# the DELETE_ALL flag is not granted by default to the owner!
#
sub DELETE_ALL()    { return 0x00010000; } # delete document subtree
#
# CATEGORY d) 0x01000000 - 0x08000000: grant privileges
#
# the GRANT right is a little complicated: if a user wants to grant a
# certain right to another user, the grantor needs to have the right
# to grant! this is to avoid users grant privileges to others they
# don't have themself. any ACL implementaion should follow this, to
# avoid security leaks.
#
sub GRANT()         { return 0x01000000; } # grant/revoke other users on content
#
sub GRANT_ALL()     { return 0x02000000; } # grant/revoke other users on all content
#
# CATEGORY e) 0x10000000 - 0x80000000: special roles
#
# the OWNER flag shows that current user is the owner of the current
# document.  this should be a workaround for the missing document
# owner.  this flag implies 0x0300031f, i guess, this means the owner is only
# entitled to do simple operations on the document.
#
sub OWNER()         { return 0x40000000; } # user owns document

#
# MODIFY is a - for now static - combination of a list of privileges to be given to creating users on object
# creation for example
# MODIFY could be changed to be more restrictive in the future
#
sub MODIFY()        { return 0x43016F17; } # user has VIEW, WRITE, DELETE, ATTRIBUTES, TRANSLATE, CREATE, MOVE, COPY, LINK, ATTRIBUTES_ALL, DELETE_ALL, GRANT, GRANT_ALL, and OWNER privilege on object

#
# the master flag shows, that the user is the master of the entire
# subtree.  this should imply 0x0301331d. this privilege is mainly for
# administrative reasons. therefore a master has also the right to
# grant/revoke privileges not owned by the master himself. as well the
#  MASTER is allowed to delete an entire subtree regardless of the
# rights the user has on any child in the subtree.
#
# since the master is generally not responsible for the content he is
# not allowed to edit the content
#
sub MASTER()        { return 0x80000000; }
#
#  SYSTEM PRIVILEGES
#
# the ADMIN privilege indicates extreme superuser! actually this is the helper right :P
#
sub ADMIN()         { return 0xffffffff; }


# ##########################################################################
# Package XIMS::Privileges::System
package XIMS::Privileges::System;

sub list {
    return qw( CHANGE_PASSWORD GRANT_ROLE RESET_PASSWORD SET_STATUS CREATE_ROLE DELETE_ROLE
               CHANGE_ROLE_FULLNAME CHANGE_USER_FULLNAME CHANGE_ROLE_NAME CHANGE_USER_NAME
               CREATE_USER DELETE_USER CHANGE_DAV_OTPRIVS_MASK CHANGE_SYSPRIVS_MASK SET_ADMIN_EQU );
}

#
# 0x01 - 0x80: user-self-management
#
sub CHANGE_PASSWORD()           { return 0x00000001; } # user can change his password
sub GRANT_ROLE()                { return 0x00000002; } # if users are role-masters of a role, they can grant/revoke other user/roles to/from his role

#
# 0x1000 - 0x800000: helpdesk-related user/role-management
#
sub RESET_PASSWORD()            { return 0x00001000; }
sub SET_STATUS()                { return 0x00002000; } # (un)lock users

sub CREATE_ROLE()               { return 0x00004000; } # with this privilege, users can add role-members without being role-masters of the role
sub DELETE_ROLE()               { return 0x00008000; }

sub CHANGE_ROLE_FULLNAME()      { return 0x00010000; }
sub CHANGE_USER_FULLNAME()      { return 0x00020000; }

sub CHANGE_ROLE_NAME()          { return 0x00040000; }
sub CHANGE_USER_NAME()          { return 0x00080000; }

sub CREATE_USER()               { return 0x00100000; }
sub DELETE_USER()               { return 0x00200000; }

sub CHANGE_DAV_OTPRIVS_MASK()   { return 0x00400000; }

#
# 0x10000000 - 0x80000000: system-management related
#
sub CHANGE_SYSPRIVS_MASK()      { return 0x10000000; }
sub SET_ADMIN_EQU()             { return 0x20000000; }


package XIMS::Helpers;
# ##########################################################################
# Package XIMS::Helpers
#

##
#
# SYNOPSIS
#    privmask_to_hash( $privmask )
#
# PARAMETER
#    $privmask: integer bitmask
#
# RETURNS
#    Returns a hash-reference with the corresponding XIMS::Privileges to $privmask as keys set to 1
#
# DESCRIPTION
#    Used to get a more readable representation of the integer bitmask
#
sub privmask_to_hash {
    my $privmask = shift;
    my $privclass = shift;
    $privclass ||= '';
    no strict 'refs';
    my $listclass = "XIMS::Privileges::".$privclass."list";
    my %privs = map { (lc($_), 1) } grep { $privmask & &{"XIMS::Privileges::$privclass$_"} } &{$listclass}();
    return \%privs;
}

##
#
# SYNOPSIS
#    system_privmask_to_hash( $privmask )
#
# PARAMETER
#    $privmask: integer bitmask
#
# RETURNS
#    Returns a hash-reference with the corresponding XIMS::Privileges::System to $privmask as keys set to 1
#
# DESCRIPTION
#    Used to get a more readable representation of the integer bitmask
#
sub system_privmask_to_hash { privmask_to_hash( shift, 'System::' ) }

##
#
# SYNOPSIS
#    dav_otprivmask_to_hash( $privmask, $object_types )
#
# PARAMETER
#    $privmask     : integer bitmask
#    $object_types : Reference to array of XIMS::ObjectType instances
#
# RETURNS
#    Returns a hash-reference with the corresponding DAV object type privileges as keys set to 1
#
# DESCRIPTION
#    Used to get a more readable representation of the integer bitmask
#
sub dav_otprivmask_to_hash { 
    my $privmask = shift;
    my $object_types = shift;

    # cast $privmask to an integer, so that the bitwise operation will work as expected
    1 if $privmask == 1;

    my %privs = map { ($_->name(), 1) } grep { $privmask & $_->davprivval() } @{$object_types};
    return \%privs;    
}


1;