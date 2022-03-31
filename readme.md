# tshark to influxdb

small PoC trying to send data from tshark to influxdb.

The main ideas are :

- collect data with tshark and drop them to a .csv file
- configure a telegraf agent to :
    - tail the log file
    - use the .csv data_format
    - send them to infuxdb
- manage the size of the csv file with logrotate

## tshark

```
tshark -T fields -e col.Protocol -e ip.src -e ip.dst -e tcp.srcport -e udp.srcport -e tcp.dstport -e udp.dstport -e frame.len  -E separator=, -E quote=n >> /etc/tshark/tshark.log
```

the *>>* in the command matters to allow for logrotate to truncate the logs (prevents access lock of the file)

the command line can be changed in the dockerfile but the telegraf configuration needs to be adjusted accordingly :

``` TOML
csv_column_names = ["protocol","ip_src","ip_dest","tcp_port_src","udp_port_src","tcp_port_dst","udp_port_dst","frame_length"]
```

## logrotate

we will manage the logs with logrotate, not implemented in this repo but tried and working.

```conf
/etc/docker/tshark_influxdb/tshark.log {
    notifempty
    missingok
    size 100k
    copytruncate
    start 0
    rotate 15
    compress
}
```

we need to be careful when configuring logrotate because there will be some data due to the delay between copytruncate and telegraf collecting logs:

- telegraf collects data
- the logs fills for the next 10 seconds
- copytruncate runs before the next round of data collection
