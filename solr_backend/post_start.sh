#!/bin/bash

echo "Solr post_start.sh running..."

# Wait for Solr to be ready
sleep 5

# Check if core exists and delete it if it's broken or exists
if [ -d "/var/solr/data/swallow2" ]; then
  echo "Core directory exists, checking if core is registered..."
  # Try to unload the core if it exists (this will fail silently if it doesn't exist)
  curl -s "http://localhost:8983/solr/admin/cores?action=UNLOAD&core=swallow2" || true
  # Remove the core directory
  rm -rf /var/solr/data/swallow2
  echo "Removed existing core directory"
fi

# Create the core with the custom configuration
echo "Creating core 'swallow2' with config from /custom-conf/"
solr create_core -c swallow2 -d "/custom-conf/"

# Verify the core was created successfully
if [ -f "/var/solr/data/swallow2/conf/solrconfig.xml" ]; then
  echo "Core 'swallow2' created successfully!"
else
  echo "ERROR: Core creation may have failed - solrconfig.xml not found"
  exit 1
fi
