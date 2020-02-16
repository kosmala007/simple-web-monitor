#!/bin/bash

PACKAGE="Simple Web Monitor"

message_statements=''
message_recipients=''
risk=0
domain=''

mailer_host=$(grep MAILER_HOST .env | cut -d '=' -f2)
mailer_port=$(grep MAILER_PORT .env | cut -d '=' -f2)
mailer_user=$(grep MAILER_USER .env | cut -d '=' -f2)
mailer_pass=$(grep MAILER_PASS .env | cut -d '=' -f2)

# catch arguments
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "$PACKAGE"
            echo "Usage: swm [arguments]"
            echo " "
            echo "arguments:"
            echo "-h    show help"
            echo "-d    domain for check"
            echo "-r    recipients (emails) of notifications (separated by comma, e.g. -r m1@example.com,m2@example.com)"
            echo " "
            echo "requipments:"
            echo "* curl"
            echo "* numfmt"
            exit 0
            ;;
        -d)
            shift
            if test $# -gt 0; then
                domain=$1
            fi
            shift
            ;;
        -r)
            shift
            if test $# -gt 0; then
                message_recipients=$1
            fi
            shift
            ;;
    esac
done

# check .env var
if [ -z "$mailer_host" ] || [ -z "$mailer_port" ] || [ -z "$mailer_user" ] || [ -z "$mailer_pass" ]; then
    echo "Error - missing var in .env file, see .env.dist"
    exit 0
fi

# check required arguments
if [ -z "$domain" ] || [ -z "$message_recipients" ]; then
    echo "Error - missing arguments. See --help"
    exit 0
fi

# check website http status
http_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $domain)
http_status=$(echo $http_response | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
if [ $http_status -ne "200" ] ; then
    message_statements+=$'Critical https status code: '$http_status$'\n\n'
    echo "Critical https status code: $http_status"
    risk=1
fi

# check website response size
response_size=$(echo $http_response | wc -c)
if [ $response_size -lt 512 ] ; then
    message_statements+=$'Critical website size: '$(echo $response_size | numfmt --to=si)$'\n\n'
    echo "Critical website size: "$(echo $response_size | numfmt --to=si)
    risk=1
fi

# send notify
if [ "$risk" -eq "1" ] ; then
    message_subject="$PACKAGE | threats found in: $domain !!!"
    content=$'From: <'$mailer_user$'> \nTo: <'$message_recipients$'> \nContent-Type: text/plain;charset=utf-8 \nSubject: '$message_subject$'\n\n'
    content+="$message_statements"

    curl --connect-timeout 15 -v --insecure "smtp://$mailer_host:$mailer_port" \
        -u "$mailer_user:$mailer_pass" \
        --mail-from "$mailer_user" \
        $(echo "${message_recipients}" | tr ', ' '\n' | xargs -r -n1 printf '--mail-rcpt %s ') \
        -T - \
        --ssl \
        <<< "$content"
fi
