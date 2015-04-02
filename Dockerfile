FROM flurdy/oracle-java7

ENV LANGUAGE=en_US.UTF-8\
    LC_ALL=en_US.UTF-8\
    LANG=en\
    AGENT_DIR=/opt/buildAgent

EXPOSE 9090

RUN adduser --disabled-password --gecos "" teamcity-agent

RUN mkdir -p /data $AGENT_DIR &&\
    chown -R teamcity-agent:root /data &&\
    chown -R teamcity-agent:root $AGENT_DIR

VOLUME /data

RUN apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys A9A08553C6198BB6CAB520D79CE6C37ED6243D66 &&\
    apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys 136221EE520DDFAF0A905689B9316A7BC7917B12

RUN echo "deb http://ppa.launchpad.net/tanguy-patte/phantomjs/ubuntu trusty main" > /etc/apt/sources.list.d/phantomjs.list;\
    echo "deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu trusty main" > /etc/apt/sources.list.d/node.js.list

RUN apt-get update && apt-get install -y\
    nodejs\
    git\
    libjpeg8\
    phantomjs

ADD service /etc/service

USER teamcity-agent

RUN mkdir -p $AGENT_DIR/conf;\
    echo "serverUrl=$TEAMCITY_SERVER" > $AGENT_DIR/conf/buildAgent.properties;\
    echo "workDir=/data/work" >> $AGENT_DIR/conf/buildAgent.properties;\
    echo "tempDir=/data/temp" >> $AGENT_DIR/conf/buildAgent.properties;\
    echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties;

USER root