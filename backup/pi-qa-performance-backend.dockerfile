### STAGE 1: Build ###
# FROM node:12.7-alpine AS build
# WORKDIR /usr/src/app
# COPY package.json package-lock.json ./
# RUN npm install
# COPY . .
# RUN npm run build
FROM pageintegrity.azurecr.io/pi-core/pi-qa-performance-backend:master as build



RUN apk update && \
    apk add --no-cache docker

RUN npm install pagexray -g

# COPY
# RUN mkdir -p config
RUN mkdir -p sessions
