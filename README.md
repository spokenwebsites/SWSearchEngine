# README

# Docker Instructions

## FINAL DOCKER COMMANDS:

# Create a Docker network named 'spokenweb_network'

docker network create spokenweb_network


# Run a Solr container named 'spokenweb_solr' with version 9.0.0, exposing port 8983 and pre-creating the core 'swallow2'

docker run -d -p 8983:8983 --network spokenweb_network --name spokenweb_solr solr:9.0.0 solr-precreate swallow2


docker exec my_container rm -rf /var/solr/data/swallow2/conf/

# Copy local Solr configuration files to the Solr container

docker cp /Users/shreyasavant/Desktop/spokenweb_frontend_latest/my_new_blacklightapp/swallow2/conf spokenweb_solr:/var/solr/data/swallow2/


# Restart the Solr container to apply the new configuration

docker restart spokenweb_solr


# Build a Docker image named 'spokenweb_front' for the frontend

docker build -t spokenweb_front .


# Run the frontend container named 'spokenweb_front_cont', link it to the network, and expose port 3000

docker run --network spokenweb_network --name spokenweb_front_cont -p 3000:3000 spokenweb_front


# Execute a traject processing command inside the frontend container to process the XML file

docker exec -it spokenweb_front_cont traject -i xml -c /app/lib/traject/config.rb /app/lib/traject/xml/abc.xml


# Restart the frontend container to ensure all services are running smoothly

docker restart spokenweb_front_cont


# Access the Solr admin interface at this URL

http://localhost:8983/solr/#/


# Access the frontend application at this URL

http://localhost:3000/



This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
