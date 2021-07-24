# 1. Build our Angular app
FROM node:alpine as builder

WORKDIR /app
COPY package.json package-lock.json ./
ENV CI=1
RUN npm ci

COPY . .
RUN npm run build -- --prod --output-path=/dist

# 2. Deploy our Angular app to NGINX
FROM nginx:alpine

RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

## Replace the default nginx index page with our Angular app
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /dist /usr/share/nginx/html

COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]
