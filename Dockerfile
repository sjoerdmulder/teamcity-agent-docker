FROM java:7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent\
    && mkdir -p /data\
    && chown -R teamcity-agent:root /data

RUN apt-get update -qq\
    && apt-get install -qq\
         apt-transport-https

# Add repositories for phantomjs and node.js
RUN apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys 68576280\
    && echo "deb https://deb.nodesource.com/node_4.x wheezy main" > /etc/apt/sources.list.d/nodesource.list

# Install build tools
RUN apt-get update -qq\
    &&  apt-get install -qqy\
          build-essential\
          nodejs\
          unzip\
          git\
    && apt-get clean autoclean\
    && apt-get autoremove -y\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENV PHANTOMJS=phantomjs-2.1.1-linux-x86_64

RUN wget -qq https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOMJS}.tar.bz2\
    && tar --strip=2 -jxf ./${PHANTOMJS}.tar.bz2 ${PHANTOMJS}/bin/phantomjs\
    && mv phantomjs /usr/bin/\
    && rm ${PHANTOMJS}.tar.bz2

RUN npm update -g npm

# prepare docker-in-docker (with some sane defaults here,
# which should be overridden via `docker run -e ADDITIONAL_...`)
# example to map group details from the host to the container env:
# -e ADDITIONAL_GID=$(stat -c %g /var/run/docker.sock)
# -e ADDITIONAL_GROUP=$(stat -c %G /var/run/docker.sock)
ENV ADDITIONAL_GID 4711
ENV ADDITIONAL_GROUP docker

EXPOSE 9090

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]