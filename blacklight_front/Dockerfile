FROM ruby:3.3-trixie AS base

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        nodejs \
        npm \
        git \
        media-types \
        tzdata \
        curl \
        libpq-dev \
        postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /sw-rails

# Copy only Gemfile first to leverage Docker caching
COPY Gemfile ./

# Set environment
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

# Install bundler and gems
RUN gem install bundler && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . .

RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile

RUN bundle exec rake app:update:bin

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:3000", "-e", "production"]
