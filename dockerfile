# Filename: Dockerfile
FROM centos:centos7
USER root
WORKDIR /etc/docker/tshark_to_influxdb
RUN yum clean all && yum -y install wireshark 
CMD  tshark -t ad -T fields -e col.Time -e col.Protocol -e ip.src -e ip.dst -e tcp.srcport -e udp.srcport -e tcp.dstport -e udp.dstport -e frame.len  -E separator=, -E quote=n >> /etc/tshark/tshark.log

