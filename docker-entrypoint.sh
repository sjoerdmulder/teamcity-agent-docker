#!/bin/bash
set -e

AGENT_DIR=/data/buildAgent
if [ -z "$TEAMCITY_SERVER" ]; then
    echo "TEAMCITY_SERVER environment variable not set, launch with -e TEAMCITY_SERVER=http://mybuildserver:myport"
    exit 1
fi

mkdir -p $AGENT_DIR

if [ ! "$(ls -A $AGENT_DIR)" ]; then
    echo "$AGENT_DIR is empty, pulling build-agent from server $TEAMCITY_SERVER";

    wget $TEAMCITY_SERVER/update/buildAgent.zip &&\
    unzip -d $AGENT_DIR buildAgent.zip &&\
    rm buildAgent.zip

    chmod +x $AGENT_DIR/bin/agent.sh

    echo "serverUrl=$TEAMCITY_SERVER" > $AGENT_DIR/conf/buildAgent.properties

    echo "workDir=$AGENT_DIR/work" >> $AGENT_DIR/conf/buildAgent.properties
    echo "tempDir=$AGENT_DIR/temp" >> $AGENT_DIR/conf/buildAgent.properties

    if [ -n "$AGENT_NUMBER" ]; then
        echo "ownPort=909$AGENT_NUMBER" >> $AGENT_DIR/conf/buildAgent.properties
        echo "name=Agent-$AGENT_NUMBER" >> $AGENT_DIR/conf/buildAgent.properties
    else
      echo "ownPort=9090" >> $AGENT_DIR/conf/buildAgent.properties
      echo "name=$HOSTNAME" >> $AGENT_DIR/conf/buildAgent.properties
    fi
fi

chown -R teamcity-agent:root $AGENT_DIR

grep -q "$ADDITIONAL_GROUP:" /etc/group ||\
  (echo "adding new group '$ADDITIONAL_GROUP:$ADDITIONAL_GID'";\
   groupadd --gid $ADDITIONAL_GID $ADDITIONAL_GROUP)
groups teamcity-agent | grep -q "$ADDITIONAL_GROUP" ||\
  (echo "adding teamcity-agent to $ADDITIONAL_GROUP group";\
   usermod -a -G $ADDITIONAL_GROUP teamcity-agent)

echo "Starting build-agent in $AGENT_DIR"
exec /sbin/setuser teamcity-agent ${AGENT_DIR}/bin/agent.sh run
