#!/bin/bash

RESTART="./manual.sh"
HEALTHCHECK="./healthcheck.sh"
echo '#############################GET REQUEST##########################'
TASKID=$(curl -X POST $postLink/api/crawler/| awk '{ print substr( $0, 13,  length($0)-15)}')
HEALTH=$(curl $postLink/api/celery/$TASKID) && export HEALTH=$(echo $HEALTH | awk '{ print $3;}') && export HEALTH="${HEALTH#?}"
echo '#############################GET REQUEST##########################'
echo ''
if [ $HEALTH = 'SUCCESSFUL"' ]; then CHECK=0; fi
if [ $HEALTH = 'PENDING"' ]; then CHECK=1; fi
if [ $HEALTH = 'STARTED"' ]; then CHECK=2; fi
if [ $HEALTH = 'FAILURE"' ]; then CHECK=3; fi
echo $HEALTH
echo status code is now [$CHECK]
echo code- [0] STATUS IS SUCCESSFUL
echo code- [1] STATUS IS PENDING
echo code- [2] STATUS IS STARTED
echo code- [3] STATUS IS FAILURE
echo ''
case $CHECK in
    0) curl -i -X POST $postLink/api/celery/$TASKID; echo "Crawler was triggered"; sleep 4;
     ;;

    1)  until [ $HEALTH = 'FAILURE"' ]; \
        do HEALTH=$(curl $postLink/api/celery/$TASKID) && export HEALTH=$(echo $HEALTH | awk '{ print $3;}') && HEALTH="${HEALTH#?}" ;\
        sleep 4; done; curl -X POST --data-urlencode "payload={\"channel\": \"#testnotification\", \"username\": \"ERROR\", \"text\": \"CRAWREL IS FAILURE\", \"icon_emoji\": \":ghost:\"}" \
        $notificationLink; sleep 14400; (exec "$HEALTHCHECK");
            ;;
    2) until [ $HEALTH = 'FAILURE"' ]; \
        do HEALTH=$(curl $postLink/api/celery/$TASKID) && export HEALTH=$(echo $HEALTH | awk '{ print $3;}') && HEALTH="${HEALTH#?}" ;\
        sleep 4; ECHO $HEALTH; done; curl -X POST --data-urlencode "payload={\"channel\": \"#testnotification\", \"username\": \"ERROR\", \"text\": \"CRAWREL IS FAILURE\", \"icon_emoji\": \":ghost:\"}" \
        $notificationLink; sleep 14400; (exec "$HEALTHCHECK");
        ;;
#         sleep 14400;
    3) curl -X POST --data-urlencode "payload={\"channel\": \"#testnotification\", \"username\": \"ERROR\", \"text\": \"CRAWREL IS FAILURE\", \"icon_emoji\": \":ghost:\"}" \
        $notificationLink; sleep 14400; (exec "$HEALTHCHECK");
           ;;
    *) sleep 1; (exec "$HEALTHCHECK");
    ;;

esac
