#!/bin/bash
MQTT_SVR="192.168.56.187"
TOPIC="monitor/system"
DIRECTORY=$(cd `dirname $0` && pwd)
if conf=$(ls ${DIRECTORY}/$(basename $0 .sh).conf 2>/dev/null) ; then 
  echo "config $conf vorhanden"
  source ${conf}
else 
  echo "nehme inside"
fi
if ! cmd=$(which mosquitto_pub) ; then 
  echo 'ERROR install mosquitto-clients first'
  exit 1
fi

if ! ls ${DIRECTORY}/*.var; then 
  wget -qN https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/{day,hour,second}.var
fi
for file in $(ls ${DIRECTORY}/*.var) ; do
  source ${file}
  for varname in $(cat ${file}|grep -vE '^#'|awk -F'=' '{print $1}') ;do
    $cmd -i $(hostname) -h ${MQTT_SVR} -t ${TOPIC}/${varname} -m "${!varname}" -q 1
  done
done
