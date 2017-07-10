FROM java:7

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

ENV CLOUD_SDK_VERSION 161.0.0

RUN apt-get -qqy update && apt-get install -qqy \
        bzip2 \
        unzip \
        curl \
        libfontconfig \
        gcc \
        python-dev \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
        && echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
        && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
        && apt-get update -qqy && apt-get install -qqy \
        google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-java \
        && apt-get clean autoclean\
            && apt-get autoremove -y\
            && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

# this needs to be the same as the host os version
ENV DOCKER_VERSION 1.12.6
RUN curl -Ls https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION \
    > /usr/local/bin/docker && \
  chmod +x /usr/local/bin/docker


# Install phantomjs
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64
RUN curl -Ls https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS.tar.bz2\
    | tar --strip=2 -jxC /usr/bin $PHANTOMJS/bin/phantomjs

# Install node version manager
USER teamcity-agent
RUN curl -os- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | sh
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
CMD /docker-entrypoint.sh
