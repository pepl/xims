# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config;

use strict;
use vars qw( $VERSION );

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use Apache;
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
# see
# http://xims.uibk.ac.at/xims-doku/developers/developer-guide.dkb#id2832938
# for the "Debuglevel Reference"
#
# ****************************************
sub DebugLevel()                { '6' }

# ****************************************
#
# paths and files...
#
# ****************************************

# apache document_root
sub ApacheDocumentRoot()          { '' }            # Absolute path to the Apache document root

sub XIMSRoot()                    { 'ximsroot' }    # Path to ximsroot,relative to ApacheDocumentRoot()
                                                    # Do not change unless you know what you are doing!

sub PublicRoot()                  { 'ximspubroot'}  # Path to the export directory relative to ApacheDocumentRoot()
                                                    # Must be in sync with the corresponding value in config.xsl
                                                    # Do not change unless you know what you are doing!

sub goxims()                      { 'goxims' }      # Name of the main XIMS PerlHandler module
                                                    # Must be in sync with the corresponding value in config.xsl
                                                    # Do not change unless you know what you are doing!

sub ContentInterface()            { 'content' }     # Name of the content interface
                                                    # Must be in sync with the corresponding value in config.xsl
                                                    # Do not change unless you know what you are doing!

sub DefaultSkin()                 { 'default' }     # Name of the skin used per default. Relative path under XIMSRoot()/skins/
                                                    # Do not change unless you know what you are doing!

sub ResolveRelToSiteRoots()       { '1' }           # <'0'|'1'>
                                                    # Set this to '1' if you want to symlink OU's directly under
                                                    # ApacheDocumentRoot() or use virtual hosts
                                                    # Do not change unless you know what you are doing!

sub SearchResultRowLimit()        { '20' }          # Number of found objects displayed per page at event_search
                                                    # Must be in sync with the corresponding value in config.xsl


# some names for "special" files
sub AutoIndexFilename()           { '_ottereendex.html' }      # Filename of the auto-generated container indices.
                                                               # If you change that, you have to update the DirectoryIndex directive in ximshttpd.conf
sub DocFSExportStylesheet()       { 'document_export.xsl' }
sub AutoindexExportStylesheet()   { 'export_auto_index.xsl' }

# fallback in the absence of defaultbookmark
sub DefaultStartingPath()         { '/xims' }   # If users have no defaultbookmark set, they will be redirected to /$goxims/$contentinterface/$defaultstartingpath
                                                # Value must be the path to an existing XIMS content object

sub WYSIWYGEditor()               { '' }        # Currently, 'htmlarea' and 'wepro' are implemented.
                                                # If you configure WYSIWYGEditor(), you have to install the corresponding editor files to XIMSRoot(). For example, download HTMLArea 3 CVS from
                                                # http://sourceforge.net/projects/itools-htmlarea/ and extract it to XIMSRoot() so that htmlarea.js is available at $XimsRoot()/htmlarea/htmlarea.js.
                                                # The files for 'wepro' are available at http://www.ektron.com/ewebeditpro.cfm?doc_id=1989
                                                # Unpack them to XIMSRoot()/ewebedit/
                                                #
                                                # WYSIWYGEditor() should be considered as a system wide default an fall back value. Users should be able to set their preference via the /user/ interface (to be developed)

# path and options for tidy
sub TidyPath()                    {'/usr/local/bin/tidy'};                                              # path to tidy binary
sub TidyOptions()                 {' -config /usr/local/xims/conf/ximstidy.conf -quiet -f /dev/null'};  # options for tidy

# ****************************************
#
# authentification
#
# ****************************************

sub AuthStyle()                   { 'XIMS::Auth::Password' }   # Name or comma-separated list of names of the authentification module(s)
                                                               # Modules in a list will be tried consecutively.
sub AuthServer()                  { '' }                       # FQDN of the Server used for LDAP or IMAP authentification



# ****************************************
#
# "special" userids
#
# ****************************************

sub PublicUserID()                { '6' }                  # Default value comes from default_data.sql
                                                           # Do not change unless you know what you are doing!
sub AdminRoleID()                 { '4' }                  # Default value comes from default_data.sql
                                                           # Do not change unless you know what you are doing!


# ****************************************
#
# db-stuff
#
# ****************************************

sub DBMS()                        { 'DBI' }
sub DBUser()                      { '' }
sub DBName()                      { '' }
sub DBPassword()                  { '' }

sub DBdsn()                       { '' }                # DBI dsn string
sub DBDOpt()                      { '' }                # RDBMS specific DBD connect options
sub DBSessionOpt()                { '' }                # RDBMS specific DBD session options

# Example settings for PostgreSQL
#sub DBUser()                      { 'ximsrun' } # Default value from defaultdata.sql
#sub DBName()                      { 'xims' }    # Default value from defaultdata.sql
#sub DBPassword()                  { 'ximsrun' } # Default value from defaultdata.sql
#sub DBdsn()                       { 'dbi:Pg:dbname=xims' }
#sub DBSessionOpt()                { 'SET DateStyle TO German;SET Client_Encoding TO UNICODE;' }
#sub DBDOpt()                      { 'FetchHashKeyName=NAME_uc;' }

# Examples settings for Oracle
#sub DBdsn()                       { 'dbi:Oracle:test' }
#sub DBSessionOpt()                { 'ALTER SESSION SET NLS_DATE_FORMAT=\'DD.MM.YYYY HH24:MI:SS\';' }
#sub DBDOpt()                      { 'LongReadLen=10485760;LongTruncOk=1'};

sub DBEncoding()                  { '' }                   # Set this to your dabase encoding if the database is not encoded in UTF-8
sub QBDriver()                    { '' }                   # Used for special DBI specific QueryBuilder Driver.
                                                           # 'InterMedia' for example will load XIMS::QueryBuilder::OracleInterMedia
                                                           # for Oracle.


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
                                                             # maps 1:1 to the names of the subdir in /ximsroot/skins/default/stylesheets
                                                             # i.e: /ximsroot/skins/default/stylesheets/en-us/
                                                             #                                          ^^^^^
1;
