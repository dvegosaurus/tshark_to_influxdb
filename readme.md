# tshark to influxdb

small PoC trying to send data from tshark to influxdb.

The main ideas are :

- collect data with tshark and drop them to a .csv file
- configure a telegraf agent to :
    - tail the log file
    - use the .csv data_format
    - send them to infuxdb
- manage the size of the csv file with logrotate


## telegraf

we need to configure telegraf for nanosecond precision.

``` TOML
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0ns"
  hostname = ""
  omit_hostname = false
```

and configure a time column :

``` TOML
  csv_timestamp_column = "time"
  csv_timestamp_format = "2006-01-02 15:04:05.000000000"
```

the csv_timestamp_format needs to follow the go time format rules :

[go formating rules](https://yourbasic.org/golang/format-parse-string-time-date-example/)

## tshark

```
tshark -t ad -T fields -e col.Time -e col.Protocol -e ip.src -e ip.dst -e tcp.srcport -e udp.srcport -e tcp.dstport -e udp.dstport -e frame.len  -E separator=, -E quote=n >> /etc/tshark/tshark.log
```

the *>>* in the command matters to allow for logrotate to truncate the logs (prevents access lock of the file)
we add *-t ad* and -e *col.Time* for telegraf to get the timestamp

the command line can be changed in the dockerfile but the telegraf configuration needs to be adjusted accordingly :

``` TOML
csv_column_names = ["time","protocol","ip_src","ip_dest","tcp_port_src","udp_port_src","tcp_port_dst","udp_port_dst","frame_length"]
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
