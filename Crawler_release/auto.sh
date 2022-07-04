#!/bin/bash
RESTART="./auto.sh"
COUNT=0
echo '#############################GET REQUEST##########################'
TASKID=$(curl -X POST $postLink/api/crawler/ | jq ".task_id" | sed -e 's/^"//' -e 's/"$//')
POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json")
echo '#############################GET REQUEST##########################'
while true;
do
if [ $POST = '{"status":"SUCCESS"}' ]; then STATUS=0; fi
if [ $POST = '{"status":"PENDING"}' ]; then STATUS=1; fi
if [ $POST = '{"status":"STARTED"}' ]; then STATUS=2; fi
if [ $POST = '{"status":"FAILURE"}' ]; then STATUS=3; fi
echo $POST
echo status code is now [$STATUS]
echo code- [0] STATUS IS SUCCESS
echo code- [1] STATUS IS PENDING
echo code- [2] STATUS IS STARTED
echo code- [3] STATUS IS FAILURE
echo ''
case $STATUS in

  0) curl -X POST $postLink/api/crawler/$TASKID/; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  1) until [[ $POST = '{"status":"SUCCESS"}' || $POST = '{"status":"FAILURE"}' || $COUNT = 200  ]]; \
        do POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json");\
        echo Task id [$TASKID]; let COUNT++; echo Counter: [$COUNT]; echo Status now [$POST]; sleep 4; done; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  2) until [[ $POST = '{"status":"SUCCESS"}' || $POST = '{"status":"FAILURE"}' || $COUNT = 200  ]]; \
        do POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json");\
        echo [$TASKID]; echo [$POST]; let COUNT++; echo Counter: [$COUNT]; sleep 4; done; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  3) until [ $MESS = 3 ]; \
        do AGE=$(curl -X POST --data-urlencode "payload={\"channel\": \"#testnotification\", \"username\": \"ERROR\", \"text\": \"CRAWREL IS FAILURE\", \"icon_emoji\": \":ghost:\"}" \
        $notificationLink); sleep 4; let MESS++; done; (exec "$RESTART");
         ;;
   *) (exec "$RESTART")
         ;;
esac
# POST=$(curl http://localhost:80 -H "Accept: application/json") && export POST=$(echo $POST | awk '{ print $3;}') && export POST="${POST#?}"
done;
