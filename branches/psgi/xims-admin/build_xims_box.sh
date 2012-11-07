#!/bin/bash
# use '/bin/bash' here because ubuntu links '/bin/sh'
# to '/bin/dash'
# 
# Build script for the XIMS-Box
#
#   It assumes the following directory-structure
#   in the xims_box_build_system directory:
#     <path-to-xims-box-build-dir>
#        |
#        |-build_scripts
#        |-debian
#        |  |-apache_1.3.37
#        |  |-cpan-perl-modules
#        |  |-libxml2-2.6.27
#        |  |-libxslt-1.1.19
#        |  |-perl-5.8.8
#        |  `-xims
#        |-redhat
#        |  |-BUILD
#        |  |-RPMS
#        |  |-SOURCES
#        |  |-SPECS
#        |  `-SRPMS
#        `-xims-box
#           |-debs
#           `-rpms
#
#   Do not change this setup, unless you know what you are
#   doing!
#
# 
#set -xv #debug

function usage () {
    cat <<MSG_USAGE
 
  USAGE
    interactive mode:
      build_xims_box.sh -o {clean|keep}
 
    non interactive (e.g. for a cron-job):
      build_xims_box.sh -n -o {clean|keep} [-v <VERSION>] [-a <BOX-VERSION>] -b <BUILD_TARGET>
    
    -b BUILD_TARGET  Is the directory where the resulting
                     *.tar.gz files (one containing the rpms and one
                     containing the debs) will be put into.

    -n               Run in non interactive mode
 
    -o {clean|keep}  Use the 'clean' option for removing the
                     XIMS-Box build system after the build. The
                     'keep' option keeps the build system in the
                     filesystem, usually in
                     '/tmp/xims_box_build_system'

    -v VERSION       If called in non interactive mode, the 'xims'
                     rpm/deb packages will get the given
                     version string. If called in non interactive
                     mode and the version is not provided it
                     defaults to the 'inoffical' version of '0.007'.
                     In interactive mode, the user will be prompted
                     for a version number.

    -a BOX-VERSION   If called in non interactive mode and this option
                     is provided, the resulting *.tar.gz files - holding
                     the rpms/debs - will get 'BOX-VERSION' appended in
                     the filename. Hence, if provided, the resulting
                     *.tar.gz files will get following filenames:
                        xims-out-of-the-box-debs-<BOX-VERSION>.tar.gz
                        xims-out-of-the-box-rpms-<BOX-VERSION>.tar.gz
                     If omitted, a date-string of the format 'YYYYMMDD'
                     will be used instead.

  ############################## NOTE!!! #################################

    This script requires GNU core-utils, wget, patch, a subversion client
    plus dpkg/rpm build tools!
    
    It has been developed for execution on a Debian-based machine (tested
    on Debian/Ubuntu). However, it should be easily possible to be run on
    any RPM-based system with some minor adjustments.

  ############################## NOTE!!! #################################

MSG_USAGE
    exit 1
}

function cleanup_end_script () {
    # print error and exit
    echo
    echo "**********************************************"
    echo 
    echo -ne "Error!!\nSome action exited with non-zero exit-code!\
              \nThe error occured somewhere near '$1' in '$0'.\nSee '$LOGFILE' and '$ERRORLOGFILE' for details!\n
              \nPlease correct errors and rerun script. Cleaning up, now ... "
    rm -rf $RPM_BUILD_ROOT >> /dev/null 2>&1
    if [ "$REMOVE_BUILD_DIR" == "yes" ]; then
        rm -rf $BUILD_DIR >> /dev/null 2>&1
        # remove downloaded tar-file
        rm -f $BUILD_SYSTEM_FILE
    fi
    echo "Done! Bye, bye!"
    echo
    echo -e "\n... then an ERROR occurred :-( See '$ERRORLOGFILE' for details!" >> $LOGFILE
    echo "... which should be our ERROR cause :-(" >> $ERRORLOGFILE
    exit 1
}

function script_interrupt () {
    echo
    echo "**********************************************"
    echo 
    echo "Caught interrupt! "
    echo -n "Cleaning up ... "
    rm -rf /tmp/$BUILD_SYSTEM_FILE $RPM_BUILD_ROOT >> /dev/null 2>&1
    if [ "$REMOVE_BUILD_DIR" == "yes" ]; then
        rm -rf $BUILD_DIR >> /dev/null 2>&1
    fi
    echo "done! Exit script, now. Bye, bye!"
    echo
    echo "... then I received an interrupt :-(" | tee -a $LOGFILE >> $ERRORLOGFILE
    exit 1
}

