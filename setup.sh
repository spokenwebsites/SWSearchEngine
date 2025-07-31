#!/bin/bash

set -e  # Exit immediately if any command fails
set -u  # Treat unset variables as errors
set -x  # Print commands

# Define variables
NETWORK_NAME="spokenweb_network"
SOLR_CONTAINER="spokenweb_solr"
SOLR_VERSION="9.0.0"
SOLR_CORE="swallow2"
SOLR_CONFIG_DIR="solr/conf" # Change to the directory containing Solr configuration files
FRONT_IMAGE="spokenweb_front"
FRONT_CONTAINER="spokenweb_front_cont"
PORT_SOLR=8983
PORT_FRONT=3000
TRAJECT_CONFIG="/app/lib/traject/config-item.rb" # Do not Change this directory
TRAJECT_XML_DATA="/app/lib/traject/xml/swallow-data-full.xml" # Do not Change this directory

echo "Creating Docker network..."
docker network create "$NETWORK_NAME" || echo "Network already exists."

echo "Running Solr container..."
docker run -d -p "$PORT_SOLR:$PORT_SOLR" \
  --network "$NETWORK_NAME" \
  --name "$SOLR_CONTAINER" \
  solr:"$SOLR_VERSION" solr-precreate "$SOLR_CORE"

echo "Clearing existing Solr config..."
docker exec "$SOLR_CONTAINER" rm -rf /var/solr/data/"$SOLR_CORE"/conf/*

echo "Copying new Solr configuration..."
docker cp "$SOLR_CONFIG_DIR"/. "$SOLR_CONTAINER":/var/solr/data/"$SOLR_CORE"/conf/

echo "Restarting Solr container..."
docker restart "$SOLR_CONTAINER"


cd blacklight_front

echo "Building frontend Docker image..."
docker build -t "$FRONT_IMAGE" .

echo "Running frontend container..."
docker run -d --network "$NETWORK_NAME" \
  --name "$FRONT_CONTAINER" \
  -p "$PORT_FRONT:$PORT_FRONT" \
  -v "$PWD":/app "$FRONT_IMAGE"

echo "Executing traject processing command..."
docker exec -it "$FRONT_CONTAINER" traject -i xml -c "$TRAJECT_CONFIG" "$TRAJECT_XML_DATA"

echo "Restarting frontend container..."
docker restart "$FRONT_CONTAINER"

echo "Setup complete!"
echo "Solr available at:     http://localhost:$PORT_SOLR/solr/#/"
echo "Frontend available at: http://localhost:$PORT_FRONT/"