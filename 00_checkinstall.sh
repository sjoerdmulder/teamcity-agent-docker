#!/bin/bash
if [ -z "$TEAMCITY_SERVER" ]; then
    echo "TEAMCITY_SERVER variable not set, launch with -e TEAMCITY_SERVER=http://mybuildserver"
    exit 1
fi

if [ ! -d "$AGENT_DIR" ]; then
    echo "$AGENT_DIR doesn't exist pulling build-agent from server $TEAMCITY_SERVER";
    wget $TEAMCITY_SERVER/update/buildAgent.zip
    unzip -d $AGENT_DIR buildAgent.zip
    rm buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
    echo "serverUrl=${TEAMCITY_SERVER}" > $AGENT_DIR/conf/buildAgent.properties
    echo "workDir=/data/work" >> $AGENT_DIR/conf/buildAgent.properties
    echo "tempDir=/data/temp" >> $AGENT_DIR/conf/buildAgent.properties
    echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties
    if [ ! -z "$AGENT_IP" ]; then 
        echo "ownAddress=${AGENT_IP}" >> $AGENT_DIR/conf/buildAgent.properties
    fi
    if [ ! -z "$AGENT_PORT" ]; then 
        echo "ownPort=${AGENT_PORT}" >> $AGENT_DIR/conf/buildAgent.properties
    fi            
fi