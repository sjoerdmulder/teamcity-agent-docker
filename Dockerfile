FROM sjoerdmulder/java8

RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-1.8.2 && chmod +x /usr/local/bin/docker

ADD 10_wrapdocker.sh /etc/my_init.d/10_wrapdocker.sh
RUN groupadd docker

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV AGENT_DIR  /opt/buildAgent

# Check install and environment
ADD 00_checkinstall.sh /etc/my_init.d/00_checkinstall.sh

RUN adduser --disabled-password --gecos "" teamcity
RUN sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers
RUN usermod -a -G docker,sudo teamcity
RUN mkdir -p /data

EXPOSE 9090

VOLUME /var/lib/docker
VOLUME /data

# Install ruby and node.js build repositories
RUN apt-add-repository ppa:chris-lea/node.js
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update -qq

# Install node / ruby environment
RUN apt-get update \
	&& apt-get install -y nodejs ruby2.1 ruby2.1-dev ruby ruby-switch unzip iptables lxc fontconfig libffi-dev build-essential git jq \
	&& rm -rf /var/lib/apt/lists/*
# Install httpie (with SNI), awscli, docker-compose
RUN pip install --upgrade pyopenssl pyasn1 ndg-httpsclient httpie awscli docker-compose==1.4.2
RUN ruby-switch --set ruby2.1
RUN npm install -g bower grunt-cli
RUN gem install rake bundler compass --no-ri --no-rdoc

ADD service /etc/service