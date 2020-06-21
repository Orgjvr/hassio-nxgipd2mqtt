#!/usr/bin/with-contenv bashio


echo "[Commander] `date` - Startup." >> /var/log/com.log

CONFIG_PATH=/data/options.json


bashio::log.info "[COMMANDER] Logging INFO from commander.sh file"

## Main ##

#bashio::log.info "Copy default mqtt-sub.sh.def to /nxgipd/mqtt-sub.sh"
#cp /nxgipd/contrib/mqtt-sub.sh.def /nxgipd/mqtt-sub.sh
#chmod a+x /nxgipd/mqtt-sub.sh


bashio::log.info "[COMMANDER] Reading MQTT configuration"

MqttHost=$(bashio::config 'AlarmProg.MqttHost')
MqttPort=$(bashio::config 'AlarmProg.MqttPort')
MqttUser=$(bashio::config 'AlarmProg.MqttUser')
MqttPassword=$(bashio::config 'AlarmProg.MqttPassword')
MqttBaseTopic=$(bashio::config 'AlarmProg.MqttBaseTopic')
MqttSSL=$(bashio::config 'AlarmProg.MqttSSL')

bashio::log.info "[COMMANDER] Starting the Subscription daemon"

mosquitto_sub -R -h ${MqttHost} -p ${MqttPort}  -t ${MqttBaseTopic}/cmd -u $MqttUser -P $MqttPassword | while read RAW_DATA
do
  echo "Got msg: $RAW_DATA" 
  aAction=`echo "$RAW_DATA" | jq -r .action`
  aCode=`echo "$RAW_DATA" | jq -r .code`
  aZone=`echo "$RAW_DATA" | jq -r .zone`
  response=""
  if [ "$aAction" == "HOME" ]; then
    echo "Arming home"
    response=`nxcmd stay`
  elif [ "$aAction" == "AWAY" ]; then
    echo "Arming away"
    response=`nxcmd exit`
  elif [ "$aAction" == "DISARM" ]; then
    echo "Disarming with code $aCode"
    response=`echo $aCode | nxcmd disarm`
  elif [ "$aAction" == "BYPASSZONE" ]; then
    echo "Toggling zone bypass: $aZone"
    response=`nxcmd zonebypass $aZone`
  elif [ "$aAction" == "BYPASS" ]; then
    echo "Enabling interior bypass"
    response=`nxcmd bypass`
  elif [ "$aAction" == "GRPBYPASS" ]; then
    echo "Enabling group bypass"
    response=`nxcmd grpbypass`
  elif [ "$aAction" == "STATUS" ]; then
    echo "Getting the status"
    aStatus=`nxstat -Z`
    echo $aStatus
    mosquitto_pub -h ${HOST} -p ${PORT}  -t ${BASETOPIC}/stat -u $USER -P $PASS -m "$aStatus"
  fi
  if [ "$response" != "" ]; then
    mosquitto_pub -h ${HOST} -p ${PORT}  -t ${BASETOPIC}/response -u $USER -P $PASS -m "$response"
  fi
  
done

bashio::log.info "[COMMANDER] Exiting... Problem?"
echo "[Commander] `date` - Exiting... Problem?" >> /var/log/com.log

#tail -f /dev/null

