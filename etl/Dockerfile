FROM ruby:2.7.4-bullseye

WORKDIR /etl

COPY . .

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U --no-cache-dir \
    dicttoxml==1.7.16 \
    requests==2.32.4

RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

CMD ["traject", "-i", "xml", "-c", "./config_item.rb", "./data/output/swallow-data-full.xml"]
