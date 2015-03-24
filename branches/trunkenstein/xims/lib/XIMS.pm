
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

use common::sense;
use XIMS::Config;
use Encode ();
use Carp;

our $AUTOLOAD;
our $VERSION = 2.99_1;
our $_CONFIG_;
our $_DATAPROVIDER_;
our $_OBJECT_TYPES_;
our $_DATA_FORMATS_;
our $_LANGUAGES_;
our $_DEBUGLEVEL_;
our %STYLE_CACHE;

BEGIN {
    $_CONFIG_ = XIMS::Config->new(ro => $ENV{XIMS_NO_XSLCONFIG});

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

    my @langs = $dp->languages();
    foreach my $lang (@langs) {
        $_LANGUAGES_->{ $lang->id() } = $lang;
    }

    # Decide the debug level here, at compile time. This allows perl to
    # `inline´ XIMS::DEBUGLEVEL() for really fast access.
    $_DEBUGLEVEL_ = $ENV{XIMSDEBUGLEVEL} || $_CONFIG_->DebugLevel();

    ## no critic (ProhibitNestedSubs)

    # internal helper for building up fullname of entry of
    # XIMS::OBJECT_TYPES

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

## no critic ( RequireFinalReturn, ProhibitSubroutinePrototypes )

require XIMS::DataProvider;
require XIMS::Privileges;
require XIMS::Privileges::System;

=head2 DATAPROVIDER()

Returns a XIMS::DataProvider instance.

=cut

sub DATAPROVIDER {
    $_DATAPROVIDER_ ||= XIMS::DataProvider->new();
    return $_DATAPROVIDER_;
}

=head2 OBJECT_TYPES()

Returns the list of object types.

=cut

sub OBJECT_TYPES () { $_OBJECT_TYPES_ }

=head2 DATA_FORMATS()

Returns the list of data formats.

=cut

sub DATA_FORMATS () { $_DATA_FORMATS_ }

=head2 LANGUAGES()

Returns the list of languages.

=cut

sub LANGUAGES () { $_LANGUAGES_ }

=head2 HOME()

Returns the path to XIMS' root directory.

=cut

sub HOME {
    $ENV{'XIMS_HOME'} || '/usr/local/xims';
}

=head2 XIMS::Config wrappers

=over

=item GOXIMS()

=item GOPUBLIC()

=item GOBAXIMS()

=item GODAV()

=item DEBUGLEVEL()

=item PUBROOT_URL()

=item PUBROOT()

=item DEFAULT_SKIN()

=item FALLBACKSTARTPATH()

=item DEFAULTXHTMLEDITOR()

=item XMLEDITOR()

=item TIDYPATH()

=item TIDYOPTIONS()

=item XIMSROOT_URL()

=item XIMSROOT()

=item AUTHSTYLE()

=item AUTHSERVER()

=item TRUSTPROXY()

=item CONTENTINTERFACE()

=item PERSONALINTERFACE()

=item USERMANAGEMENTINTERFACE()

=item DBMS()

=item QBDRIVER()

=item DBDSN()

=item DBENCODING()

=item UIFALLBACKLANG()

=item PUBLICUSERID()

=item AUTHENTICATEDUSERROLEID()

=item AUTOINDEXFILENAME()

=item AUTOINDEXEXPORTSTYLESHEET()

=item RESOLVERELTOSITEROOTS()

=item SEARCHRESULTROWLIMIT()

=item UILANGUAGES()

=item REQUESTAGENTSOURCEIP()

=item MAILSIZELIMIT()

=back

=cut

sub GOXIMS                    { return '/' . $_CONFIG_->goxims(); }

sub GOPUBLIC                  { return '/' . $_CONFIG_->gopublic(); }

sub GOBAXIMS                  { return '/' . $_CONFIG_->gobaxims(); }

sub GODAV                     { return '/' . $_CONFIG_->godav(); }

sub DEBUGLEVEL ()             { $_DEBUGLEVEL_ }

sub PUBROOT_URL               { return '/' . $_CONFIG_->PublicRoot(); }

sub PUBROOT                   { return $_CONFIG_->ServerDocumentRoot()
                                     . '/'
                                     . $_CONFIG_->PublicRoot();
}
sub DEFAULT_SKIN              { return $_CONFIG_->DefaultSkin(); }

sub FALLBACKSTARTPATH         { return $_CONFIG_->FallbackStartPath(); }

sub DEFAULTXHTMLEDITOR        { return $_CONFIG_->DefaultXHTMLEditor(); }

sub XMLEDITOR                 { return $_CONFIG_->XMLEditor(); }

sub TIDYPATH                  { return $_CONFIG_->TidyPath(); }

sub TIDYOPTIONS               { return $_CONFIG_->TidyOptions(); }

sub XIMSROOT_URL              { return '/' . $_CONFIG_->XIMSRoot(); }

sub XIMSROOT                  { return $_CONFIG_->ServerDocumentRoot()
                                     . '/'
                                     . $_CONFIG_->XIMSRoot();
}

sub AUTHSTYLE                 { return $_CONFIG_->AuthStyle(); }

sub AUTHSERVER                { return $_CONFIG_->AuthServer(); }

sub TRUSTPROXY                { return $_CONFIG_->trustProxy(); }

sub CONTENTINTERFACE          { return '/' . $_CONFIG_->ContentInterface(); }

sub PERSONALINTERFACE         { return '/' . $_CONFIG_->PersonalInterface(); }

sub USERMANAGEMENTINTERFACE   { return '/' . $_CONFIG_->UserManagementInterface(); }

sub DBMS                      { return $_CONFIG_->DBMS(); }

sub QBDRIVER                  { return $_CONFIG_->QBDriver(); }

sub DBDSN                     { return $_CONFIG_->DBdsn(); }

sub UIFALLBACKLANG            { return $_CONFIG_->UIFallbackLang(); }

sub PUBLICUSERID              { return $_CONFIG_->PublicUserID(); }

sub AUTHENTICATEDUSERROLEID   { return $_CONFIG_->AuthenticatedUserRoleID(); }

sub AUTOINDEXFILENAME         { return $_CONFIG_->AutoIndexFilename(); }

sub AUTOINDEXEXPORTSTYLESHEET { return $_CONFIG_->AutoindexExportStylesheet(); }

sub RESOLVERELTOSITEROOTS     { return $_CONFIG_->ResolveRelToSiteRoots(); }

sub SEARCHRESULTROWLIMIT      { return $_CONFIG_->SearchResultRowLimit(); }

sub DEFAULTUSERPREFSSKIN      { return $_CONFIG_->DefaultUserPrefsSkin(); }
sub DEFAULTUSERPREFSPROFILE      { return $_CONFIG_->DefaultUserPrefsProfile(); }
sub DEFAULTUSERPREFSCONTAINERVIEW      { return $_CONFIG_->DefaultUserPrefsContainerview(); }
sub DEFAULTUSERPREFSPUBONSAVE      { return $_CONFIG_->DefaultUserPrefsPubOnSave(); }

sub RECMAXOBJECTS      { return $_CONFIG_->RecMaxObjects(); }

sub UILANGUAGES {
    my %rv;
    foreach ( $_CONFIG_->UILanguages() ) {
        /^(\w{1,8})(?:-\w+)/;
        $rv{$_} = "\^$1\.\*";
    }
    return %rv;
}

sub REQUESTAGENTSOURCEIP      { return $_CONFIG_->RequestAgentSourceIP(); }

sub MAILSIZELIMIT             { return $_CONFIG_->MailSizeLimit(); }

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

sub CONFIG () { $_CONFIG_ }

## use critic

#  Utility methods

=head2 Debug()

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
    my ($level, $message) = @_;
    if ( $level <= XIMS::DEBUGLEVEL() ) {
        $message =~ s/\n|\s+/ /g;
        my ( $module, undef, undef, $method ) = caller(1);
        warn( "[$module, $method] $message\n" );
    }
    return;
}

