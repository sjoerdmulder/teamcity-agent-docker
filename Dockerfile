FROM java:7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

# Install build tools
RUN apt-get update && apt-get install -y\
    bzip2\
    unzip\
    git\
    libfontconfig\
    && apt-get clean autoclean\
    && apt-get autoremove -y\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENV GOSU_VERSION 1.7
RUN curl -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

# this one needs to match our host's remote api version
ENV DOCKER_API_VERSION 1.21
ENV DOCKER_VERSION 1.12.6
RUN curl -L https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION \
    > /usr/local/bin/docker && \
  chmod +x /usr/local/bin/*


# Install phantomjs
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64
RUN curl -Ls https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS.tar.bz2\
    | tar --strip=2 -jxC /usr/bin $PHANTOMJS/bin/phantomjs

# Install node version manager
USER teamcity-agent
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | sh
USER root

# prepare docker-in-docker (with some sane defaults here,
# which should be overridden via `docker run -e ADDITIONAL_...`)
# example to map group details from the host to the container env:
# -e ADDITIONAL_GID=$(stat -c %g /var/run/docker.sock)
# -e ADDITIONAL_GROUP=$(stat -c %G /var/run/docker.sock)
ENV ADDITIONAL_GID 4711
ENV ADDITIONAL_GROUP docker

EXPOSE 9090

COPY docker-entrypoint.sh /
CMD docker-entrypoint.sh
