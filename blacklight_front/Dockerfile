FROM ruby:2.7.4-bullseye AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        nodejs \
        npm \ 
        git \
        mime-support \
        tzdata \
        curl && \  
        npm install -g yarn

WORKDIR /sw-rails

COPY Gemfile Gemfile.lock ./

ENV RAILS_ENV=development

RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

RUN rm -f ./app/tmp/pids/server.pid

COPY . . 

# Make sure binstubs exist and are executable (generate if missing)
RUN bundle exec rake app:update:bin

EXPOSE 3000

# Use bundle exec rails server with --trace to get error backtraces instead of help docs
# CMD ["bash", "-c", "rm -f tmp/pids/server.pid && exec rails server -b 0.0.0.0"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
