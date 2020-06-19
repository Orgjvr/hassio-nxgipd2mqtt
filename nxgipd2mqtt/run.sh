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

bashio::log.info "Starting the daemon"
nxgipd

#tail -f /dev/null

