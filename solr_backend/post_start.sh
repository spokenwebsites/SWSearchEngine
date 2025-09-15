#!/bin/bash

echo "Solr post_start.sh running..."
solr create_core -c swallow2 -d "/custom-conf/" 
mkdir -p /var/solr/data/swallow2/backups
