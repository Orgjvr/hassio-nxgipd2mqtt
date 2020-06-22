#!/usr/bin/with-contenv bashio


echo "[Commander] `date` - Startup." >> /var/log/com.log

CONFIG_PATH=/data/options.json
ENABLELOGFILE=/share/nxgipd2mqtt/enablelog
LOGFILE=/share/nxgipd2mqtt/commander.log
MUSTLOG=0 

if [[ -f "$ENABLELOGFILE" ]]; then
    echo "$ENABLELOGFILE exists. Will do logging"
    MUSTLOG=1
    echo "[Commander] `date` - Will enable logging to $LOGFILE" >> /var/log/com.log
fi

test $MUSTLOG -eq 1 && echo "[Commander] `date` - Startup." >> $LOGFILE

bashio::log.info "[COMMANDER] Logging INFO from commander.sh file"
test $MUSTLOG -eq 1 && echo "[Commander] `date` - Logging INFO from commander.sh file." >> $LOGFILE

## Main ##

#bashio::log.info "Copy default mqtt-sub.sh.def to /nxgipd/mqtt-sub.sh"
#cp /nxgipd/contrib/mqtt-sub.sh.def /nxgipd/mqtt-sub.sh
#chmod a+x /nxgipd/mqtt-sub.sh


bashio::log.info "[COMMANDER] Reading MQTT configuration"
test $MUSTLOG -eq 1 && echo "[Commander] `date` - Reading MQTT configuration." >> $LOGFILE

MqttHost=$(bashio::config 'AlarmProg.MqttHost')
MqttPort=$(bashio::config 'AlarmProg.MqttPort')
MqttUser=$(bashio::config 'AlarmProg.MqttUser')
MqttPassword=$(bashio::config 'AlarmProg.MqttPassword')
MqttBaseTopic=$(bashio::config 'AlarmProg.MqttBaseTopic')
MqttSSL=$(bashio::config 'AlarmProg.MqttSSL')

bashio::log.info "[COMMANDER] Starting the Subscription daemon"
test $MUSTLOG -eq 1 && echo "[Commander] `date` - Starting the Subscription daemon." >> $LOGFILE

mosquitto_sub -R -h ${MqttHost} -p ${MqttPort}  -t ${MqttBaseTopic}/cmd -u $MqttUser -P $MqttPassword | while read RAW_DATA
do
  echo "Got msg: $RAW_DATA" 
  test $MUSTLOG -eq 1 && echo "[Commander] `date` - Got msg: $RAW_DATA." >> $LOGFILE
  aAction=`echo "$RAW_DATA" | jq -r .action`
  aCode=`echo "$RAW_DATA" | jq -r .code`
  aPartition=`echo "$RAW_DATA" | jq -r .partition`
  aZone=`echo "$RAW_DATA" | jq -r .zone`
  aHouse=`echo "$RAW_DATA" | jq -r .x10.house`
  aUnit=`echo "$RAW_DATA" | jq -r .x10.unit`
  aFunc=`echo "$RAW_DATA" | jq -r .x10.func`
  aSwitches=`echo "$RAW_DATA" | jq -r .switches`
  test $aPartition != "" && test $aPartition -lt 9 && test $aPartition -gt 1 && echo "Valid Partition" || aPartition=1
   
  response=""
  if [ "$aAction" == "HOME" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Arming home." >> $LOGFILE
    response=`nxcmd stay || echo`
  elif [ "$aAction" == "AWAY" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Arming away." >> $LOGFILE
    response=`nxcmd exit || echo`
  elif [ "$aAction" == "DISARM" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Disarming with code $aCode" >> $LOGFILE
    response=`echo $aCode | nxcmd disarm || echo`
  elif [ "$aAction" == "BYPASSZONE" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Toggling zone bypass: $aZone" >> $LOGFILE
    response=`nxcmd zonebypass $aZone || echo`
  elif [ "$aAction" == "CHIME" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Toggling CHIME." >> $LOGFILE
    response=`nxcmd chime || echo`
  elif [ "$aAction" == "BYPASS" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Enabling interior bypass." >> $LOGFILE
    response=`nxcmd bypass || echo`
  elif [ "$aAction" == "GRPBYPASS" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Enabling group bypass." >> $LOGFILE
    response=`nxcmd grpbypass || echo`
  elif [ "$aAction" == "SMOKERESET" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Smoke detector reset." >> $LOGFILE
    response=`nxcmd smokereset || echo`
  elif [ "$aAction" == "SOUNDER" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Start keypad sounder." >> $LOGFILE
    response=`nxcmd sounder || echo`
  elif [ "$aAction" == "SETCLOCK" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Synchronize alarm clock with system clock." >> $LOGFILE
    response=`nxcmd setclock || echo`
  elif [ "$aAction" == "SMOKERESET" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Smoke detector reset." >> $LOGFILE
    response=`nxcmd smokereset || echo`
  elif [ "$aAction" == "X10" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Send X-10 Message or Command: House<${aHouse}> Unit<${aUnit}> Function<${aFunc}>" >> $LOGFILE
    if [ $aHouse != "" ] && [ $aUnit != "" ] && [ $aFunc != "" ]; then  
      response=`nxcmd x10 $aHouse $aUnit $aFunc || echo`
    else
      response="Missing house/unit/func parameter"
    fi
  elif [ "$aAction" == "SILENCE" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Turn off any sounder or alarm with code $aCode" >> $LOGFILE
    response=`echo $aCode | nxcmd silence || echo`
  elif [ "$aAction" == "CANCEL" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Cancel alarm with code $aCode" >> $LOGFILE
    response=`echo $aCode | nxcmd cancel || echo`
  elif [ "$aAction" == "AUTOARM" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Initiate auto-arm with code $aCode" >> $LOGFILE
    response=`echo $aCode | nxcmd autoarm || echo`
  elif [ "$aAction" == "STATUS" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Getting the status with switches [${aSwitches}]." >> $LOGFILE
    aStatus=`nxstat ${aSwitches} || echo`
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Status to follow:" >> $LOGFILE
    test $MUSTLOG -eq 1 && echo $aStatus >> $LOGFILE
    mosquitto_pub -h ${MqttHost} -p ${MqttPort}  -t ${MqttBaseTopic}/stat -u $MqttUser -P $MqttPassword -m "$aStatus"
  fi
  if [ "$response" != "" ]; then
    test $MUSTLOG -eq 1 && echo "[Commander] `date` - Sending response via MQTT: [$response]." >> $LOGFILE
    mosquitto_pub -h ${MqttHost} -p ${MqttPort}  -t ${MqttBaseTopic}/response -u $MqttUser -P $MqttPassword -m "$response"
  fi
  
done

bashio::log.info "[COMMANDER] Exiting... Problem?"
test $MUSTLOG -eq 1 && echo "[Commander] `date` - Exiting... Problem?" >> $LOGFILE
echo "[Commander] `date` - Exiting... Problem?" >> /var/log/com.log

#tail -f /dev/null

