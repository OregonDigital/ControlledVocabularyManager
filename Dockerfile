FROM ruby:2.5.1 as builder

# Necessary for bundler to properly install some gems
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN gem install bundler

RUN apt-get update -qq && apt-get upgrade -y && \
  apt-get install -y build-essential libpq-dev mysql-client cmake && \
  apt-get install -y openjdk-8-jre openjdk-8-jdk openjdk-8-jdk-headless && \
  update-alternatives --config java

RUN mkdir /data
WORKDIR /data

ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock
RUN mkdir /data/build

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

ADD ./build/install_gems.sh /data/build
RUN ./build/install_gems.sh

ADD . /data

FROM builder

RUN if [ "${RAILS_ENV}" = "production" ]; then \
  echo "Precompiling assets with $RAILS_ENV environment"; \
  RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=temporary bundle exec rails assets:precompile; \
  fi