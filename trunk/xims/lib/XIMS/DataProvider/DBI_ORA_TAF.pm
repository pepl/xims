package XIMS::DataProvider::DBI_ORA_TAF;

use XIMS;
use DBD::Oracle(qw(:ora_fail_over));

# add ora_taf_function=XIMS::DataProvider::DBI_ORA_TAF::handle_taf 
# into Config/General/DBDOpt (ximsconfig.xml)

# taken and modified from the DBD::Oracle manual
sub handle_taf {
    my ($fo_event,$fo_type, $dbh) = @_;
    if ($fo_event == OCI_FO_BEGIN) {
        XIMS::Debug(2,  " Instance Unavailable Please stand by!! \n");
        XIMS::Debug(2, sprintf(" Your TAF type is %s \n",
                               (($fo_type==OCI_FO_NONE) ? "NONE"
                                :($fo_type==OCI_FO_SESSION) ? "SESSION"
                                :($fo_type==OCI_FO_SELECT) ? "SELECT"
                                : "UNKNOWN!")));
    }
    elsif ($fo_event == OCI_FO_ABORT){
        XIMS::Debug(2,  " Failover aborted. Failover will not take place.\n");
    }
    elsif ($fo_event == OCI_FO_END){
        XIMS::Debug(2, sprintf(" Failover ended ... Resuming your %s\n",(($fo_type==OCI_FO_NONE) ? "NONE"
                                                                         :($fo_type==OCI_FO_SESSION) ? "SESSION"
                                                                         :($fo_type==OCI_FO_SELECT) ? "SELECT"
                                                                         : "UNKNOWN!")));
        # re-set session options
        foreach ( split(";", XIMS::DBSessionOpt()) ) {
            $dbh->do("$_");
        }
    }
    elsif ($fo_event == OCI_FO_REAUTH){
        XIMS::Debug(2,  "Failed over user. Resuming services\n");
    }
    elsif ($fo_event == OCI_FO_ERROR){
        XIMS::Debug(2,  "Failover error ...\n");
        sleep 5;                 # sleep before having another go
        return OCI_FO_RETRY;
    }
    else {
        XIMS::Debug(2, sprintf("Bad Failover Event: %d.\n",  $fo_event));
    }
    return 0;
}

1;
