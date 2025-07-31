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
        curl  

RUN npm install -g yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./

ENV RAILS_ENV=development

RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

COPY . . 

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]