# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config;

use strict;
use vars qw( $VERSION );

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use Apache;
use Data::Dumper;
##
#
# SYNOPSIS
#    XIMS::Config->new() 
#
# PARAMETER
#
# RETURNS
#    $config: XIMS::Config instance
#
# DESCRIPTION
#    Constructor; if we will have a lot config-stuff sometime, we'll move that to a 'real' config(reader)-concept
#
sub new {
    my $class = shift;
    my $apache = Apache->request() if $ENV{MOD_PERL};

    return bless { apache => $apache }, $class;
}



# ****************************************
#
# Debuglevel
#
# values from 0..6, where 6 is the most verbose.
#
# i.e:
# 0  turns off any messages from XIMS itself;
# 5  logs every function call and most forks inside them;
# 6  additionally dumps out parameters and values,
#    and even SQL statements used;
#
# ****************************************
sub DebugLevel()                { '6' }



# ****************************************
# 
# paths and files...
# 
# ****************************************

# apache document_root
sub ApacheDocumentRoot()          { '/www' }                 # apache ht_docs_dir, absolute path
sub XIMSRoot()                    { 'ximsroot' }             # path to ximsroot,relative to Documentroot;
                                                             # all ximsrelated under this dir
sub PublicRoot()                  { 'ximspubroot'}

sub goxims()                      { 'goxims' }              
sub ContentInterface()            { 'content' }

sub DefaultSkin()                 { 'default' }              # subdir where stylesheets for the default skin are found, relative path

sub ResolveRelToSiteRoots()       { 0 }                      # <0|1>
                                                             # set this to 1 if you want to symlink OU's directly into 
                                                             # ApacheDocumentRoot toplevel

# some names for "special" files

sub DocFSExportStylesheet()       { 'document_export.xsl' }
sub AutoindexExportStylesheet()   { 'export_auto_index.xsl' }
sub AutoIndexFilename()           { '_ottereendex.html' }

# fallback in the absence of defaultbookmark
sub DefaultStartingPath()         { '/xims' }

# ****************************************
# 
# authentification
# 
# ****************************************

sub AuthStyle()                   { 'XIMS::Auth::Password' } # name of authentification module or comma-separated 
                                                             # list there each will be tried consecutively
sub AuthServer()                  { '' }                     # for LDAP or IMAP auth



# ****************************************
# 
# "special" userids
# 
# ****************************************

sub PublicUserID()                { '5' }
sub AdminRoleID()                 { '4' }


# ****************************************
# 
# db-stuff
# 
# ****************************************

sub DBMS()                        { 'DBI' }
sub DBMS_OPTION()                 { '' }
sub DBUser()                      { 'ximsrun' }
sub DBName()                      { 'xims' }
sub DBPassword()                  { 'ximsrun' }
sub DBEncoding()                  { 'ISO-8859-1' }           # used amongst other things to
                                                             # en|decode from UTF-8 for libxml

# Example settings for PostgreSQL
sub DBdsn()                       { 'dbi:Pg:dbname=xims;host=localhost' }
sub DBSessionOpt()                { 'SET DateStyle TO German;SET Client_Encoding TO LATIN1;' }
sub DBDOpt()                      { 'FetchHashKeyName=NAME_uc;' }

# Examples isettings for Oracle
#sub DBdsn()                       { 'dbi:Oracle:test' }
#sub DBSessionOpt()                { 'ALTER SESSION SET NLS_DATE_FORMAT=\'DD.MM.YYYY HH24:MI:SS\';' }
#sub DBDOpt()                      { 'LongReadLen=10485760;LongTruncOk=1'};


# ****************************************
# 
# Language settings
# 
# ****************************************

sub DefaultLanguage()             { 'en-us' }                # (default)language set on object creation
                                                             # while objects with (even multiple) non-default
                                                             # language content(s) are in the datastructures,
                                                             # there's no usable implemetation for it UI-wise yet;
sub UIFallbackLang()              { 'en-us' }                # once a multilanguage userinterface is implemented, XIMS
                                                             # will fall back to this, if it cannot provide stylesheets
                                                             # for the language requested by the UserAgent; this setting
                                                             # maps 1:1 to the names of the subdir in /ximsroot/stylesheets/skins/default
                                                             # i.e: /ximsroot/stylesheets/skins/default/en-us/
                                                             #                                          ^^^^^
1;
