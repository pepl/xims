# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

package XIMS;
#
# the main package defines general method accessable in all modules.
#

# note: we should _probably_ get rid of globals and begin-block and make this more OO :-|
#BEGIN {
    use strict;
    use vars qw( $VERSION $_MODPERL_ $_CONFIG_ );

    use XIMS::Config;

#    $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
    $VERSION = 1.1;

    # test if this is a local script or if we are running under mod_perl
    $_MODPERL_ = $ENV{MOD_PERL} ? 1 : 0 ;

    $_CONFIG_ = XIMS::Config->new();

#}

#
# XIMS::Config wrappers
# note: did not change the nameing yet, because i want to do it when we are getting to a 'real' config(reader)-concept
#
sub GOXIMS()                    { $_CONFIG_->goxims() }
sub DEBUGLEVEL()                { $_CONFIG_->DebugLevel() }
sub PUBROOT_URL()               { "/" . $_CONFIG_->PublicRoot() }
sub PUBROOT()                   { $_CONFIG_->ApacheDocumentRoot() . "/" . $_CONFIG_->PublicRoot()  }
sub DEFAULT_LANGUAGE()          { $_CONFIG_->DefaultLanguage() }
sub DEFAULT_SKIN()              { $_CONFIG_->DefaultSkin() }
sub DOC_FSEXPORTSTYLESHEET()    { $_CONFIG_->DocFSExportStylesheet() }
sub DEFAULT_PATH()              { $_CONFIG_->DefaultStartingPath() }
sub XIMSROOT_URL()              { "/" . $_CONFIG_->XIMSRoot() }
sub XIMSROOT()                  { $_CONFIG_->ApacheDocumentRoot() . "/" . $_CONFIG_->XIMSRoot() }
sub AUTHSTYLE()                 { $_CONFIG_->AuthStyle() }
sub AUTHSERVER()                { $_CONFIG_->AuthServer() }
sub CONTENTINTERFACE()          { "/" . $_CONFIG_->ContentInterface() }
sub DBMS()                      { $_CONFIG_->DBMS() }
sub QBDRIVER()                  { $_CONFIG_->QBDriver() }
sub DBUSER()                    { $_CONFIG_->DBUser() }
sub DBNAME()                    { $_CONFIG_->DBName() }
sub DBPWD()                     { $_CONFIG_->DBPassword() }
sub DBSESSIONOPT()              { $_CONFIG_->DBSessionOpt() }
sub DBDOPT()                    { $_CONFIG_->DBDOpt() }
sub DBDSN()                     { $_CONFIG_->DBdsn() }
sub DBENCODING()                { $_CONFIG_->DBEncoding() }
sub UIFALLBACKLANG()            { $_CONFIG_->UIFallbackLang() }
sub ADMINROLEID()               { $_CONFIG_->AdminRoleID() }
sub PUBLICUSERID()              { $_CONFIG_->PublicUserID() }
sub AUTOINDEXFILENAME()         { $_CONFIG_->AutoIndexFilename() }
sub AUTOINDEXEXPORTSTYLESHEET() { $_CONFIG_->AutoindexExportStylesheet() }
sub RESOLVERELTOSITEROOTS()     { $_CONFIG_->ResolveRelToSiteRoots() }

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
            if ( $_MODPERL_ ) {
                my $log = Apache->request->log();
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
#    escape 'dangerous' characters to xml-entities
#
sub xml_escape {
    # phish: is this obsolete ?
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
    return qw(DENIED VIEW WRITE DELETE PUBLISH ATTRIBUTES TRANSLATE CREATE MOVE LINK PUBLISH_ALL ATTRIBUTES_ALL
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
sub MODIFY()        { return 0x43012F17; } # user has VIEW, WRITE, DELETE, ATTRIBUTES, TRANSLATE, CREATE, MOVE, LINK, ATTRIBUTES_ALL, DELETE_ALL, GRANT, GRANT_ALL, and OWNER privilege on object

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
               CREATE_USER DELETE_USER CHANGE_SYSPRIVS_MASK SET_ADMIN_EQU );
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

sub CREATE_ROLE()               { return 0x00003000; } # with this privilege, users can add role-members without being role-masters of the role
sub DELETE_ROLE()               { return 0x00004000; }

sub CHANGE_ROLE_FULLNAME()      { return 0x00005000; }
sub CHANGE_USER_FULLNAME()      { return 0x00006000; }

sub CHANGE_ROLE_NAME()          { return 0x00007000; }
sub CHANGE_USER_NAME()          { return 0x00008000; }

sub CREATE_USER()               { return 0x00009000; }
sub DELETE_USER()               { return 0x0000a000; }

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
    no strict 'refs';
    my %privs = map { (lc($_), 1) } grep { $privmask & &{"XIMS::Privileges::$_"} } XIMS::Privileges::list();
    return \%privs;
}


1;
