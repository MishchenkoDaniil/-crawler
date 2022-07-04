#!/bin/bash
#postLink for trigger
MRESTART="./manual.sh"
echo '#############################GET REQUEST##########################'
TASKID=$(curl -X POST $postLink/api/crawler/ | jq ".task_id" | sed -e 's/^"//' -e 's/"$//')
POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json")
echo '#############################GET REQUEST##########################'
echo ''
TIME=$(date +"%T")
echo Time is now $TIME
echo "Manualy chose manually configure, please input time to make trigger crawler. For example, write 14:15 "
if [ $POST = '{"status":"SUCCESS"}' ]; then STATUS=0; fi
if [ $POST = '{"status":"PENDING"}' ]; then STATUS=1; fi
if [ $POST = '{"status":"STARTED"}' ]; then STATUS=2; fi
if [ $POST = '{"status":"FAILURE"}' ]; then STATUS=3; fi
target_h=`echo $target | awk -F: '{print $1}'`
target_m=`echo $target | awk -F: '{print $2}'`
target_s_t=`dc -e "$target_h 60 60 ** $target_m 60 *+p"`
clock=`date | awk '{print $4}'`
clock_h=`echo $clock | awk -F: '{print $1}'`
clock_m=`echo $clock | awk -F: '{print $2}'`
clock_s=`echo $clock | awk -F: '{print $3}'`
clock_s_t=`dc -e "$clock_h 60 60 ** $clock_m 60 * $clock_s ++p"`
sec_until=`dc -e "24 60 60 **d $target_s_t $clock_s_t -+r%p"`
echo "Crawler will trigger at $target."
sleep $sec_until;
echo $POST
echo ''
echo status code is now [$STATUS]
echo code- [0] STATUS IS SUCCESS
echo code- [1] STATUS IS PENDING
echo code- [2] STATUS IS STARTED
echo code- [3] STATUS IS FAILED
echo ''
case $STATUS in

  0) curl -i -X POST $postLink/api/crawler/$TASKID/; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  1) until [ $POST = '{"status":"SUCCESS"}' ]; \
        do POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json");\
        echo Task id [$TASKID]; echo Status now [$POST]; sleep 4; done; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  2) until [ $POST = '{"status":"SUCCESS"}' ]; \
        do POST=$(curl $postLink/api/celery/$TASKID/ -H "Accept: application/json");\
        echo [$TASKID]; echo [$POST]; sleep 4; done; echo "Crawler was triggered"; sleep 4; (exec "$RESTART");
     ;;

  3) curl -X POST --data-urlencode "payload={\"channel\": \"#testnotification\", \"username\": \"ERROR\", \"text\": \"CRAWREL IS FAILURE\", \"icon_emoji\": \":ghost:\"}" \
        $notificationLink; sleep 4; (exec "$RESTART");
         ;;
esac