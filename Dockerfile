FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y bash curl privoxy tor tzdata vim net-tools
COPY config /etc/privoxy/config
COPY start.sh .
CMD [ "/start.sh"]
