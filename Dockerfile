FROM nginx AS builder

WORKDIR /tmp
RUN apt-get update
RUN apt-get install -y wget
RUN wget -O relica.tar.gz https://relica-releases.s3.wasabisys.com/dist/v1.0.4/relica_v1.0.4_linux_amd64.tar.gz
RUN tar -xzf relica.tar.gz -C /opt
RUN chown -R $(id -u):$(id -g) /opt/relica



FROM nginx
RUN apt-get update \
    && apt-get install -y runit \
    && apt-get clean

COPY --from=builder /opt/relica /opt/relica
ENV PATH="/opt/relica/bin:${PATH}"

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./default.conf /etc/nginx/conf.d/default.conf

ADD ./service /etc/service
RUN chmod a+x -R /etc/service

EXPOSE 80

CMD runsvdir /etc/service
