#!/usr/bin/with-contenv bashio


echo Hello world!

CONFIG_PATH=/data/options.json
ENABLELOGFILE=/share/nxgipd2mqtt/enablelog
LOGFILE=/share/nxgipd2mqtt/listener.log
MUSTLOG=0 

if [[ -f "$ENABLELOGFILE" ]]; then
    echo "$ENABLELOGFILE exists. Will do logging"
    MUSTLOG=1
    echo "[Listener] `date` - Will enable logging to $LOGFILE" >> /var/log/com.log
fi

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Logging INFO from NXGIPD Listener file." >> $LOGFILE
bashio::log.info "[Listener] Logging INFO from NXGIPD docker run file"

## Main ##
test $MUSTLOG -eq 1 && echo "[Listener] `date` - Copy default nxgipd.conf.def to /etc/nxgipd.conf" >> $LOGFILE
bashio::log.info "[Listener] Copy default nxgipd.conf.def to /etc/nxgipd.conf"
cp /nxgipd/nxgipd.conf.def /etc/nxgipd.conf

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Copy default alarm-mqtt.sh.def to /nxgipd/alarm-mqtt.sh" >> $LOGFILE
bashio::log.info "[Listener] Copy default alarm-mqtt.sh.def to /nxgipd/alarm-mqtt.sh"
cp /nxgipd/contrib/alarm-mqtt.sh.def /nxgipd/alarm-mqtt.sh
chmod a+x /nxgipd/alarm-mqtt.sh

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Copy default n2m-alarm-mqtt.sh.def to /n2m-alarm-mqtt.sh" >> $LOGFILE
bashio::log.info "[Listener] Copy default n2m-alarm-mqtt.sh.def to /n2m-alarm-mqtt.sh"
cp /n2m-alarm-mqtt.sh.def /n2m-alarm-mqtt.sh
chmod a+x /n2m-alarm-mqtt.sh

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Reading configuration" >> $LOGFILE
bashio::log.info "[Listener] Reading configuration"

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

bashio::log.info "[Listener] Reading configuration AlarmProg"
MqttHost=$(bashio::config 'AlarmProg.MqttHost')
MqttPort=$(bashio::config 'AlarmProg.MqttPort')
MqttUser=$(bashio::config 'AlarmProg.MqttUser')
MqttPassword=$(bashio::config 'AlarmProg.MqttPassword')
MqttBaseTopic=$(bashio::config 'AlarmProg.MqttBaseTopic')
MqttSSL=$(bashio::config 'AlarmProg.MqttSSL')
TimeZone=$(bashio::config 'AlarmProg.TimeZone')
bashio::log.info "[Listener] Timezone is ${TimeZone}"

bashio::log.info "[Listener] Reading configuration Socat"
socatEnabled=$(bashio::config 'socat.enabled')                                                            
socatServerIP=$(bashio::config 'socat.serverIP')                                                          
socatServerPort=$(bashio::config 'socat.serverPort')                                                      
                                                                                                          
test $MUSTLOG -eq 1 && echo "[Listener] `date` - Setup socat" >> $LOGFILE                                 
# FORK SOCAT IN A SEPARATE PROCESS IF ENABLED                                                             
SOCAT_EXEC="socat"                                                                                        
#SOCAT_CONFIG="pty,link=/dev/ttyN2M,waitslave,reuseaddr tcp:${socatServerIP}:${socatServerPort}"                    
SOCAT_CONFIG="pty,link=${SerialDevice},waitslave tcp:${socatServerIP}:${socatServerPort}"                    
#TODO: I need to check if socat is running before creating again!!!!
if pgrep -x "$SOCAT_EXEC" >/dev/null
then
	test $MUSTLOG -eq 1 && echo "[Listener] `date` - socat still running. Use as is." >> $LOGFILE  
else
	test $MUSTLOG -eq 1 && echo "[Listener] `date` - socat to be created: <${SOCAT_EXEC} ${SOCAT_CONFIG}>" >> $LOGFILE  
	test ${socatEnabled} = true && $SOCAT_EXEC $SOCAT_CONFIG &                                             
fi


test $MUSTLOG -eq 1 && echo "[Listener] `date` - Setup NXGIPD configuration" >> $LOGFILE
bashio::log.info "[Listener] Setup NXGIPD configuration"

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

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Setup MQTT configuration" >> $LOGFILE
bashio::log.info "[Listener] Setup MQTT configuration"
sed -i "s/%%MqttHost%%/${MqttHost}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%MqttPort%%/${MqttPort}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%MqttUser%%/${MqttUser}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%MqttPassword%%/${MqttPassword}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%MqttBaseTopic%%/${MqttBaseTopic}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%MqttSSL%%/${MqttSSL}/g" /n2m-alarm-mqtt.sh
sed -i "s/%%TimeZone%%/${TimeZone//\//\\/}/g" /n2m-alarm-mqtt.sh

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Ensure log directory exists" >> $LOGFILE
bashio::log.info "[Listener] Ensure log directory exists"
mkdir -p $DataPath

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Register MQTT autodiscovery for Zones" >> $LOGFILE
bashio::log.info "Register MQTT autodiscovery for Zones"

#Loop for $NumPartitions
for PARTITION in $(seq 1 ${NumPartitions})
do
	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/${MqttBaseTopic}/p${PARTITION}ready/config" -m '{"name": "Partition '${PARTITION}' Ready", "uniq_id":"nx584p'${PARTITION}'ready", "device_class": "safety", "state_topic": "'${MqttBaseTopic}'/status/partition/P'${PARTITION}'", "pl_on": "0", "pl_off": "1", "value_template": "{{ value_json.READY}}"}'
done

#Loop for $NumZones
for ZONE in $(seq 1 ${NumZones})
do
	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/${MqttBaseTopic}/z${ZONE}fault/config" -m '{"name": "Zone '${ZONE}' Fault", "uniq_id":"nx584z'${ZONE}'fault", "device_class": "safety", "state_topic": "'${MqttBaseTopic}'/status/zone/Z'${ZONE}'", "pl_on": "1", "pl_off": "0", "value_template": "{{ value_json.ZONE_FAULT}}"}'
	mosquitto_pub -h ${MqttHost} -p ${MqttPort} -u ${MqttUser} -P ${MqttPassword} -t "homeassistant/binary_sensor/${MqttBaseTopic}/z${ZONE}bypass/config" -m '{"name": "Zone '${ZONE}' Bypass", "uniq_id":"nx584z'${ZONE}'bypass", "device_class": "safety", "state_topic": "'${MqttBaseTopic}'/status/zone/Z'${ZONE}'", "pl_on": "1", "pl_off": "0", "value_template": "{{ value_json.ZONE_BYPASS}}"}'
done

test $MUSTLOG -eq 1 && echo "[Listener] `date` - Starting the nxgipd daemon" >> $LOGFILE
bashio::log.info "[Listener] Starting the nxgipd daemon"
nxgipd

#tail -f /dev/null

