#!/bin/bash
# This is just an example, adapt to your needs.
export XIMS_HOME=/opt/xims
export PERLBREW_ROOT=/opt/perl5
source ${PERLBREW_ROOT}/etc/bashrc
cd "${XIMS_HOME}/lib"
start_server --port 127.0.0.1:5000 -- starman --workers 12 xims.psgi > ${XIMS_HOME}/logs/error_log 2>&1 
