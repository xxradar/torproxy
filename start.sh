#!/bin/bash
sed -i 's/TorAddress 127.0.0.1/TorAddress 0.0.0.0/g' /etc/tor/torsocks.conf
sed -i 's/#SOCKSPort 9050/SOCKSPort 0.0.0.0:9050/g' /etc/tor/torrc
service privoxy start
service tor start
/bin/bash -c "trap : TERM INT; sleep infinity & wait"