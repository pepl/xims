#!/bin/sh
/usr/local/xims/tools/fs_importer.pl -u admin -p _adm1nXP -m /root /usr/local/xims/examples/simple.examplesite.tld
/usr/local/xims/tools/admin/folder_to_objectroot.pl -u admin -p _adm1nXP -s http://simple.examplesite.tld /simple.examplesite.tld
/usr/local/xims/tools/add_departmentlinks.pl -u admin -p _adm1nXP -l index.html,about.html,team.html,contact.html /simple.examplesite.tld
/usr/local/xims/tools/publisher.pl -u admin -p _adm1nXP -r /simple.examplesite.tld
# republish to include the portlet, which is published by now
/usr/local/xims/tools/publisher.pl -u admin -p _adm1nXP /simple.examplesite.tld
