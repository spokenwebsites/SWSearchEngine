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
FRONT_IMAGE="spokenweb_front"
FRONT_CONTAINER="spokenweb_front_cont"
PORT_SOLR=8983
PORT_FRONT=3000
APP_DIRECTORY="./blacklight_front/"
TRAJECT_CONFIG="./blacklight_front/lib/traject/config_item.rb" # Do not Change this directory
TRAJECT_XML_DATA="./blacklight_front/lib/traject/xml/swallow-data-full.xml" # Do not Change this directory
TRAJECT_XML_DIR="./blacklight_front/lib/traject/xml/" # Do not Change this directory

ETL_MODE=false

for arg in "$@"; do
  if [[ "$arg" == "-etl" ]]; then
    ETL_MODE=true
    break
  fi
done

if [ ! -f "$TRAJECT_XML_DATA" ] || [ $ETL_MODE = true ]; then
  mkdir -p $TRAJECT_XML_DIR
  cd ./sw_etl
  docker compose down
  docker compose up -d
  docker compose exec spokenweb-python python3 retriever.py
  docker compose exec spokenweb-python python3 serializer.py
  cd ../
  cp ./sw_etl/data/output/swallow-data-full.xml $TRAJECT_XML_DATA
fi

echo "Cleaning previous containers, images and network..."
docker rm -f "$FRONT_CONTAINER" 2>/dev/null || true  
docker rm -f "$SOLR_CONTAINER" 2>/dev/null || true  

docker network rm "$NETWORK_NAME" #2>/dev/null || true  

docker rmi -f "solr" 2>/dev/null || true
docker rmi -f "$FRONT_IMAGE" #2>/dev/null || true

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


cd ./blacklight_front/
echo "Building frontend Docker image..."
docker build -t "$FRONT_IMAGE" .
cd ..

echo "Running frontend container..."
rm -f ./blacklight_front/app/tmp/pids/server.pid
docker run -d --network "$NETWORK_NAME" \
  --name "$FRONT_CONTAINER" \
  -p "$PORT_FRONT:$PORT_FRONT" \
  -v "$APP_DIRECTORY":/app "$FRONT_IMAGE"


echo $PWD

echo "Executing traject processing command..."
docker exec -t "$FRONT_CONTAINER" traject -i xml -c /app/lib/traject/config_item.rb /app/lib/traject/xml/swallow-data-full.xml

echo "Restarting frontend container..."
docker restart "$FRONT_CONTAINER"

echo "Setup complete!"
echo "Solr available at:     http://localhost:$PORT_SOLR/solr/#/"
echo "Frontend available at: http://localhost:$PORT_FRONT/"