function set_opt_versions () {
    # when there is no XIMS_VERSION, we put a
    # fiction-version of '0.007' ;-)
    if [ "$XIMS_VERSION" == '' ]; then
        XIMS_VERSION="0.007"
    fi
    # when there is no BOX_VERSION, we put a
    # version of YYYYMMDD
    if [ "$BOX_VERSION" == '' ]; then
        BOX_VERSION=`date +%Y%m%d`
    fi
}

function is_root () {
    cuser=`whoami`
    cuid=`grep $cuser /etc/passwd | cut -d: -f3`
    if [[ "$cuid" != "0" ]]; then
        echo "ERROR!!! Stop script, now! Are you root?" 1>&2
        exit 1
    fi
}

function check_deb_req () {
    # root-privileges?
    is_root
    # coreutils should never be not installed, but to be super-safe (or just dumb)
    dpkg -l 'coreutils' > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! Stop script, now! 'coreutils' package installed?" 1>&2
        exit 1
    fi
    # wget
    which wget > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! Stop script, now! 'wget' package installed?" 1>&2
        exit 1
    fi
    # subversion client
    which svn > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! Stop script, now! 'subversion' package installed?" 1>&2
        exit 1
    fi
    # patch
    which patch > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! Stop script, now! 'patch' package installed?" 1>&2
        exit 1
    fi
    # rpmbuild
    which rpmbuild > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! Stop script, now! 'rpm' package installed?" 1>&2
        exit 1
    fi
}

function check_if_failed () {
    if [[ $? -gt 0 ]]; then
        cleanup_end_script $1
    fi
}

# run interactively per default
INTERACTIVE="yes"

# we do not show 'getopts' errors
OPTERR="0"
# get options
while getopts "b:no:v:a:*" options; do
    case $options in
        b)
            if [ "$OPTARG" != "" ]; then
                BUILD_TARGET=$OPTARG
            else
                usage
            fi
        ;;
        n)
            INTERACTIVE="no"
        ;;
        o)
            case $OPTARG in
                keep) REMOVE_BUILD_DIR="no" ;;
                clean) REMOVE_BUILD_DIR="yes" ;;
                *) usage ;;
            esac
        ;;
        v)  
            if [ "$OPTARG" != "" ]; then
                XIMS_VERSION=$OPTARG
            else
                usage
            fi
        ;;
        a)  
            if [ "$OPTARG" != "" ]; then
                BOX_VERSION=$OPTARG
            else
                usage
            fi
        ;;
        *)
            usage
        ;;
    esac
done

#### check options
# If REMOVE_BUILD_DIR is not set, stop!
if [ "$REMOVE_BUILD_DIR" != "no" -a "$REMOVE_BUILD_DIR" != "yes" ]; then
    usage
fi

# do we have an non-interactive call?
if [ "$INTERACTIVE" == 'no' ]; then
    # check options for a non-intactive call
    if [ "$BUILD_TARGET" == '' ]; then
        usage
    fi
    set_opt_versions # set default versions for xims/xims-box, if not set
else
    # if run interactively prompt for the required information
    read -p 'Where should I place the resulting *.tar.gz files? ' BUILD_TARGET
    read -p 'Which version should I use for the xims deb/rpm packages? Hit return for default ("0.007"): ' XIMS_VERSION
    read -p 'Which "Box-Version" should I use for the resulting filenames? Hit return for default ("YYYYMMDD"): ' BOX_VERSION
    set_opt_versions # set default versions for xims/xims-box, if not set
fi

#### to here, we should have all required information to get the script run
# nevertheless, have a last check, to be on the save side anyway
if [ "$BUILD_TARGET" == '' -o \
     "$REMOVE_BUILD_DIR" == '' -o \
     "$XIMS_VERSION" == '' -o \
     "$BOX_VERSION" == '' ]; then
    usage
fi

############################################################
#
# Configuration options
#
############################################################

#### general stuff
# we collect recent xims data from the svn-repo
XIMS_SVN_URI="http://xims.svn.sourceforge.net/svnroot/xims/trunk"
XIMS_SVN_BRANCH="$XIMS_SVN_URI/xims"
XIMS_CONTRIB_SVN_BRANCH="$XIMS_SVN_URI/xims-contrib"
# we get the xims-build system from sf.net's files-section
BUILD_SYSTEM_FILE="xims_box_build_system_current.tar.gz"
XIMS_BOX_BUILD_SYSTEM_URI="http://xims.info/downloads/$BUILD_SYSTEM_FILE"

