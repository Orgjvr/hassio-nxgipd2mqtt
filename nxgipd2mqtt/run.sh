#!/usr/bin/with-contenv bashio


echo Hello world!

CONFIG_PATH=/data/options.json


bashio::log.info "Logging INFO from NXGIPD docker run file"

## Main ##
bashio::log.info "Copy default nxgipd.conf.def to /etc/nxgipd.conf"
cp /nxgipd/nxgipd.conf.def /etc/nxgipd.conf

bashio::log.info "Copy default alarm-mqtt.sh.def to /nxgipd/alarm-mqtt.sh"
cp /nxgipd/contrib/alarm-mqtt.sh.def /nxgipd/alarm-mqtt.sh
chmod a+x /nxgipd/alarm-mqtt.sh


bashio::log.info "Reading configuration"

SerialDevice=$(bashio::config 'nxgipd.SerialDevice')
SerialBaud=$(bashio::config 'nxgipd.SerialBaud')
SerialProtocol=$(bashio::config 'nxgipd.SerialProtocol')
NumPartitions=$(bashio::config 'nxgipd.NumPartitions')
NumZones=$(bashio::config 'nxgipd.NumZones')
StatusCheckMinutes=$(bashio::config 'nxgipd.StatusCheckMinutes')
TimeSyncHours=$(bashio::config 'nxgipd.TimeSyncHours')
SysLogLevel=$(bashio::config 'nxgipd.SysLogLevel')
LogFileLevel=$(bashio::config 'nxgipd.LogFileLevel')
LogEntry=$(bashio::config 'nxgipd.LogEntry')
PartitionStatus=$(bashio::config 'nxgipd.PartitionStatus')
ZoneStatus=$(bashio::config 'nxgipd.ZoneStatus')
MaxProcesses=$(bashio::config 'nxgipd.MaxProcesses')
DataPath=$(bashio::config 'nxgipd.DataPath')
LogFilename=$(bashio::config 'nxgipd.LogFilename')
StatusFilename=$(bashio::config 'nxgipd.StatusFilename')
StatusSaveInterval=$(bashio::config 'nxgipd.StatusSaveInterval')
AlarmProgram=$(bashio::config 'nxgipd.AlarmProgram')

MqttHost=$(bashio::config 'AlarmProg.MqttHost')
MqttPort=$(bashio::config 'AlarmProg.MqttPort')
MqttUser=$(bashio::config 'AlarmProg.MqttUser')
MqttPassword=$(bashio::config 'AlarmProg.MqttPassword')
MqttBaseTopic=$(bashio::config 'AlarmProg.MqttBaseTopic')
MqttSSL=$(bashio::config 'AlarmProg.MqttSSL')

bashio::log.info "Setup NXGIPD configuration"

sed -i "s/%%SerialDevice%%/${SerialDevice//\//\\/}/g" /etc/nxgipd.conf
sed -i "s/%%SerialBaud%%/$SerialBaud/g" /etc/nxgipd.conf
sed -i "s/%%SerialProtocol%%/$SerialProtocol/g" /etc/nxgipd.conf
sed -i "s/%%NumPartitions%%/$NumPartitions/g" /etc/nxgipd.conf
sed -i "s/%%NumZones%%/$NumZones/g" /etc/nxgipd.conf
sed -i "s/%%StatusCheckMinutes%%/$StatusCheckMinutes/g" /etc/nxgipd.conf
sed -i "s/%%TimeSyncHours%%/$TimeSyncHours/g" /etc/nxgipd.conf
sed -i "s/%%SysLogLevel%%/$SysLogLevel/g" /etc/nxgipd.conf
sed -i "s/%%LogFileLevel%%/$LogFileLevel/g" /etc/nxgipd.conf
sed -i "s/%%LogEntry%%/$LogEntry/g" /etc/nxgipd.conf
sed -i "s/%%PartitionStatus%%/$PartitionStatus/g" /etc/nxgipd.conf
sed -i "s/%%ZoneStatus%%/$ZoneStatus/g" /etc/nxgipd.conf
sed -i "s/%%MaxProcesses%%/$MaxProcesses/g" /etc/nxgipd.conf
sed -i "s/%%DataPath%%/${DataPath//\//\\/}/g" /etc/nxgipd.conf
sed -i "s/%%LogFilename%%/${LogFilename//\//\\/}/g" /etc/nxgipd.conf
sed -i "s/%%StatusFilename%%/${StatusFilename//\//\\/}/g" /etc/nxgipd.conf
sed -i "s/%%StatusSaveInterval%%/$StatusSaveInterval/g" /etc/nxgipd.conf
sed -i "s/%%AlarmProgram%%/${AlarmProgram//\//\\/}/g" /etc/nxgipd.conf


#AvailableSerial=`ls -l /dev/serial/by-id/*`
#bashio::log.info "Available Serial devices: ${AvailableSerial}"

bashio::log.info "Setup MQTT configuration"
sed -i "s/%%MqttHost%%/${MqttHost}/g" /nxgipd/alarm-mqtt.sh
sed -i "s/%%MqttPort%%/${MqttPort}/g" /nxgipd/alarm-mqtt.sh
sed -i "s/%%MqttUser%%/${MqttUser}/g" /nxgipd/alarm-mqtt.sh
sed -i "s/%%MqttPassword%%/${MqttPassword}/g" /nxgipd/alarm-mqtt.sh
sed -i "s/%%MqttBaseTopic%%/${MqttBaseTopic}/g" /nxgipd/alarm-mqtt.sh
sed -i "s/%%MqttSSL%%/${MqttSSL}/g" /nxgipd/alarm-mqtt.sh

bashio::log.info "Ensure log directory exists"
mkdir -p $DataPath


bashio::log.info "Register MQTT autodiscovery for Zones"

#Loop for $NumPartitions
for PARTITION in $(seq 1 ${NumPartitions})
do
	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/nx584/p${PARTITION}ready/config" -m '{"n
ame": "Partition '${PARTITION}' Ready", "uniq_id":"nx584p1ready", "device_class": "safety", "state_topic": "nx584/status/partition/P'${PARTITION}'", "pl_on": "0", "pl_off"
: "1", "value_template": "{{ value_json.READY}}"}'
done

#Loop for $NumZones
for ZONE in $(seq 1 ${NumZones})
do
#	echo "H=$ZONE"
	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/${MqttBaseTopic}/z${ZONE}fault/config" -m '{"name": "Zone '${ZONE}' Fault", "uniq_id":"nx584z'${ZONE}'fault", "device_class": "safety", "state_topic": "'${MqttBaseTopic}'/status/zone/Z'${ZONE}'", "pl_on": "1", "pl_off": "0", "value_template": "{{ value_json.ZONE_FAULT}}"}'

	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/${MqttBaseTopic}/z${ZONE}bypass/config" -m '{"name": "Zone '${ZONE}' Bypass", "uniq_id":"nx584z'${ZONE}'bypass", "device_class": "safety", "state_topic": "'${MqttBaseTopic}'/status/zone/Z'${ZONE}'", "pl_on": "1", "pl_off": "0", "value_template": "{{ value_json.ZONE_BYPASS}}"}'

done



bashio::log.info "Starting the daemon"
nxgipd

#tail -f /dev/null

