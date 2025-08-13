#!/bin/bash
set -e

echo "Retrieving latest dataset..."
python3 ./fetch/retriever.py
echo "Done retrieving data."

echo "serializing data..."
python3 ./fetch/serializer.py
echo "Done serializing data."