BUILD_DIR="/tmp/xims_box_build_system" # no trailing slashes allowed here

XIMS_BOX_DIR="$BUILD_DIR/xims-box"
XIMS_BOX_BASE_NAME="xims-out-of-the-box"
XIMS_BOX_FEXTENSION="tar.gz"

# debian build config
DEB_BUILD_ROOT="$BUILD_DIR/debian"
DEB_APACHE_DIR="$DEB_BUILD_ROOT/apache_1.3.37"
DEB_LIBXML2_DIR="$DEB_BUILD_ROOT/libxml2-2.6.27"
DEB_LIBXSLT_DIR="$DEB_BUILD_ROOT/libxslt-1.1.19"
DEB_PERL_DIR="$DEB_BUILD_ROOT/perl-5.8.8"
DEB_XIMS_DIR="$DEB_BUILD_ROOT/xims"

# rpm build config
RPM_BUILD_ROOT="/usr/src/rpm"

# logs config
LOGFILE="build_xims_box.common.log"
ERRORLOGFILE="build_xims_box.error.log"

############################################################
#
# You must not edit anything below here!
#
############################################################

#### basic privilege and requirements checking
check_deb_req

#### store current path for later use
SCRIPTPATH=$(pwd)

#### prepend path for logfiles
LOGFILE="$SCRIPTPATH/$LOGFILE"
ERRORLOGFILE="$SCRIPTPATH/$ERRORLOGFILE"

#### trap SIGINTs
trap 'script_interrupt' SIGINT

#### logfile preparation
if [ -e $LOGFILE ]; then
    rm $LOGFILE # remove old logs
fi
if [ -e $ERRORLOGFILE ]; then
    rm $ERRORLOGFILE # remove old logs
fi
# create logfile initially
echo "**********************************************" | tee $LOGFILE
echo | tee -a $LOGFILE

#### reset $BUILD_SYSTEM_FILE to actual filename (if present)
# filename must contain 'xims_box_build_system'!
# this routine is necessary for pre-download-removals
BUILD_DIR_TMP=`dirname $BUILD_DIR`
for i in `ls $BUILD_DIR_TMP`; do
    echo "$i" | grep 'xims_box_build_system' > /dev/null 2>&1
    if [ "$?" == "0" ]; then
        BUILD_SYSTEM_FILE="$i"
        # clean up from previous builds
        if [ -e $BUILD_DIR_TMP/$BUILD_SYSTEM_FILE ]; then
            # remove, if there is another downloaded file
            rm -rf $BUILD_DIR_TMP/$BUILD_SYSTEM_FILE
        fi
    fi
done

if [ -e $BUILD_DIR ]; then
    echo "Build directory ($BUILD_DIR) exists, so removing." >> $LOGFILE
    # remove, if build dir already exists
    rm -rf $BUILD_DIR
fi

#### get and prepare build system
echo -n "Getting XIMS-Box build system from sf.net ..." | tee -a $LOGFILE
cd /tmp
wget "$XIMS_BOX_BUILD_SYSTEM_URI" 2>> $ERRORLOGFILE >> $LOGFILE
check_if_failed $_ # check for success
echo -en "Done!\nPreparing build system ..." | tee -a $LOGFILE

#### reset $BUILD_SYSTEM_FILE to actual filename
# filename must contain 'xims_box_build_system'!
for i in `ls $BUILD_DIR_TMP`; do
    echo "$i" | grep 'xims_box_build_system' > /dev/null 2>&1
    if [ "$?" == "0" ]; then
        BUILD_SYSTEM_FILE="$BUILD_DIR_TMP/$i"
    fi
done

