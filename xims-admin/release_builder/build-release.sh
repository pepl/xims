#!/bin/sh

if [ -z "$2" ]; then
    echo "Usage: $0 developer-name release-number"
    exit 1
fi

CVS_RSH=ssh cvs -d:ext:$1@cvs.sf.net:/cvsroot/xims export -D tomorrow -d xims-$2 xims
find -type f -exec chmod 644 {} \;
find -iname "*.pl" -exec chmod 755 {} \;
find xims-$2/tools -name "*.pl" -exec chown 0 {} \;
find xims-$2/tools -name "*.pl" -exec chmod u+s {} \;
find xims-$2/tools -name "*.pl" -exec chmod g+s {} \;
find xims-$2/tools/install -name "*.pl" -exec chmod 754 {} \;
chmod 440 xims-$2/lib/XIMS/Config.pm
chmod 775 xims-$2/www/ximspubroot

mkdir xims-$2/documentation/api
find . -regex ".*xims-$2.lib.*\.pm" -exec sh _build-apidoc.sh {} xims-$2/documentation/api \;

find . -regex ".*xims-$2.documentation.*\.sdbk" -exec sh _build-doc.sh {} \;

cp README.html xims-$2/documentation/api

GZIP=-9 tar zcvf xims-$2.tar.gz xims-$2
rm -rf xims-$2

md5sum xims-$2.tar.gz > xims-$2.tar.gz.md5sum
