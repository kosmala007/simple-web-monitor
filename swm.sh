#!/bin/bash

package="Simple Web Monitor"
subject="$package - danger - $domain !!!"
risk=0
statements=''

domain=''
recipients=''

# catch arguments
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "$package"
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
                recipients=$1
            fi
            shift
            ;;
    esac
done

# check website http status
httpResponse=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $domain)
httpStatus=$(echo $httpResponse | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
if [ $httpStatus -ne "200" ] ; then
    statements+=$'Critical https status code: '$httpStatus$'\n\n'
    echo "Critical https status code: $httpStatus"
    risk=1
fi

# check website response size
responseSize=$(echo $httpResponse | wc -c)
if [ $responseSize -lt 512 ] ; then
    statements+=$'Critical website size: '$(echo $responseSize | numfmt --to=si)$'\n\n'
    echo "Critical website size: "$(echo $responseSize | numfmt --to=si)
    risk=1
fi

# send notify
if [ "$risk" -eq "1" ] ; then

fi
