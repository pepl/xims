#!/bin/sh

patch -p0 ../../sql/Pg/db.sql db.sql7.2.diff && patch -p0 ../../sql/Pg/nested_set_triggers_and_functions.sql nested_set_triggers_and_functions.sql7.2.diff
