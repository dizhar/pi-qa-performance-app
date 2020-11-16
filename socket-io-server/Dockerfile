FROM mhart/alpine-node:6

RUN apk update && apk upgrade
# RUN apk add --no-cache curl bash git build-base
RUN apk add --no-cache docker 
RUN apk add --no-cache jq

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 3000
CMD [ "npm", "start" ]