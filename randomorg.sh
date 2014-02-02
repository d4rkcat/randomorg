#!/bin/bash

## Randomorg Copyright 2013, rfarage (rfarage@yandex.com)
#
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
#
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License at (http://www.gnu.org/licenses/) for
## more details.

fhelp()
{
	clear
	echo """ 
randomorg - HTTPS Client - Curl unique random strings from random.org using HTTPS for security

	Usage: randomorg -f <format> -l <length> <Options> [in any order]

	Required:
		-f  -  format:
			[an] mixed case alphanumerical
			[ln] lower case alphanumerical
			[un] upper case alphanumerical
			[a]  mixed case alphabetic
			[l]  lower case alphabetic
			[u]  upper case alphabetic
			[n]  numerical
			  				
		-l  -  length of string (characters)
		
	Options:
		-n  -  number of strings
		-o  -  print output to file
		-t  -  use tor proxy (requires torify)
		-q  -  quiet, do not print remaining quota
		-p  -  post randomize with urandom (paranoid)
		-d  -  debug post randomize
		-h  -  this help
		
	Examples: 
		randomorg -f an -l 26	           ~ alphanumeric string, 26 characters
		randomorg -f a -l 14 -n 3 -t       ~ 3 alphabetic strings, 14 characters, use tor proxy
		randomorg -f n -l 8 -q -o byte	   ~ numerical string, 8 characters, quiet and output to file
"""
exit
}

frandomize()
{	
	STRING="${STRING:0:$SLENGTH}"
	if [ $SUPER = 1 ] 2> /dev/null
		then
			if [ $FORMAT = 'n' ]
				then
					RCHARS=$(strings /dev/urandom | grep -o '[2-7]' | head -n 15 | tr -d '\n'; echo)
				else
					RCHARS=$(strings /dev/urandom | grep -o '[3-6]' | head -n 15 | tr -d '\n'; echo)
			fi
			NCNT=${RCHARS:0:1}
			NSTRT=0
	
			while [ $NSTRT -lt 15 ]
				do
					STRING=$(echo $STRING |  sed -e "s/.\{$NCNT\}/&\n/g" | sort -R | tr -d '\n';echo)
					NSTRT=$((NSTRT + 1))
					NCNT=${RCHARS:$NSTRT:1}
				done
	fi
}

LOCATION="Your IP "
COLOR='tput setab'
CNTLENGTH=0
NUM=0
PASSES=1
CNT=1
STRLEN=10

if [ $1 -z ] 2> /dev/null												#Parse command line arguments			
	then
		fhelp
fi
																
ACNT=1
for ARG in $@
	do
		ACNT=$((ACNT + 1))
		case $ARG in "-d")DEBUG=1;;"-p")SUPER=1;;"-h")fhelp;;"--help")fhelp;;"-f")FORMAT=$(echo $@ | cut -d " " -f $ACNT);;"-t")TOR="torify";LOCATION="Tor Node ";;"-l")LENGTH=$(echo $@ | cut -d " " -f $ACNT);;"-n")PASSES=$(echo $@ | cut -d " " -f $ACNT);;"-q")QUIET="on";;"-o")OUTFILE=$(echo $@ | cut -d " " -f $ACNT);esac
	done

while [ $CNTLENGTH -lt $LENGTH ]										#Appropriate the right size query for number of characters (length)
	do
		CNTLENGTH=$((CNTLENGTH + 10))
		NUM=$((NUM + 1))
	done
REM=$((CNTLENGTH - LENGTH))												#Trim query so there is never more than 9 characters wasted per query
REM=$((REM * PASSES / 10))
NUM=$((NUM * PASSES))
NUM=$((NUM - REM))
SLENGTH=$((LENGTH * PASSES))

if [ $LENGTH -lt 10 ]  2> /dev/null
	then
		STRLEN=$LENGTH
fi

QUOTA=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com https://www.random.org/quota/?format=plain)
FLENGTH=$((LENGTH * 10 ))
if [ $FORMAT = 'n' ] 2> /dev/null
	then
		FLENGTH=$((FLENGTH / 2))
fi
if [ $QUOTA -lt $FLENGTH ] 2> /dev/null									#Check to make sure we will not go above our remaining quota
	then
		tput setab 1;echo " [*] ERROR: This request will put you above your quota for today, please wait until tomorow or try a smaller query. ";tput setab 9
		exit
fi
if [ $FLENGTH -ge 700000 ] 2> /dev/null
	then
		tput setab 1;echo " [*] ERROR: This request is too much for the server to handle. ";tput setab 9
		exit
fi

case $FORMAT in															#Curl random string with HTTPS
	"an")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&digits=on&upperalpha=on&loweralpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"n")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&digits=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"a")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&upperalpha=on&loweralpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"u")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&upperalpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"l")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&loweralpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"un")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&digits=on&upperalpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
	"ln")STRING=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com "https://www.random.org/strings/?num=$NUM&len=$STRLEN&unique=on&digits=on&loweralpha=on&format=plain&rnd=new" | tr -d '\n'; echo);if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: Downloaded content: ";$COLOR 9;echo $STRING;echo;fi;frandomize;if [ $DEBUG = "1" ] 2> /dev/null ;then $COLOR 1;echo " [*] DEBUG: After randomization: ";$COLOR 9;echo $STRING;fi;;
esac
SRTPLACE=0
while [ $CNT -le $PASSES ]
	do
		if [ $OUTFILE -z ] 2> /dev/null
			then
				echo
				echo "${STRING:$SRTPLACE:$LENGTH}"
			else
				echo
				echo "${STRING:$SRTPLACE:$LENGTH}" > $OUTFILE
		fi
		SRTPLACE=$((SRTPLACE + LENGTH))
		CNT=$((CNT + 1))
	done
	
	
if [ $QUIET = "on" ] 2> /dev/null
	then																#Display remaining quota
		exit
	else
		QUOTA2=$($TOR curl -s -A randomorg.sh-rfarage@yandex.com https://www.random.org/quota/?format=plain)
		DIFF=$((QUOTA - QUOTA2))
		if [ $OUTFILE -z ] 2> /dev/null
			then
				echo;echo ""$LOCATION"Quota remaining: $QUOTA2  Used for this request: $DIFF"
			else
				echo "" >> $OUTFILE;echo ""$LOCATION"Quota remaining: $QUOTA2  Used for this request: $DIFF" >> $OUTFILE
		fi
fi
