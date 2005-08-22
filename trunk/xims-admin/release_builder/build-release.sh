#!/bin/sh

if [ -z "$2" ]; then
    echo "Usage: $0 developer-name release-number"
    exit 1
fi

CVS_RSH=ssh cvs -d:ext:$1@cvs.sf.net:/cvsroot/xims export -D tomorrow -d xims-$2 xims
CVS_RSH=ssh cvs -d:ext:$1@cvs.sf.net:/cvsroot/xims export -D tomorrow -d xims-$2-contrib xims-contrib
mv xims-$2-contrib/htmlarea3rc1 xims-$2/www/ximsroot/htmlarea
mv xims-$2-contrib/jscalendar-1.0 xims-$2/www/ximsroot/
cd xims-$2
find -type f -exec chmod 644 {} \;
find -iname "*.pl" -exec chmod 755 {} \;
find tools -name "*.pl" -exec chown 0 {} \;
find bin -name "*.pl" -exec chmod 6755 {} \;
find sbin -name "*.pl" -exec chmod 700 {} \;
find tools/install -name "*.pl" -exec chmod 700 {} \;
chmod 440 conf/ximsconfig.xml
chmod 6775 www/ximspubroot

cd ..
mkdir xims-$2/documentation/api
find . -regex ".*xims-$2.lib.*\.pm" -exec sh _build-apidoc.sh {} xims-$2/documentation/api \;
find . -regex ".*xims-$2.documentation.*\.sdbk" -exec sh _build-doc.sh {} \;

find xims-$2 -type d -name "originals" | xargs rm -rf

cp README.html xims-$2/documentation/api

GZIP=-9 tar zcvf xims-$2.tar.gz xims-$2
#rm -rf xims-$2
#rm -rf xims-$2-contrib

md5sum xims-$2.tar.gz > xims-$2.tar.gz.md5sum
