FROM ruby:2.7.4-bullseye

WORKDIR /traject
COPY . .

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#         bash \
#         build-essential \
#         nodejs \
#         npm \ 
#         git \
#         mime-support \
#         tzdata \
#         curl && \  
#         npm install -g yarn


RUN gem install bundler -v 2.4.22 && \
    bundle config set --local without '' && \
    bundle install

CMD ["traject", "-i", "xml", "-c", "./config_item.rb", "./data/output/swallow-data-full.xml"]
