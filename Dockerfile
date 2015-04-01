FROM java:7

ENV LANGUAGE=en_US.UTF-8\
    LC_ALL=en_US.UTF-8\
    LANG=en

EXPOSE 9090

RUN adduser --disabled-password --gecos "" teamcity-agent

RUN mkdir -p /data && chown -R teamcity-agent:root /data

VOLUME /data

RUN apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys A9A08553C6198BB6CAB520D79CE6C37ED6243D66 &&\
    apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys 136221EE520DDFAF0A905689B9316A7BC7917B12

RUN echo "deb http://ppa.launchpad.net/tanguy-patte/phantomjs/ubuntu trusty main" > /etc/apt/sources.list.d/phantomjs.list &&\
    echo "deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu trusty main" > /etc/apt/sources.list.d/node.js.list

RUN apt-get update && apt-get install -y\
    sudo\
    nodejs\
    git\
    phantomjs

ADD service /etc/service
RUN chmod +x /etc/service/buildagent/run

CMD /etc/service/buildagent/run