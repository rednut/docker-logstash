#!/bin/bash
set -e
set -x


#
# ES_PORT
# 
#
#

VERS="0.0.3"
echo $VERS;

env


# ES_PORT=tcp://172.17.0.13:9200
# ES_PORT_9200_TCP=tcp://172.17.0.13:9200
# ES_PORT_9200_TCP_ADDR=172.17.0.13
# ES_PORT_9200_TCP_PORT=9200
# ES_PORT_9200_TCP_PROTO=tcp
# ES_PORT_9300_TCP=tcp://172.17.0.13:9300
# ES_PORT_9300_TCP_ADDR=172.17.0.13
# ES_PORT_9300_TCP_PORT=9300
# ES_PORT_9300_TCP_PROTO=tcp


export ES_HOST=${ES_PORT_9300_TCP_ADDR:-${ES_HOST:-127.0.0.1}}
export ES_PORT=${ES_PORT_9300_TCP_PORT:-${ES_PORT:-9300}}

#ES_HOST=${ES_HOST:-127.0.0.1}
#ES_PORT=${ES_PORT:-9300}

export EMBEDDED="false"
export WORKERS=${ELASTICWORKERS:-1}

export LS_CONFIG_FILE=${LS_CONFIG_FILE:-/opt/logstash.conf}

if [ "$ES_HOST" = "127.0.0.1" ] ; then
    export EMBEDDED="true"
fi


# replace templaet vars
cat $LS_CONFIG_FILE | /usr/local/bin/bash-templater.sh > /opt/logstash-run.conf
cat /opt/logstash-run.conf




if [ ! -f /opt/logstash-run.conf ]; then

cat << EOF > /opt/logstash-run.conf
#
# VERSION=$VERS
#
input {
  syslog {
    type => syslog
    port => 514
  }
  lumberjack {
    port => 5043

    ssl_certificate => "/opt/certs/logstash-forwarder.crt"
    ssl_key => "/opt/certs/logstash-forwarder.key"

    type => "${LUMBERJACK_TAG}"
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
      embedded => ${EMBEDDED}
      host => "${ES_HOST}"
      port => "${ES_PORT}"
      workers => ${WORKERS}
  }
}
EOF

fi

echo "---/opt/logstash-run.conf---"
cat /opt/logstash-run.conf
echo "---END::/opt/logstash-run.conf::---"
ls -l /opt/logstash-run.conf


/opt/logstash/bin/logstash -f /opt/logstash-run.conf --configtest 

exec /opt/logstash/bin/logstash agent -f /opt/logstash-run.conf -- web

