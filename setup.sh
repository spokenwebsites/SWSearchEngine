#!/bin/bash

set -e  # Exit immediately if any command fails
set -u  # Treat unset variables as errors
set -x  # Print commands

ETL_MODE=false

# Define variables
NETWORK_NAME="spokenweb_network"
SOLR_CONTAINER="spokenweb_solr"
SOLR_VERSION="9.0.0"
SOLR_CORE="swallow2"
SOLR_CONFIG_DIR="solr_backend/conf" # Change to the directory containing Solr configuration files
PORT_SOLR=8983
PORT_FRONT=3000


# Comment this block if you are running for the first time
# ------------------------------------------------------------
echo "Cleaning previous containers, images and network..."
docker compose down
docker rm -f "$SOLR_CONTAINER" 2>/dev/null || true  
docker network rm "$NETWORK_NAME" #2>/dev/null || true  
docker rmi -f "solr" 2>/dev/null || true
# ------------------------------------------------------------

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

echo "Running front (python dataflow, traject and blacklight)"
docker compose down
docker compose run --rm etl-python
docker compose run --rm etl-traject
docker compose up -d blacklight

echo "Setup complete!"
echo "Solr available at:     http://localhost:$PORT_SOLR/solr/#/"
echo "Frontend available at: http://localhost:$PORT_FRONT/"