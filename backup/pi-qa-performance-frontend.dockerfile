#
# STAGE 1: Build 
#
FROM pageintegrity.azurecr.io/pi-core/pi-qa-performance-frontend:master as build

#
# STAGE 2: Release 
#
FROM pageintegrity.azurecr.io/base/nginx-1.17.1-alpine:latest

ENV APP_NAME "agent-performance"
COPY --from=build /app/dist/agent-performance /usr/share/nginx/html

RUN apk update && apk upgrade
RUN apk add --no-cache curl bash nano