echo "Build-system-file is: '$BUILD_SYSTEM_FILE'" >> $LOGFILE
tar -xzf $BUILD_SYSTEM_FILE 2>> $ERRORLOGFILE | tee -a $LOGFILE # report errors to error-log
check_if_failed $_ # check for success
echo -e "Done!\nGetting and preparing the latest XIMS dev snapshot ..." | tee $LOGFILE
# cd to the xims place
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package
# get snapshot
svn export --quiet $XIMS_SVN_BRANCH xims 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# add xims-contrib and put htmlarea link
cd $DEB_XIMS_DIR
svn export --quiet $XIMS_CONTRIB_SVN_BRANCH xims-contrib 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# move contents to the right place
mv xims-contrib/* $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximsroot/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# clean up
rm -rf xims-contrib
# move tinymce install-files under ximsroot
mv tinymce_3.0.9 $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximsroot/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# create the htmlarea and tinymce symlinks
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximsroot/
ln -s htmlarea3rc1 htmlarea 2>> $ERRORLOGFILE
ln -s tinymce_3.0.9 tinymce 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# put examplesite from the xims_box_build_system to ximspubroot
mv $DEB_XIMS_DIR/examplesite $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximspubroot/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# we build the xims-box with the according default-data, thus change the
# switch in 'defaultdata.sql'
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/sql/Pg/
perl -pni -e 's/^(\\i defaultdata-content\.sql)/--$1/' defaultdata.sql 2>> $ERRORLOGFILE
perl -pni -e 's/^--(\\i xims-box-defaultdata-content\.sql)/$1/' defaultdata.sql 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# cd to xims-home
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims
# replace headers of perl files of the xims-distri to fit xims-box needs
find ./ -name '*.pl' -print0 | xargs -0 perl -pni -e 's|^#!/usr/bin/perl( ?)|#!/opt/xims-package/ximsperl/bin/perl$1|' 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# patch xims svn branch (adjust default wysiwyg and ximsconfig.xml)
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims
echo -n "   Applying XIMS-Box patch ..." | tee -a $LOGFILE
patch -p1 -u < $DEB_XIMS_DIR/xims_box.patch >> $LOGFILE
check_if_failed $_ # check for success
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/conf
echo "Done!" | tee -a $LOGFILE
# adjust XIMS_HOME env-variable in ximshttpd.conf
perl -pni -e 's|^#(PerlSetEnv\sXIMS_HOME\s).*$|$1/opt/xims-package/xims|' ximshttpd.conf
check_if_failed $_ # check for success
# adjust ximsstartup.pl
perl -pni -e 's/^#\s(DBI\->install_driver\("Pg"\);).*$/$1/' ximsstartup.pl
check_if_failed $_ # check for success
perl -pni -e 's/^#\s(use AxKit \(\);).*$/$1/' ximsstartup.pl
check_if_failed $_ # check for success
perl -pni -e 's|^(use\slib\sqw\()[^)]+(\))|$1 /opt/xims-package/xims/lib $2|' ximsstartup.pl
check_if_failed $_ # check for success

# give some feedback again 
{ cat <<OUTPUT
Done!"
**********************************************

Start building debian packages ...
OUTPUT
} | tee -a $LOGFILE

#### build debs
# build apache-xims
cd $DEB_APACHE_DIR/deb
dpkg-deb --build debian apache-xims_1.3.37-1_i386.deb | tee -a $LOGFILE
check_if_failed $_ # check for success
# build libxml2-xims
cd $DEB_LIBXML2_DIR/deb
dpkg-deb --build debian libxml2-xims_2.6.27-1_i386.deb | tee -a $LOGFILE
check_if_failed $_ # check for success
# build libxslt-xims
cd $DEB_LIBXSLT_DIR/deb
dpkg-deb --build debian libxslt-xims_1.1.19-1_i386.deb | tee -a $LOGFILE
check_if_failed $_ # check for success
# build perl-xims
cd $DEB_PERL_DIR/deb
dpkg-deb --build debian perl-xims_5.8.8-1_i386.deb | tee -a $LOGFILE
check_if_failed $_ # check for success
## finally build xims
# adjust version first (XIMS_VERSION)
cd $DEB_XIMS_DIR/deb/debian/DEBIAN
perl -pni -e "s/^Version: [^-]+-1/Version: $XIMS_VERSION-1/" control 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
cd $DEB_XIMS_DIR/deb
dpkg-deb --build debian xims_$XIMS_VERSION-1_i386.deb | tee -a $LOGFILE
check_if_failed $_ # check for success

{ cat <<OUTPUT
Done!"
**********************************************

Start building rpm packages ...
OUTPUT
} | tee -a $LOGFILE

#### build rpms
# backup existent 'rpm' dir in '/usr/src' (we use our own rpm dir, as it is the Debian default name)
if [ -e /usr/src/rpm ]; then
    timestamp=`date +%Y%m%d%H:%M:%S`
    echo "WARNING!!! '/usr/src/rpm' exists. Old directory renamed into 'rpm_$timestamp'" | tee -a $LOGFILE
    mv /usr/src/rpm /usr/src/rpm_$timestamp 2>> $ERRORLOGFILE
fi
# move xims-box provided rpm-build system to /usr/src (prepare rpm-build-root)
mv $BUILD_DIR/redhat $RPM_BUILD_ROOT 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# prepare rpm build system (copying files)
cp -r $DEB_APACHE_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/apache_xims-root/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
cp -r $DEB_LIBXML2_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/libxml2_xims-root/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
cp -r $DEB_LIBXSLT_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/libxslt_xims-root/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
cp -r $DEB_PERL_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/perl_xims-root/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
cp -r $DEB_XIMS_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/xims-root/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# prepare for build (adjust xims-version)
cd $RPM_BUILD_ROOT/SPECS
perl -pni -e "s/^Version: .+$/Version: $XIMS_VERSION/" xims-1.spec 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
find -name '??*' -print0 | xargs -0 rpmbuild --quiet -bb 2>> $ERRORLOGFILE | egrep '^(Processing files:)' | tee -a $LOGFILE
check_if_failed $_ # check for success

{ cat <<OUTPUT
Done!"
**********************************************

OUTPUT
} | tee -a $LOGFILE
echo -n "Collect and 'tar' packages ..." | tee -a $LOGFILE

#### collect debs/rpms
# debs first ;-)
mv $DEB_APACHE_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
mv $DEB_LIBXML2_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
mv $DEB_LIBXSLT_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
mv $DEB_PERL_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
mv $DEB_XIMS_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success

# now the rpms
mv $RPM_BUILD_ROOT/RPMS/i386/*.rpm $XIMS_BOX_DIR/rpms/xims-box/ 2>> $ERRORLOGFILE
check_if_failed $_ # check for success

#### create the 2 'tar.gzs' ;-)
# again, debs first
cd $XIMS_BOX_DIR/debs
mv xims-box xims-box-$BOX_VERSION
tar -czf $XIMS_BOX_BASE_NAME-debs-$BOX_VERSION.$XIMS_BOX_FEXTENSION xims-box-$BOX_VERSION 2>> $ERRORLOGFILE | tee -a $LOGFILE
check_if_failed $_ # check for success
# now, the rpms
cd $XIMS_BOX_DIR/rpms
mv xims-box xims-box-$BOX_VERSION
tar -czf $XIMS_BOX_BASE_NAME-rpms-$BOX_VERSION.$XIMS_BOX_FEXTENSION xims-box-$BOX_VERSION 2>> $ERRORLOGFILE | tee -a $LOGFILE
check_if_failed $_ # check for success

# give feedback
echo "Done!" | tee -a $LOGFILE
echo | tee -a $LOGFILE

#### move files to BUILD_TARGET

# process BUILD_TARGET in order to allow relative paths too
StartString=${BUILD_TARGET:0:1}
if [ "$StartString" != "/" ]; then
    BUILD_TARGET="$SCRIPTPATH/$BUILD_TARGET"
fi

mv $XIMS_BOX_DIR/debs/*.$XIMS_BOX_FEXTENSION $BUILD_TARGET 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
mv $XIMS_BOX_DIR/rpms/*.$XIMS_BOX_FEXTENSION $BUILD_TARGET 2>> $ERRORLOGFILE
check_if_failed $_ # check for success
# clean
rm -rf $XIMS_BOX_DIR

#### clean up, if said so
if [ "$REMOVE_BUILD_DIR" == "yes" ]; then
    rm -rf $BUILD_DIR
    rm -rf $RPM_BUILD_ROOT/SPECS/*
    rm -rf $RPM_BUILD_ROOT/RPMS/i386/*
    rm -rf $RPM_BUILD_ROOT/BUILD/*
    echo "Removed '$BUILD_DIR' as I have been told so!" | tee -a $LOGFILE
else
    echo "Kept '$BUILD_DIR' as I have been told so!" | tee -a $LOGFILE
fi
echo | tee -a $LOGFILE

{ cat <<OUTPUT
**********************************************

BUILD COMPLETE !
   Placed '*.tar.gz'-files into directory: '$BUILD_TARGET'


**********************************************
OUTPUT
} | tee -a $LOGFILE

exit 0
## vim: set bg=dark sts=4 ts=4 et ai :
