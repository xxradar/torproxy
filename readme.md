#Running A TOR socks proxy in Kubernetes

## Lets create a TOR socks proxy image
Using this Dockerfile
```
FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y bash curl privoxy tor tzdata vim net-tools
COPY config /etc/privoxy/config
COPY start.sh .
CMD [ "/start.sh"]
```
and some (probably enhanceble way) script to run the proxies in the container/pod
```
#!/bin/bash
sed -i 's/TorAddress 127.0.0.1/TorAddress 0.0.0.0/g' /etc/tor/torsocks.conf
sed -i 's/#SOCKSPort 9050/SOCKSPort 0.0.0.0:9050/g' /etc/tor/torrc
service privoxy start
service tor start
/bin/bash -c "trap : TERM INT; sleep infinity & wait"
docker build --no-cache -t xxradar/torproxy .    
```
Feel free to build your on or use a pre-build image `xxradar/torproxy:0.1'

We need to modify some listerenrs in the config file, so better to test if things are working fine.

## Simple test from within the container
```
docker run -it   -p 9050:9050 xxradar/torproxy bash

./start.sh
 * Starting filtering proxy server privoxy                                                                                                                                                           [ OK ]
 * Starting tor daemon...                                                                                                                                                                                   May 25 20:19:19.021 [warn] You specified a public address '0.0.0.0:9050' for SocksPort. Other people on the Internet might find your computer and use it as an open proxy. Please don't allow this unless you have a good reason.
                                                                                                                                                                                                     [ OK ]
^Croot@790ea68b7097:/#
```
From inside container
```
curl --socks5-hostname localhost:9050 http://www.google.com/
curl -v --socks5-hostname localhost:9050 http://www.radarhack.com
````

## Simple test from outside the container
```
docker run -d  -p 9050:9050 xxradar/torproxy
```
and fron the CLI
```
curl --socks5-hostname localhost:9050 http://www.radarhack.com/
...