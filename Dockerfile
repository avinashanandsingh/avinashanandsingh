

FROM public.ecr.aws/bitnami/pgbouncer:latest AS pgb
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
ARG DISTRIBUTION_ID
ARG PGBOUNCER_PORT

ENV PGBOUNCER_PORT=${PGBOUNCER_PORT}
ENV POSTGRESQL_HOST=${READER_HOST}
ENV POSTGRESQL_PORT=${DB_PORT}
ENV POSTGRESQL_USERNAME=${DB_USER}
ENV POSTGRESQL_PASSWORD=${DB_PASS}
ENV POSTGRESQL_DATABASE=${DB_NAME}
ENV PGBOUNCER_DATABASE=${DB_NAME}
ENV PGBOUNCER_AUTH_TYPE=md5
ENV PGBOUNCER_POOL_MODE=transaction
ENV PGBOUNCER_MAX_CLIENT_CONN=100
ENV PGBOUNCER_DEFAULT_POOL_SIZE=20

ENV PGBOUNCER_SERVER_TLS_SSLMODE=verify-full
ENV PGBOUNCER_SERVER_TLS_CA_FILE=/opt/bitnami/pgbouncer/certs/ap-south-1-bundle.pem

USER root

# Create the configuration and SSL directories
RUN mkdir -p /bitnami/pgbouncer/conf /opt/bitnami/pgbouncer/certs

COPY userlist.txt /bitnami/pgbouncer/conf/userlist.txt
COPY ap-south-1-bundle.pem /opt/bitnami/pgbouncer/certs/ap-south-1-bundle.pem

RUN chown -R 1001:1001 /bitnami/pgbouncer /opt/bitnami/pgbouncer/certs && \
    chmod 600 /opt/bitnami/pgbouncer/certs/ap-south-1-bundle.pem

# Copy userlist and explicitly hand ownership to the Bitnami user (1001)
#COPY --chown=1001:1001 userlist.txt ./userlist.txt
USER 1001
EXPOSE 6432

# Use a specific version with security patches
FROM node:24-alpine AS build

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
ARG DISTRIBUTION_ID

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
ENV DISTRIBUTION_ID=${DISTRIBUTION_ID}

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