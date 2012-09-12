#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 release-number"
    exit 1
fi

svn export https://svn.sourceforge.net/svnroot/xims/trunk/xims xims-$1
svn export https://svn.sourceforge.net/svnroot/xims/trunk/xims-contrib xims-$1-contrib
mv xims-$1-contrib/htmlarea3rc1 xims-$1/www/ximsroot/htmlarea
mv xims-$1-contrib/jscalendar-1.0 xims-$1/www/ximsroot/
cd xims-$1
find -type f -exec chmod 644 {} \;
find -iname "*.pl" -exec chmod 755 {} \;
find tools -name "*.pl" -exec chown 0 {} \;
find bin -name "*.pl" -exec chmod 6755 {} \;
find sbin -name "*.pl" -exec chmod 700 {} \;
find tools/install -name "*.pl" -exec chmod 700 {} \;
chmod 440 conf/ximsconfig.xml
chmod 6775 www/ximspubroot

cd ..
mkdir xims-$1/documentation/api
find . -regex ".*xims-$1.lib.*\.pm" -exec sh _build-apidoc.sh {} xims-$1/documentation/api \;
find . -regex ".*xims-$1.documentation.*\.sdbk" -exec sh _build-doc.sh {} \;

find xims-$1 -type d -name "originals" | xargs rm -rf

cp README.html xims-$1/documentation/api

GZIP=-9 tar zcvf xims-$1.tar.gz xims-$1
#rm -rf xims-$1
#rm -rf xims-$1-contrib

md5sum xims-$1.tar.gz > xims-$1.tar.gz.md5sum
