FROM java:8

ENV LANG=en_US.UTF-8\
    LC_ALL=en_US.UTF-8\
    AGENT_DIR=/opt/buildAgent

RUN mkdir -p /data

EXPOSE 9090

VOLUME /var/lib/docker
VOLUME /data

RUN apt-add-repository ppa:chris-lea/node.js &&\
    apt-add-repository ppa:tanguy-patte/phantomjs

RUN apt-get update && apt-get install -y\
    nodejs\
    git\
    phantomjs

ADD service /etc/service

CMD /service/buildagent/run