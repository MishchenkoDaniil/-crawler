#!/bin/bash
AUTO="./auto.sh"
MANUAL="./manual.sh"
WRONG="./Crawler.sh"
echo '#############################GET REQUEST##########################'
TASKID=$(curl -X POST $postLink/api/crawler/| awk '{ print substr( $0, 13,  length($0)-15)}')
POST=$(curl $postLink/api/celery/$TASKID) && export POST=$(echo $POST | awk '{ print $3;}') && export POST="${POST#?}"
echo '#############################GET REQUEST##########################'
echo ''
echo "Hello it's Trigger Crawler"
TIME=$(date +"%T")
echo "How do you want configure this program? [A]- Automatically; [M] - Manually"
echo "Manually you can set current time"
echo "If Automatically script then script all time checking status (AND triggered) "
#read $SETMODE
case $SETMODE in
    A) (exec "$AUTO");
    ;;
    M) (exec "$MANUAL");
    ;;
    *) (exec "$WRONG");
    ;;
esac
# if [ $MODE = "A" ]; then (exec "$AUTO"); else echo "Please, enter the value correctly "; fi
# if [ $MODE = "M" ]; then (exec "$MANUAL") && echo Time is now: [$TIME]
