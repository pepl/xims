#!/bin/sh
perl ./comment2dbk.pl $1 > $2/$(echo $1 | sed -e s#/#-#g | sed -e s#.*lib-## | sed -e s#\.pm##).sdbk

