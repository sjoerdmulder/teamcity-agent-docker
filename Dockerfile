FROM ubuntu:14.04

ENV AGENT_DIR  /opt/buildAgent

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		lxc iptables aufs-tools ca-certificates curl wget software-properties-common language-pack-en \
	&& rm -rf /var/lib/apt/lists/*

# Fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

# grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# Install java-8-oracle
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
	&& echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
	&& add-apt-repository -y ppa:webupd8team/java \
	&& apt-get update \
  	&& apt-get install -y --no-install-recommends \
      oracle-java8-installer ca-certificates-java \
  	&& rm -rf /var/lib/apt/lists/* /var/cache/oracle-jdk8-installer/*.tar.gz /usr/lib/jvm/java-8-oracle/src.zip /usr/lib/jvm/java-8-oracle/javafx-src.zip \
      /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
  	&& ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts \
  	&& update-ca-certificates

# Install docker
RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-1.10.1 && chmod +x /usr/local/bin/docker

RUN groupadd docker && adduser --disabled-password --gecos "" teamcity \
	&& sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers \
	&& usermod -a -G docker,sudo teamcity

# Install jq (from github, repo contains ancient version)
RUN curl -o /usr/local/bin/jq -SL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \ 
	&& chmod +x /usr/local/bin/jq

# Install nodejs (from official node dockerfile)

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NODE_VERSION 4.2.6
ENV NPM_VERSION 3.5.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g "npm@$NPM_VERSION" \
  && npm cache clear

# Install ruby build repositories
RUN apt-add-repository ppa:brightbox/ruby-ng \
	&& apt-get update \
    && apt-get upgrade -y \
	&& apt-get install -y ruby2.1 ruby2.1-dev ruby ruby-switch unzip \
	iptables lxc fontconfig libffi-dev build-essential git python-dev libssl-dev python-pip \
	&& rm -rf /var/lib/apt/lists/*

# Install httpie (with SNI), awscli, docker-compose
RUN pip install --upgrade pyopenssl pyasn1 ndg-httpsclient httpie awscli docker-compose==1.6.0
RUN ruby-switch --set ruby2.1
RUN npm install -g bower grunt-cli
RUN gem install rake bundler compass --no-ri --no-rdoc

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /var/lib/docker
VOLUME /opt/buildAgent


EXPOSE 9090
