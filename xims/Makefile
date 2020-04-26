#
# XIMS Makefile
#
# Supports the following targets:
#
#   all       - default target checks requirements
#   install   - installs the XIMS system
#   test      - runs the test suite
#   config    - updates XIMS config
#
# See INSTALL for details.
#

# Set the location of Perl.
PERL = /usr/bin/perl

#########################
# build rules           #
#########################

all		: check check_done

check_done		: 

	@echo ===========================================================
	@echo
	@echo You may now proceed as superuser to
	@echo \"make install\" to install any needed Perl modules,
	@echo set up the XIMS database and the basic XIMS configuration.
	@echo
	@echo ===========================================================
	@echo

install		: cpan db setup defaulttestconf done

done		: 

	@echo
	@echo ===========================================================
	@echo
	@echo Initial XIMS setup complete.
	@echo Please \(re\)start apache and check for errors.
	@echo You may then proceed with \"make test\" to run the
	@echo test suite
	@echo
	@echo ===========================================================
	@echo
	@touch done

##########################
# config rules           #
##########################

config		:
	$(PERL) sbin/xims_setup.pl -c

##########################
# installation rules     #
##########################

cpan 		:
	cpanm --skip-satisfied < perl.deps

patch_modules 		:
	$(PERL) tools/install/patch_modules.pl

db		:
	$(PERL) tools/install/setup_db.pl

setup 		:
	$(PERL) sbin/xims_setup.pl

defaulttestconf    :
	$(PERL) t/ximstest.pl -c


##########################
# test rules             #
##########################
TEST_VERBOSE=0

test		:
	cd t; $(PERL) ./ximstest.pl; cd ..

##########################
# clean rules            #
##########################

clean 		:
	-rm -f done
	-rm -f t/lib/XIMS/.ximstest.conf
	-rm -f t/debug.log
	-rm -f sql/setup_db.log
