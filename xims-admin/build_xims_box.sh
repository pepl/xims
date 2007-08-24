#!/bin/sh
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
# debug
#set -xv

function usage() {
	cat <<MSG_USAGE
 
  USAGE
    interactive mode:
      build_xims_box.sh -o {clean|keep}
 
    non interactive (e.g. for a cron-job):
      build_xims_box.sh -n -o {clean|keep} [-v <VERSION>] -b <BUILD_TARGET>
    
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

MSG_USAGE
	exit 1
}

function end_script() {
	# print error and exit
	echo -n "'$1'-build failed! Cleaning up and exiting ..."
	rm -rf $BUILD_DIR $RPM_BUILD_ROOT >> /dev/null 2>&1
	echo "Done! Bye, bye!"
	exit 1
}

function int_err_script() {
	echo
	echo "**********************************************"
	echo 
	echo "Ups, caught SIGINT or an error has occurred!"
	echo -n "Cleaning up and exiting ..."
	rm -rf /tmp/$BUILD_SYSTEM_FILE $BUILD_DIR $RPM_BUILD_ROOT >> /dev/null 2>&1
	echo "Done! Bye, bye!"
	echo
	exit 1
}

# provide a 'catch-all' for possible errors and SIGINTs
trap 'int_err_script' ERR SIGINT

# run interactively per default
INTERACTIVE="yes"

# we do not show 'getopts' errors
OPTERR="0"
# get options
while getopts "b:no:v:*" options; do
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
	# when there is no XIMS_VERSION, we put a
	# fiction-version of '0.007' ;-)
	if [ "$XIMS_VERSION" == '' ]; then
		XIMS_VERSION="0.007"
	fi
else
	# if run interactively prompt for the required information
	read -p 'Where should I place the resulting *.tar.gz files? ' BUILD_TARGET
	read -p 'Which version should I use for the xims deb/rpm packages? ' XIMS_VERSION
fi

#### to here, we should have all required information to get the script run
# nevertheless, have a last check, to be on the save side anyway
if [ "$BUILD_TARGET" == '' -o \
     "$REMOVE_BUILD_DIR" == '' -o \
     "$XIMS_VERSION" == '' ]; then
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
BUILD_SYSTEM_FILE="xims_box_build_system.tar.gz"
XIMS_BOX_BUILD_SYSTEM_URI="http://downloads.sourceforge.net/xims/$BUILD_SYSTEM_FILE"

BUILD_DIR="/tmp/xims_box_build_system"

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

############################################################
#
# You must not edit anything below here!
#
############################################################

# clean up from previous builds
if [ -e /tmp/$BUILD_SYSTEM_FILE ]; then
	# remove, if there is another downloaded file
	rm -rf /tmp/$BUILD_SYSTEM_FILE
fi
if [ -e $BUILD_DIR ]; then
	# remove, if build dir already exists
	rm -rf $BUILD_DIR
fi

