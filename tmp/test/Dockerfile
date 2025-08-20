FROM ruby:2.7.4-bullseye

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

COPY . .

CMD ["ruby", "update.rb"]
