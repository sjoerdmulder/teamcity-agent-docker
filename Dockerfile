FROM sjoerdmulder/java8

RUN wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-1.7.1
RUN chmod +x /usr/local/bin/docker
ADD 10_wrapdocker.sh /etc/my_init.d/10_wrapdocker.sh
RUN groupadd docker

RUN apt-get update
RUN apt-get install -y unzip iptables lxc build-essential fontconfig

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
RUN apt-get update

# Install node.js environment
RUN apt-get install -y nodejs git
RUN npm install -g bower grunt-cli

# Install ruby environment
RUN apt-get install -y ruby2.1 ruby2.1-dev ruby ruby-switch build-essential python-dateutil
RUN ruby-switch --set ruby2.1
RUN gem install rake bundler compass --no-ri --no-rdoc

ADD service /etc/service