#### get and prepare build system
echo "Getting XIMS-Box build system from sf.net ..."
cd /tmp
wget "$XIMS_BOX_BUILD_SYSTEM_URI"
echo "Done! Start extracting ..."
tar -xzf $BUILD_SYSTEM_FILE
# remove tar-file again
rm -f $BUILD_SYSTEM_FILE
echo "Done! Getting and preparing the latest XIMS dev snapshot ..."
# cd to the xims place
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package
# get snapshot
svn checkout --quiet $XIMS_SVN_BRANCH xims
# add xims-contrib and put htmlarea link
cd $DEB_XIMS_DIR
svn checkout --quiet $XIMS_CONTRIB_SVN_BRANCH xims-contrib
# move contents to the right place
mv xims-contrib/* $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximsroot/
# clean up
rm -rf xims-contrib
# make the htmlarea symlink
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximsroot/
ln -s htmlarea3rc1 htmlarea
# put examplesite from the xims_box_build_system to ximspubroot
mv $DEB_XIMS_DIR/examplesite $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/www/ximspubroot/
# cd to xims-home
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims
# remove '.svn' dirs
find ./ -name '.svn' -print0 | xargs -0 rm -rf
# we build the xims-box with the according default-data, thus change the
# switch in 'defaultdata.sql'
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/sql/Pg/
perl -pni -e 's/^(\\i defaultdata-content\.sql)/--$1/' defaultdata.sql
perl -pni -e 's/^--(\\i xims-box-defaultdata-content\.sql)/$1/' defaultdata.sql
# cd to xims-home
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims
# replace headers of perl files of the xims-distri to fit xims-box needs
find ./ -name '*.pl' -print0 | xargs -0 perl -pni -e 's|^#!/usr/bin/perl( ?)|#!/opt/xims-package/ximsperl/bin/perl$1|'
# replace ximsconfig.xml
mv $DEB_XIMS_DIR/ximsconfig.xml $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/conf/
cd $DEB_XIMS_DIR/deb/debian/opt/xims-package/xims/conf
# adjust XIMS_HOME env-variable in ximshttpd.conf
perl -pni -e 's|^#(PerlSetEnv\sXIMS_HOME\s).*$|$1/opt/xims-package/xims|' ximshttpd.conf
# adjust ximsstartup.pl
perl -pni -e 's/^#\s(DBI\->install_driver\("Pg"\);).*$/$1/' ximsstartup.pl
perl -pni -e 's/^#\s(use AxKit \(\);).*$/$1/' ximsstartup.pl
perl -pni -e 's|^(use\slib\sqw\()[^)]+(\))|$1 /opt/xims-package/xims/lib $2|' ximsstartup.pl

# give some feedback again 
echo "Done!"
echo "**********************************************"
echo 
echo "Start building debian packages ..."

#### build debs
# build apache-xims
cd $DEB_APACHE_DIR/deb
dpkg-deb --build debian apache-xims_1.3.37-1_i386.deb
# test if build succeeded
if [ $? -ne 0 ]; then
	end_script "apache_xims (deb)"
fi
# build libxml2-xims
cd $DEB_LIBXML2_DIR/deb
dpkg-deb --build debian libxml2-xims_2.6.27-1_i386.deb
if [ $? -ne 0 ]; then
	end_script "libxml2_xims (deb)"
fi
# build libxslt-xims
cd $DEB_LIBXSLT_DIR/deb
dpkg-deb --build debian libxslt-xims_1.1.19-1_i386.deb
if [ $? -ne 0 ]; then
	end_script "libxslt_xims (deb)"
fi
# build perl-xims
cd $DEB_PERL_DIR/deb
dpkg-deb --build debian perl-xims_5.8.8-1_i386.deb
if [ $? -ne 0 ]; then
	end_script "perl_xims (deb)"
fi
## finally build xims
# adjust version first (XIMS_VERSION)
cd $DEB_XIMS_DIR/deb/debian/DEBIAN
perl -pni -e "s/^Version: [^-]+-1/Version: $XIMS_VERSION-1/" control
cd $DEB_XIMS_DIR/deb
dpkg-deb --build debian xims_$XIMS_VERSION-1_i386.deb
if [ $? -ne 0 ]; then
	end_script "xims (deb)"
fi

echo "Done!"
echo "**********************************************"
echo 
echo "Start building rpm packages ..."

#### build rpms

## this is really bad on systems where other rpms are built the default
## rpm-way :-O !
# remove existent 'rpm' dir in '/usr/src' (as it is the Debian default name)
if [ -e /usr/src/rpm ]; then
	rm -rf /usr/src/rpm
fi
# move xims-box provided rpm-build system to /usr/src (prepare rpm-build-root)
mv $BUILD_DIR/redhat $RPM_BUILD_ROOT
# prepare rpm build system (copying files)
cp -r $DEB_APACHE_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/apache_xims-root/
cp -r $DEB_LIBXML2_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/libxml2_xims-root/
cp -r $DEB_LIBXSLT_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/libxslt_xims-root/
cp -r $DEB_PERL_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/perl_xims-root/
cp -r $DEB_XIMS_DIR/deb/debian/opt $RPM_BUILD_ROOT/BUILD/xims-root/
# prepare for build (adjust xims-version)
cd $RPM_BUILD_ROOT/SPECS
perl -pni -e "s/^Version: .+$/Version: $XIMS_VERSION/" xims-1.spec
find -name '??*' -print0 | xargs -0 rpmbuild --quiet -bb >> /dev/null 2>&1
# end if unsuccessful
if [ $? -ne 0 ]; then
	end_script "RPM"
fi

echo "Done!"
echo "**********************************************"
echo 
echo "Collect and 'tar' packages ..."
#### collect debs/rpms
# debs first ;-)
mv $DEB_APACHE_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/
mv $DEB_LIBXML2_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/
mv $DEB_LIBXSLT_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/
mv $DEB_PERL_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/
mv $DEB_XIMS_DIR/deb/*.deb $XIMS_BOX_DIR/debs/xims-box/
# now the rpms
mv $RPM_BUILD_ROOT/RPMS/i386/*.rpm $XIMS_BOX_DIR/rpms/xims-box/
#### create the 2 'tar.gzs' ;-)
# again, debs first
cd $XIMS_BOX_DIR/debs
tar -czf $XIMS_BOX_BASE_NAME-debs.$XIMS_BOX_FEXTENSION xims-box >> /dev/null 2>&1
# now, the rpms
cd $XIMS_BOX_DIR/rpms
tar -czf $XIMS_BOX_BASE_NAME-rpms.$XIMS_BOX_FEXTENSION xims-box >> /dev/null 2>&1

# give feedback
echo "Done!"
echo 

#### move files to BUILD_TARGET
mv $XIMS_BOX_DIR/debs/*.$XIMS_BOX_FEXTENSION $BUILD_TARGET
mv $XIMS_BOX_DIR/rpms/*.$XIMS_BOX_FEXTENSION $BUILD_TARGET
# clean
rm -rf $XIMS_BOX_DIR

#### clean up, if said so
if [ "$REMOVE_BUILD_DIR" == "yes" ]; then
	rm -rf $BUILD_DIR
	rm -rf $RPM_BUILD_ROOT/SPECS/*
	rm -rf $RPM_BUILD_ROOT/RPMS/i386/*
	rm -rf $RPM_BUILD_ROOT/BUILD/*
	echo "Removed '$BUILD_DIR' as I have been told so!"
else
	echo "Kept '$BUILD_DIR' as I have been told so!"
fi
echo

echo "**********************************************"
echo "*                                            *"
echo "*  BUILD COMPLETE !                          *"
echo "*                                            *"
echo "*  Placed '*.tar.gz'-files into directory:   *"
echo "*    '$BUILD_TARGET'"
echo "*                                            *"
echo "**********************************************"

exit 0
