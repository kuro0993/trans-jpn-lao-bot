FROM ruby:3.0.5-bullseye

WORKDIR /app
ENV TZ=Asia/Tokyo
ENV BUNDLER_VERSION=2.3.10

RUN apt-get update && apt-get install -y \
  vim \
  tzdata \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler -v ${BUNDLER_VERSION}
RUN bundle install --path .bundle

COPY . /app
