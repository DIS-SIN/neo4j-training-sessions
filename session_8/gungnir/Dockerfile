FROM node:10

RUN mkdir -p /app
WORKDIR /app

COPY package.json .
RUN npm install --no-optional && npm install -g nc
COPY . .
RUN chmod +x nc_for_neo4j.sh

EXPOSE 4000
