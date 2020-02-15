#!/bin/bash

domain='https://admin.com/'

## check website http status
httpResponse=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $domain)
httpStatus=$(echo $httpResponse | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
if [ $httpStatus -ne "200" ] ; then
    echo "Critical https status code: $httpStatus"
fi

## check website response size
responseSize=$(echo $httpResponse | wc -c)
if [ $responseSize -lt 512 ] ; then
    echo "Critical website size: "$(echo $responseSize | numfmt --to=si)
fi
