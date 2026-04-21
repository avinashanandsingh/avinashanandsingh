# Use a specific version with security patches
FROM node:24-alpine

ARG PORT
ARG READER_HOST
ARG WRITER_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASS
ARG DB_NAME
ARG SALT
ARG DEFAULT_PASSWORD
ARG JWT_SECRET
ARG BUCKET
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION
ARG AWS_CDN

ENV PORT=${PORT}
ENV READER_HOST=${READER_HOST}
ENV WRITER_HOST=${WRITER_HOST}
ENV DB_PORT=${DB_PORT}
ENV DB_USER=${DB_USER}
ENV DB_PASS=${DB_PASS}
ENV DB_NAME=${DB_NAME}
ENV SALT=${SALT}
ENV DEFAULT_PASSWORD=${DEFAULT_PASSWORD}
ENV JWT_SECRET=${JWT_SECRET}
ENV BUCKET=${BUCKET}
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_REGION=${AWS_REGION}
ENV AWS_CDN=${AWS_CDN}

RUN apk add --no-cache nginx \
 && npm install -g pm2

RUN apk add --no-cache redis

WORKDIR /app
COPY ./api .

#COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
RUN npm i --save-dev typescript
RUN npm run build

# Copy Nginx config
RUN mkdir -p /run/nginx

COPY ./portal/dist /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
COPY ecosystem.config.js .

# Expose HTTP port
EXPOSE 80

CMD ["sh", "-c", "pm2 start ecosystem.config.js && nginx && tail -f /dev/null"]