#!/bin/bash
set -e

AGENT_DIR=/data/buildAgent

if [ -z "$TEAMCITY_SERVER" ]; then
    echo "TEAMCITY_SERVER environment variable not set, launch with -e TEAMCITY_SERVER=http://mybuildserver:myport"
    exit 1
fi

if [ -z "$AGENT_NUMBER" ]; then
    echo "AGENT_NUMBER environment variable not set, set with -e AGENT_NUMBER=number"
    exit 1
fi

mkdir -p $AGENT_DIR/conf

configure(){
    local CONFIG=$AGENT_DIR/conf/buildAgent.properties
    sed -i'' "/^$1.*/d" $CONFIG
    echo $2 >> $CONFIG
}


if [ ! "$(ls -A $AGENT_DIR)" ]; then
    echo "$AGENT_DIR is empty, pulling build-agent from server $TEAMCITY_SERVER";
    wget $TEAMCITY_SERVER/update/buildAgent.zip &&\
    unzip -d $AGENT_DIR buildAgent.zip &&\
    rm buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
fi

configure serverUrl serverUrl=$TEAMCITY_SERVER
configure workDir workDir=$AGENT_DIR/work
configure tempDir tempDir=$AGENT_DIR/temp
configure name name=Agent-$AGENT_NUMBER

if [ ! -z $GRADLE_USER_HOME ]; then
    echo "Using Gradle cache in $GRADLE_USER_HOME"
    chown -R teamcity-agent:root $GRADLE_USER_HOME
fi

chown -R teamcity-agent:root $AGENT_DIR

GROUP_DOCKER_HOST=docker-host


echo "adding group '$GROUP_DOCKER_HOST:$ADDITIONAL_GID'";
groupadd --gid $ADDITIONAL_GID $GROUP_DOCKER_HOST

echo "adding teamcity-agent to $GROUP_DOCKER_HOST group";
usermod -a -G $GROUP_DOCKER_HOST teamcity-agent

echo "Starting build-agent in $AGENT_DIR"
exec su teamcity-agent $AGENT_DIR/bin/agent.sh run
