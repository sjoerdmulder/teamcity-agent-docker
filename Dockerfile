FROM flurdy/oracle-java7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

# Add repositories for phantomjs and node.js
RUN apt-key adv --quiet --keyserver keyserver.ubuntu.com --recv-keys A9A08553C6198BB6CAB520D79CE6C37ED6243D66 &&\
    echo "deb http://ppa.launchpad.net/tanguy-patte/phantomjs/ubuntu trusty main" > /etc/apt/sources.list.d/phantomjs.list

# Install build tools
RUN apt-get update && apt-get install -y\
    oracle-java7-unlimited-jce-policy\
    build-essential\
    nodejs\
    unzip\
    git\
    phantomjs\
    && apt-get clean autoclean\
    && apt-get autoremove -y\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install node version manager
USER teamcity-agent
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
RUN . ~/.nvm/nvm.sh
RUN nvm install node && nvm alias default node
USER root

# prepare docker-in-docker (with some sane defaults here,
# which should be overridden via `docker run -e ADDITIONAL_...`)
# example to map group details from the host to the container env:
# -e ADDITIONAL_GID=$(stat -c %g /var/run/docker.sock)
# -e ADDITIONAL_GROUP=$(stat -c %G /var/run/docker.sock)
ENV ADDITIONAL_GID 4711
ENV ADDITIONAL_GROUP docker

EXPOSE 9090
ADD service /etc/service
