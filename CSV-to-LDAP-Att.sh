#!/bin/bash

#Author: Brenden Wood
#The staff directory intranet page pulls phone numbers from LDAP attributes of users.
#Phone numbers updates were given to us in a spreadsheet and manually updated one by one
#This script pulls the numbers and usernames from a CSV file and updates LDAP.

#LDAP Server and OU variables.

LDAPserver="ldap.nat.internal"
OfficeDivision="NAT_OFF"

#Create arrays from each column of CSV file 

CSVfile=NumbersToUpdate.csv

ExtAttr=( $(cut -d ',' -f2 $CSVfile) )
mobileAttr=( $(cut -d ',' -f3 $CSVfile) )
usernameAttr=( $(cut -d ',' -f1 $CSVfile) )

#Clear any existing LDIF files in working directroy of script before starting
rm *.ldif

printf "\nWould you like to update mobile numbers? (y/n): "
read updatemobile

if [ $updatemobile == "y" ]
then
	printf "\n\nUpdating Mobile Numbers in LDAP...\n\n\n"

	for ((i=0;i<${#usernameAttr[@]};i++))
	do
		echo ${usernameAttr[$i]}
		echo ${mobileAttr[$i]}
		printf "\ndn: cn=${usernameAttr[$i]},ou=Active,ou=Users,ou=$OfficeDivision,o=IEAUST" >> LDAPChangeMobile.ldif
		printf "\nchangetype: modify\nreplace: mobile\nmobile: ${mobileAttr[$i]} \n\n-\n" >> LDAPChangeMobile.ldif 
	
		#The -n option simulates LDAP change without actually making change. For testing.
		ldapmodify -n -f LDAPChangeMobile.ldif && > LDAPChangeMobile.ldif

	done
fi

printf "\nWould you like to update extension numbers? (y/n): "
read UpdateExt

if [ $UpdateExt == "y" ]
then   
        printf "\n\nUpdating Extension Numbers in LDAP...\n\n\n"

        for ((i=0;i<${#usernameAttr[@]};i++))
        do
                echo ${usernameAttr[$i]}
                echo ${ExtAttr[$i]}
                printf "\ndn: cn=${usernameAttr[$i]},ou=Active,ou=Users,ou=$OfficeDivision,o=IEAUST" >> LDAPChangeExt.ldif
                printf "\nchangetype: modify\nreplace: mobile\nmobile: ${ExtAttr[$i]} \n\n-\n" >> LDAPChangeExt.ldif

                #The -n option simulates LDAP change without actually making change. For testing.
                ldapmodify -n -f LDAPChangeExt.ldif && > LDAPChangeExt.ldif

        done
fi

