FROM node:10

RUN mkdir -p /app
WORKDIR /app

COPY package.json .
RUN npm install --no-optional
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
