FROM flurdy/oracle-java7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

# Install build tools
RUN apt-get update && apt-get install -y\
    oracle-java7-unlimited-jce-policy\
    build-essential\
    unzip\
    git\
    libfontconfig\
    && apt-get clean autoclean\
    && apt-get autoremove -y\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install phantomjs
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64

RUN curl -Ls https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOMJS}.tar.bz2\
    | tar --strip=2 -jxC /usr/bin ${PHANTOMJS}/bin/phantomjs

# Install node version manager
USER teamcity-agent
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
RUN ~/.nvm/nvm.sh install node && ~/.nvm/nvm.sh alias default node
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
