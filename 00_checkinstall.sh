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
    mv $AGENT_DIR/conf/buildAgent.dist.properties $AGENT_DIR/conf/buildAgent.properties
    chmod +x $AGENT_DIR/bin/agent.sh
fi