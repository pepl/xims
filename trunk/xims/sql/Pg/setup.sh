#!/bin/sh
# $Id$
################################################################################
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

decide() {
    while true 
        do
            echo -n "$1 (Yes|No)"
            read input
            case $input in
                [Yes]*) return 0;;
                [No]*)   return 1;; 
                *) echo "answer Yes or No" 
            esac
        done
}

# create users, temporarly
create_users() {
    psql      -U $PG_SUPER_USER           template1     < $BASE/users.sql
}


create_database() {
   dropdb     -U $PG_SUPER_USER           $XIMS_DB_NAME

   createdb   -U $XIMS_DB_OWNER -E latin1 $XIMS_DB_NAME

   createlang -U $PG_SUPER_USER plpgsql   $XIMS_DB_NAME 

   psql       -U $XIMS_DB_OWNER           $XIMS_DB_NAME < $BASE/create.sql
   
}

insert_defaultdata() {
   psql       -U $XIMS_DB_OWNER           $XIMS_DB_NAME < $BASE/defaultdata.sql
}


# set some variables

BASE=`dirname $0`

[ $EDITOR ]            || EDITOR="vi"

# find username of the postgres superuser
# these are names i ran across up to now
for name in "postmaster" "pgsql" "postgres"
    do 
        if grep -q "$name" /etc/passwd
            then PG_SUPER_USER=$name
        fi
done

[ $PG_SUPER_USER ] || { echo "cant find postgres superuser in /etc/passwd";
                        echo "please set it in PG_SUPER_USER as environment";
                        exit 1;
                      }

[ $XIMS_DB_NAME ]      || XIMS_DB_NAME="xims"

[ $XIMS_DB_OWNER ]     || XIMS_DB_OWNER="xims"
[ $XIMS_DB_OWNER_PWD ] || XIMS_DB_OWNER_PWD="xims"

[ $XIMSDB_ADMIN ]      || XIMS_DB_ADMIN="ximsadm"
[ $XIMS_DB_ADMIN_PWD ] || XIMS_DB_ADMIN_PWD="ximsadm"

[ $XIMS_DB_USER ]      || XIMS_DB_USER="ximsrun"
[ $XIMS_DB_USER_PWD ]  || XIMS_DB_USER_PWD="ximsrun"

clear
cat << SCREEN1

               -  -  - - ---[ DataBase - Setup ]---  - -  -  -
                                        
                     @@@  @@@  @@@  @@@@@@@@@@    @@@@@@   
                     @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@   
                     @@!  !@@  @@!  @@! @@! @@!  !@@       
                     !@!  @!!  !@!  !@! !@! !@!  !@!       
                      !@@!@!   !!@  @!! !!@ @!@  !!@@!!    
                       @!!!    !!!  !@!   ! !@!   !!@!!!   
                      !: :!!   !!:  !!:     !!:       !:!  
                     :!:  !:!  :!:  :!:     :!:      !:!   
                      ::  :::   ::  :::     ::   :::: ::   
                      :   ::   :     :      :    :: : :    
    
     This is designed to be run with 'local' connections set to 'trust', 
            which is the default on a fresh install of postgres. 
                     You should change that later on.  

          WE WILL DROP AND CREATE THE RELEVANT USERS, DATABASES, 
       EVENTUALLY EVEN GO ON VACATION TO VENICE WITH YOUR GIRLFRIEND. 

                  YOU HAVE A GOOD CHANCE TO LOOSE DATA!!!!

SCREEN1

decide "Continue?" || exit 1

#decide "Edit pg_hba.conf?" && edithbaconf   
cat << SCREEN3

               -  -  - - ---[ DataBase - Setup ]---  - -  -  -
                                        
                     @@@  @@@  @@@  @@@@@@@@@@    @@@@@@   
                     @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@   
                     @@!  !@@  @@!  @@! @@! @@!  !@@       
                     !@!  @!!  !@!  !@! !@! !@!  !@!       
                      !@@!@!   !!@  @!! !!@ @!@  !!@@!!    
                       @!!!    !!!  !@!   ! !@!   !!@!!!   
                      !: :!!   !!:  !!:     !!:       !:!  
                     :!:  !:!  :!:  :!:     :!:      !:!   
                      ::  :::   ::  :::     ::   :::: ::   
                      :   ::   :     :      :    :: : :    
    
     We will now drop the users xims, ximsadm and ximsrun if they exist,
   then (re)create them, the user xims will be granted to create databases.

             All users will have default passwords for the moment, 
             so you don't get promted for them for further actions. 

                     You most likely want me to do that.

SCREEN3

decide "Drop and (re)create the relevant users?" && create_users

cat << SCREEN4

              -  -  - - ---[ DataBase - Setup ]---  - -  -  -
                                        
                    @@@  @@@  @@@  @@@@@@@@@@    @@@@@@   
                    @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@   
                    @@!  !@@  @@!  @@! @@! @@!  !@@       
                    !@!  @!!  !@!  !@! !@! !@!  !@!       
                     !@@!@!   !!@  @!! !!@ @!@  !!@@!!    
                      @!!!    !!!  !@!   ! !@!   !!@!!!   
                     !: :!!   !!:  !!:     !!:       !:!  
                    :!:  !:!  :!:  :!:     :!:      !:!   
                     ::  :::   ::  :::     ::   :::: ::   
                     :   ::   :     :      :    :: : :    
    
              I will now drop the database xims if it exists. 

                  YES, THAT MEANS ALL DATA WILL BE GONE!

            After that a new database and all objects within will 
                         be created by the user xims.
 
             YOU NOW HAVE A REAL GOOD CHANCE TO LOOSE DATA!!!!

SCREEN4

decide "drop and recreate database?" && create_database

cat << SCREEN5

              -  -  - - ---[ DataBase - Setup ]---  - -  -  -
                                        
                    @@@  @@@  @@@  @@@@@@@@@@    @@@@@@   
                    @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@   
                    @@!  !@@  @@!  @@! @@! @@!  !@@       
                    !@!  @!!  !@!  !@! !@! !@!  !@!       
                     !@@!@!   !!@  @!! !!@ @!@  !!@@!!    
                      @!!!    !!!  !@!   ! !@!   !!@!!!   
                     !: :!!   !!:  !!:     !!:       !:!  
                    :!:  !:!  :!:  :!:     :!:      !:!   
                     ::  :::   ::  :::     ::   :::: ::   
                     :   ::   :     :      :    :: : :    
    
                    I will now insert the default dataset. 
      It is required for running the tests and for the operation of xims.

     Unless something failed before or you have ...uh... special interests,
     you want me to do that. Note that it must fail if you decided not to
     recrate the database before -- you will mess things up, in this case.
 
SCREEN5

decide "insert default data?" && insert_defaultdata

cat << SCREEN6

              -  -  - - ---[ DataBase - Setup ]---  - -  -  -
                                        
                    @@@  @@@  @@@  @@@@@@@@@@    @@@@@@   
                    @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@   
                    @@!  !@@  @@!  @@! @@! @@!  !@@       
                    !@!  @!!  !@!  !@! !@! !@!  !@!       
                     !@@!@!   !!@  @!! !!@ @!@  !!@@!!    
                      @!!!    !!!  !@!   ! !@!   !!@!!!   
                     !: :!!   !!:  !!:     !!:       !:!  
                    :!:  !:!  :!:  :!:     :!:      !:!   
                     ::  :::   ::  :::     ::   :::: ::   
                     :   ::   :     :      :    :: : :    
    

      Now change the passwords on the dbusers: xims, ximsrun, ximsadm!

                          You'd be a fool not to. 


Thank you, that would be it.


SCREEN6

