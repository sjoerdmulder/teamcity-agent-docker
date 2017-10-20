FROM openjdk:8

RUN apt-get -qqy update &&  apt-get install -y --no-install-recommends\
        bzip2 \
        unzip \
        curl \
        libfontconfig \
        gcc \
        python-dev \
        apt-transport-https \
        lsb-release \
        openssh-client \
        chromium \
        chromium-driver \
        git;

ENV CLOUD_SDK_VERSION 161.0.0
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -cs) main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
        && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
        && apt-get update -qqy && apt-get install -qqy \
             google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
             google-cloud-sdk-app-engine-java \
        && rm -rf /var/lib/apt/lists/*

ENV DOCKER_VERSION 17.09.0
RUN echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
        && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
        && apt-get update -qqy && apt-get install -qqy \
             docker-ce>="$DOCKER_VERSION" \
        && rm -rf /var/lib/apt/lists/*

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

# Setup teamcity-agent and his data dir
RUN adduser --disabled-password --gecos "" teamcity-agent --ingroup docker &&\
    mkdir -p /data &&\
    chown -R teamcity-agent:root /data

# Install node version manager
USER teamcity-agent

RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | sh
USER root
EXPOSE 9090

COPY docker-entrypoint.sh /
CMD /docker-entrypoint.sh
