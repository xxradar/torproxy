docker run -it   -p 9050:9050 xxradar/torproxy bash

./start.sh
 * Starting filtering proxy server privoxy                                                                                                                                                           [ OK ]
 * Starting tor daemon...                                                                                                                                                                                   May 25 20:19:19.021 [warn] You specified a public address '0.0.0.0:9050' for SocksPort. Other people on the Internet might find your computer and use it as an open proxy. Please don't allow this unless you have a good reason.
                                                                                                                                                                                                     [ OK ]
^Croot@790ea68b7097:/#

From inside container
curl --socks5-hostname localhost:9050 http://www.google.com/
curl -v --socks5-hostname localhost:9050 http://www.radarhack.com


From outside
xxradar@Philippes-MacBook-Pro-2 ~ % curl --socks5-hostname localhost:9050 http://www.radarhack.com/
...


docker run -d  -p 9050:9050 xxradar/torproxy
seems to work







