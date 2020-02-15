#!/bin/bash

domain='https://admin.com/'
statements=''

## check website http status
httpResponse=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $domain)
httpStatus=$(echo $httpResponse | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
if [ $httpStatus -ne "200" ] ; then
    statements+=$'Critical https status code: '$httpStatus$'\n\n'
    echo "Critical https status code: $httpStatus"
fi

## check website response size
responseSize=$(echo $httpResponse | wc -c)
if [ $responseSize -lt 512 ] ; then
    statements+=$'Critical website size: '$(echo $responseSize | numfmt --to=si)$'\n\n'
    echo "Critical website size: "$(echo $responseSize | numfmt --to=si)
fi
