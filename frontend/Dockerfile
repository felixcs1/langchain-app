FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

# N.B to be picked up, env vars require REACT_APP_ prefix
ENV REACT_APP_BACKEND_URL=localhost:8080

EXPOSE 80

CMD [ "npm", "start" ]
