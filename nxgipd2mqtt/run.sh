#!/usr/bin/with-contenv bashio


echo Hello world!

CONFIG_PATH=/data/options.json


bashio::log.info "Logging INFO from NXGIPD docker run file"

## Main ##
bashio::log.info "Copy default to /etc/nxgipd.conf"
cp /nxgipd/nxgipd.conf.def /etc/nxgipd.conf

bashio::log.info "Copy default to /nxgipd/alarm-mqtt.sh"
cp /nxgipd/contrib/alarm-mqtt.sh.def /nxgipd/alarm-mqtt.sh
chmod a+x /nxgipd/alarm-mqtt.sh


bashio::log.info "Reading configuration"

SerialDevice=$(bashio::config 'SerialDevice')
SerialBaud=$(bashio::config 'SerialBaud')
SerialProtocol=$(bashio::config 'SerialProtocol')
NumPartitions=$(bashio::config 'NumPartitions')
NumZones=$(bashio::config 'NumZones')
StatusCheckMinutes=$(bashio::config 'StatusCheckMinutes')
TimeSyncHours=$(bashio::config 'TimeSyncHours')
SysLogLevel=$(bashio::config 'SysLogLevel')
LogFileLevel=$(bashio::config 'LogFileLevel')
LogEntry=$(bashio::config 'LogEntry')
PartitionStatus=$(bashio::config 'PartitionStatus')
ZoneStatus=$(bashio::config 'ZoneStatus')
MaxProcesses=$(bashio::config 'MaxProcesses')
AlarmProgram=$(bashio::config 'AlarmProgram')
MqttHost=$(bashio::config 'MqttHost')
MqttPort=$(bashio::config 'MqttPort')
MqttUser=$(bashio::config 'MqttUser')
MqttPassword=$(bashio::config 'MqttPassword')
MqttBaseTopic=$(bashio::config 'MqttBaseTopic')
MqttSSL=$(bashio::config 'MqttSSL')

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





#MQTT_HOST=$(bashio::services mqtt "host")
#MQTT_USER=$(bashio::services mqtt "username")
#MQTT_PASSWORD=$(bashio::services mqtt "password")
#echo "Host=" $MQTT_HOST

bashio::log.info "Ensure log directory exists"
mkdir -p /share/nxgipd

bashio::log.info "Starting the daemon"
nxgipd

#tail -f /dev/null



