#!/bin/sh
#echo 'xsltproc --param shade.verbatim "1" --stringparam html.stylesheet http://xims.info/stylesheets/docbook.css -o `dirname $1`/`basename $1 sdbk`html docbook/xhtml/docbook.xsl $1' > d.sh
NEWNAME=`echo $1 | sed -e s/sdbk/html/`
xsltproc --stringparam html.stylesheet http://xims.info/stylesheets/docbook.css -o $NEWNAME docbook/xhtml/docbook.xsl $1
perl -pi -e 's#.sdbk#.html#g' $NEWNAME
rm -f $1
#find . -regex ".*$1.documentation.*\.sdbk" -exec rm -f {} \;