=head2 xml_escape()

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

=head2 xml_unescape()

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

=head2 xml_escape_noquot()

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


=head2 nodevalue()

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
            return $value;
        }
    }
}

=head2 trim()

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

=head2 unquot()

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

=head2 clean()

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

=head2 escapewildcard()

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

=head2  tokenize_string()

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



=head2 utf8_sanitize()

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

    if ( XIMS::is_notutf8($string) ) {
        return Encode::decode( 'UTF-8', Encode::encode('UTF-8',$string) );
    }
    else {
        Encode::_utf8_on($string);
        return $string;
    }
}



=head2 is_notutf8()

=head3 Parameter

    $string: string

=head3 Returns

    $boolean: True if string is not utf-8 and false if it is utf-8 encoded

=head3 Description

    my $boolean = XIMS::is_notutf8( $string )

Tests whether a string is utf-8 encoded or not.

=cut

sub is_notutf8 {
    my $string = shift;

    eval { Encode::decode( 'UTF-8', $string, 1 ); };
    return $@ ? 1 : 0;
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

=head2  system_privmask_to_hash()

=head3 Parameter

    $privmask: integer bitmask

=head3 Returns

Returns a hash-reference with the corresponding XIMS::Privileges::System to
$privmask as keys set to 1.

=head3 Description

    system_privmask_to_hash( $privmask )

Used, to get a more readable representation of the integer bitmask.

=cut

sub system_privmask_to_hash { return privmask_to_hash( shift, 'System::' ); }



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

Copyright (c) 2002-2015 The XIMS Project.

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

