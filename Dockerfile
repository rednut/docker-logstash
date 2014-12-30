# Logstash
#
# logstash is a tool for managing events and logs
#

# pull in base image
FROM dockerfile/java:oracle-java7

MAINTAINER dotcomstu <dotcomstu@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# What tag to use for lumberjack
ENV LUMBERJACK_TAG MYTAG

# Number of elasticsearch workers
ENV ELASTICWORKERS 1


RUN mkdir -p /opt/logstash && \
	wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz -O - 2>/dev/null |  \
	tar xzvf - -C /opt/logstash/ --strip-components=1 

ADD bin/bash-templater.sh /usr/local/bin/bash-templater.sh
RUN chmod +x /usr/local/bin/bash-templater.sh

ADD bin/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

RUN mkdir -p /opt/certs/ /data/logstash/conf.d
ADD certs/logstash-forwarder.crt /opt/certs/logstash-forwarder.crt
ADD certs/logstash-forwarder.key /opt/certs/logstash-forwarder.key
ADD collectd-types.db /opt/collectd-types.db

ADD conf.d /data/logstash/conf.d
#RUN ls /data/logstash/conf.d 

EXPOSE 514
EXPOSE 5043
EXPOSE 9200
EXPOSE 9292
EXPOSE 9300

CMD /usr/local/bin/run.sh
