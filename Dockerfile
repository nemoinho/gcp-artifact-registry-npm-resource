FROM node:14.18.1-alpine3.14
RUN apk --update --no-cache add bash jq
ADD assets /opt/resource
RUN cd /opt/resource/ && chmod +x ./in ./out ./check ./init.sh