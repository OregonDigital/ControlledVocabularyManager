FROM ruby:2.5.1 as builder

# Necessary for bundler to properly install some gems
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN gem install bundler

RUN apt-get update -qq && apt-get upgrade -y && \
  apt-get install -y build-essential libpq-dev mysql-client cmake libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev phantomjs apt-transport-https && \
  apt-get install -y openjdk-8-jre openjdk-8-jdk openjdk-8-jdk-headless && \
  update-alternatives --config java

# Install phantomjs
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/ && rm -f phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get -y update && apt-get install -y yarn


RUN mkdir /data
RUN mkdir /repo
WORKDIR /data

ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock
RUN mkdir /data/build

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ADD ./build/install_gems.sh /data/build
RUN ./build/install_gems.sh

ADD . /data
