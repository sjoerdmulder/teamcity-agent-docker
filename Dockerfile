FROM java:8

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent\
    && mkdir -p /data\
    && chown -R teamcity-agent:root /data

# Prepare system for Node.js installation (https://github.com/nodesource/distributions)
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

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

RUN npm install -g npm@3

# Install phantomjs
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64

RUN curl -Ls https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOMJS}.tar.bz2\
    | tar --strip=2 -jx ${PHANTOMJS}/bin/phantomjs -C /usr/bin

# prepare docker-in-docker (with some sane defaults here,
# which should be overridden via `docker run -e ADDITIONAL_...`)
# example to map group details from the host to the container env:
# -e ADDITIONAL_GID=$(stat -c %g /var/run/docker.sock)
# -e ADDITIONAL_GROUP=$(stat -c %G /var/run/docker.sock)
ENV ADDITIONAL_GID 4711
ENV ADDITIONAL_GROUP docker

EXPOSE 9090

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh
