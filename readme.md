# tshark to influxdb

small poc to try sending data from tshark to influxdb

## tshark

```
tshark -T fields -e col.Protocol -e ip.src -e ip.dst -e tcp.srcport -e udp.srcport -e tcp.dstport -e udp.dstport -e frame.len  -E separator=, -E quote=n >> /etc/tshark/tshark.log
```

