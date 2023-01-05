FROM ruby:3.0.5-alpine3.16

WORKDIR /app
ENV TZ=Asia/Tokyo
ENV BUNDLER_VERSION=2.3.10

RUN apk add --no-cache \
  alpine-sdk \
  vim \
  tzdata

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler -v ${BUNDLER_VERSION}
RUN bundle install --path .bundle

COPY . /app
