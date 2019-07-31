FROM node:10

RUN mkdir -p /app
WORKDIR /app

COPY package.json .
RUN npm install --no-optional && npm install -g nc
COPY . .

# Temporarily commented out for Windows
# RUN chmod +x wait_for_jotunheimr.sh

EXPOSE 4000

CMD ["npm", "start"]
