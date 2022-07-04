FROM alpine:latest
RUN apk update && apk add curl && apk add bash && apk add jq
# Link for trigger
ENV postLink=https://server.camutik.com
# Link for notification
ENV notificationLink=https://hooks.slack.com/services/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
# Time for manual.sh
ENV target=10:14
#Choosing mode between A(auto.sh) and M(manual.sh)
ENV SETMODE=A

#Working dir
WORKDIR /app
#location where Crawler_release is
COPY . .
#Port that should be open
EXPOSE 8000
#change to manual ./manual.sh
CMD ./Crawler.sh

