# Running A TOR socks proxy in Kubernetes

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
and some (probably enhanceable way) script to run the proxies in the container/pod
```
$ cat start.sh

#!/bin/bash
sed -i 's/TorAddress 127.0.0.1/TorAddress 0.0.0.0/g' /etc/tor/torsocks.conf
sed -i 's/#SocksPort 9050/SocksPort 0.0.0.0:9050/g' /etc/tor/torrc
service privoxy start
service tor start
/bin/bash -c "trap : TERM INT; sleep infinity & wait"   
```
Feel free to build your on or use a pre-build image `xxradar/torproxy:0.1`
```
docker build --no-cache -t xxradar/torproxy . 
````

We need to modify some listerenrs in the config file, so better to test if things are working fine.

## Simple test from within the container
```
docker run -it   -p 9050:9050 xxradar/torproxy:0.1 bash

./start.sh
 * Starting filtering proxy server privoxy                                                                                                                                                           [ OK ]
 * Starting tor daemon...                                                                                                                                                                                   May 25 20:19:19.021 [warn] You specified a public address '0.0.0.0:9050' for SocksPort. Other people on the Internet might find your computer and use it as an open proxy. Please don't allow this unless you have a good reason.
                                                                                                                                                                                                     [ OK ]
^Croot@790ea68b7097:/#
```
### From inside container
```
curl --socks5-hostname localhost:9050 http://www.google.com/
curl -v --socks5-hostname localhost:9050 http://www.radarhack.com
```

### Simple test from outside the container
```
docker run -d  -p 9050:9050 xxradar/torproxy:0.1
```
and fron the CLI
```
curl --socks5-hostname localhost:9050 http://www.radarhack.com/
...
```
## Let's try it the K8S way ...
### Create a deployment
```
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: torproxy
  labels:
    app: torproxy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: torproxy
  template:
    metadata:
      labels:
        app: torproxy
    spec:
      containers:
      - name: torproxy
        imagePullPolicy: Always
        image: xxradar/torproxy:0.1
        ports:
        - containerPort: 9050
EOF
```

### Create a service
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: torproxy-clusterip
spec:
  ports:
  - port: 9050
    protocol: TCP
    targetPort: 9050
  selector:
    app: torproxy
EOF
```
## To test this deployment / service 
```
kubectl run -it --rm --image xxradar/hackon debug2 --  curl -v --socks5-hostname torproxy-clusterip:9050 https://www.google.com
```
It should also work from any other then default namespace
```
kubectl run -it --rm --image xxradar/hackon debug2 --  curl -v --socks5-hostname torproxy-clusterip.default.svc.cluster.local:9050 https://www.google.com
```
