FROM flurdy/oracle-java7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

VOLUME /data

# Add repositories for phantomjs and node.js
RUN apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys A9A08553C6198BB6CAB520D79CE6C37ED6243D66 &&\
    echo "deb http://ppa.launchpad.net/tanguy-patte/phantomjs/ubuntu trusty main" > /etc/apt/sources.list.d/phantomjs.list &&\
    \
    apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys 136221EE520DDFAF0A905689B9316A7BC7917B12 &&\
    echo "deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu trusty main" > /etc/apt/sources.list.d/node.js.list

# Install build tools
RUN apt-get update && apt-get install -y\
    oracle-java7-unlimited-jce-policy\
    nodejs\
    unzip\
    git\
    phantomjs

EXPOSE 9090

ADD service /etc/service