#!/bin/env bash

CURRENT_MACS=$(nmap -sn -PR 192.168.0.0/24 | awk 'BEGIN{c=0;} /^MAC Address:/{c++;print $3;}')
MACS_FILE=macs.txt
BODY_FILE=$(mktemp)

SMTP_USER=$(perl -MMIME::Base64 -e 'print encode_base64("alert\@geekadmin.es");')
SMTP_PASS=$(perl -MMIME::Base64 -e 'print encode_base64("4l3rt42018");')
SMTP_FROM=alert@geekadmin.es
SMTP_TO=alert@geekadmin.es
SMTP_BODY="${CURRENT_MACS}"
SMTP_DATE="$(date --rfc-2822)"

cat $(dirname $0)/$MACS_FILE | while read L
do
  	set $L
	for MAC in $CURRENT_MACS
        do
          	if [ "$MAC" == "$1" ]
		then
       			echo "- $L" | tee -a $BODY_FILE 
			echo "$(date '+%Y-%m-%d %H:%M:%S') Found $MAC" | tee -a /tmp/$(basename $0).log
       		fi
        done 
done

if [ -s $BODY_FILE ]
then

echo "$(date '+%Y-%m-%d %H:%M:%S') Sending mail"  | tee -a /tmp/$(basename $0).log

(
sleep 2
echo EHLO mail
sleep 1
echo AUTH LOGIN
sleep 1
echo $SMTP_USER
sleep 1
echo $SMTP_PASS
sleep 1
echo MAIL FROM: $SMTP_FROM 
sleep 1 
echo RCPT TO: $SMTP_TO 
sleep 1
echo DATA
sleep 1
echo From: $SMTP_FROM
echo Date: $SMTP_DATE
echo Subject: Connected devices 
cat $BODY_FILE
echo .
sleep 1
echo EXIT
) | openssl s_client -connect geekadmin.es:25 -starttls smtp >/dev/null 2>&1

else

echo "$(date '+%Y-%m-%d %H:%M:%S') No MACs found from file"  | tee -a /tmp/$(basename $0).log

fi

rm $BODY_FILE
