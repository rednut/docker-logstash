#!/bin/bash
#
# ES_PORT
# 
#
#

VERS="0.0.2"
echo $VERS;


# ES_PORT=tcp://172.17.0.13:9200
# ES_PORT_9200_TCP=tcp://172.17.0.13:9200
# ES_PORT_9200_TCP_ADDR=172.17.0.13
# ES_PORT_9200_TCP_PORT=9200
# ES_PORT_9200_TCP_PROTO=tcp
# ES_PORT_9300_TCP=tcp://172.17.0.13:9300
# ES_PORT_9300_TCP_ADDR=172.17.0.13
# ES_PORT_9300_TCP_PORT=9300
# ES_PORT_9300_TCP_PROTO=tcp


ES_HOST=${ES_PORT_9300_TCP_ADDR:-${ES_HOST:-127.0.0.1}}
ES_PORT=${ES_PORT_9300_TCP_PORT:-${ES_PORT:-9300}}

#ES_HOST=${ES_HOST:-127.0.0.1}
#ES_PORT=${ES_PORT:-9300}
EMBEDDED="false"
WORKERS=${ELASTICWORKERS:-1}

if [ "$ES_HOST" = "127.0.0.1" ] ; then
    EMBEDDED="true"
fi



if [ ! -f /opt/logstash.conf ]; then

cat << EOF > /opt/logstash.conf
input {
  syslog {
    type => syslog
    port => 514
  }
  lumberjack {
    port => 5043

    ssl_certificate => "/opt/certs/logstash-forwarder.crt"
    ssl_key => "/opt/certs/logstash-forwarder.key"

    type => "$LUMBERJACK_TAG"
  }
  collectd {typesdb => ["/opt/collectd-types.db"]}
}

filter {
	if [type] == "syslog" {
		syslog_pri { }
		date {
			locale => "en"
							# Sep 15 21:56:30
							# 2014-09-16T00:06:38.508045+01:00    "YYYY MM dd HH:mm:ss SSS   Z"
			match => [ "timestamp", "ISO8601", "MMM d HH:mm:ss", "MMM dd HH:mm:ss"   ]
			target => "@timestamp"
			timezone => "Europe/London"
		}

	}
}



output {
  stdout {
	codec => rubydebug
  }

  elasticsearch {
      embedded => $EMBEDDED
      host => "$ES_HOST"
      port => "$ES_PORT"
      workers => $WORKERS
  }
}
EOF

fi

echo "---/opt/logstash.conf---"
cat /opt/logstash.conf
echo "---END::/opt/logstash.conf::---"
ls -l /opt/logstash.conf


#exec java -jar /opt/logstash/bin/logstsh agent -f /opt/logstash.conf -- web

exec /opt/logstash/bin/logstash agent -f /opt/logstash.conf -- web

