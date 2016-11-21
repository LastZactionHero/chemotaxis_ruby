FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential nodejs

RUN mkdir /app

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /app
WORKDIR /app
