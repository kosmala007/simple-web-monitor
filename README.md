# Simple Web Monitor

Simple Web Monitor it's easy program for monitoring your domain.

When monitor detect risk:

* http status diffrent from 200
* response size lower than 512 bytes

Program will send you an email.

## How it use

1. Check help ``./swm.hs --help``
1. Create ``.env`` file based on ``.env.dis`` with credentials form mailer
    * important - don't use quotation marks
1. Run script manuallny eg. ``./swm.sh -d https://github.com/404 -r your@email.com``
    * When you get the email everything is fine
1. Add script to your crontab
    * usefull online cron schedule expressions tester - [https://crontab.guru/](https://crontab.guru/)

## Required programs in OS

* curl
* numfmtm
* cut
* tr
* sed
* wc
* crontab
