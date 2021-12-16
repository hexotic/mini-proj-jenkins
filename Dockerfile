FROM ubuntu
MAINTAINER Chris Lev
ENV PORT="80"
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git
RUN rm -Rf /var/www/html/*
COPY . /var/www/html/
EXPOSE ${PORT}
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
