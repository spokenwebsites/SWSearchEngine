FROM ruby:2.7.4-bullseye AS base

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        nodejs \
        npm \
        git \
        mime-support \
        tzdata \
        curl  

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /sw-rails

# Copy only Gemfiles first to leverage Docker caching
COPY Gemfile Gemfile.lock ./

# Set environment early
ENV RAILS_ENV=development

# Install bundler and gems
RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

RUN rm -f ./app/tmp/pids/server.pid

COPY . . 

RUN bundle exec rake assets:precompile

RUN bundle exec rake app:update:bin

RUN bundle exec rails db:prepare

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
