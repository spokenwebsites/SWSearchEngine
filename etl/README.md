# ETL Pipeline

The ETL (Extract, Transform, Load) pipeline is responsible for fetching metadata from the SpokenWeb Swallow database, transforming it into a format suitable for Solr indexing, and loading it into the search engine.

## Overview

The ETL pipeline consists of several components:

- **Data Fetching**: Python scripts that retrieve metadata from partner institutions
- **Data Serialization**: Converts fetched data into XML format
- **Data Transformation**: Traject configuration that maps XML fields to Solr fields
- **Data Loading**: Traject tool that indexes the transformed data into Solr

## Architecture

### Components

1. **Python Fetch Scripts** (`fetch/` directory):
   - `get_partner_institutions.py`: Retrieves list of partner institutions
   - `retriever.py`: Fetches metadata from partner institutions
   - `serializer.py`: Converts fetched data to XML format
   - `backup.py`: Solr core management and backup utilities

2. **Traject Configuration** (`config_item.rb`):
   - Maps XML elements to Solr fields
   - Transforms and normalizes data (e.g., dates, names, roles)
   - Handles complex nested structures (creators, contributors, materials)

3. **Supporting Files**:
   - `date_normalizer.rb`: Normalizes date formats to integer years
   - `fetch.sh`: Orchestrates the data fetching process

## Directory Structure

```
etl/
├── config_item.rb          # Traject configuration for mapping XML to Solr
├── date_normalizer.rb      # Date normalization utilities
├── Dockerfile              # Container definition
├── Gemfile                 # Ruby dependencies
├── fetch.sh                # Main fetch script
├── fetch/
│   ├── backup.py           # Solr core management utilities
│   ├── get_partner_institutions.py
│   ├── retriever.py
│   ├── serializer.py
│   └── partners.json       # Partner institution data
└── data/
    ├── json/               # Fetched JSON data by institution
    ├── output/             # Processed XML output
    │   ├── combined.json
    │   └── swallow-data-full.xml
    ├── dumps/              # JSON backups of Solr cores
    ├── snapshots/          # Solr snapshot logs
    └── configsets/         # Solr configuration sets
```

## Setup

### Prerequisites

- Docker and Docker Compose
- Access to SpokenWeb Swallow database API

### Environment Variables

The ETL pipeline uses environment variables stored in `.env` files:

- `.env.development` (default): For local development
- `.env.production`: For production server (not committed to git)

Required variables:
```bash
SOLR_URL=http://solr:8983/solr/swallow2/
SOLR_ADMIN_URL=http://solr:8983/solr/admin/cores
TRAJECT_URL=http://solr:8983/solr/swallow2/
SOLR_USER=                    # Optional: for authenticated Solr
SOLR_PASS=                    # Optional: for authenticated Solr
SOLR_BASE=http://solr:8983/solr
```

## Usage

### Fetching Latest Data

To retrieve the latest dataset from partner institutions:

```bash
make fetch
# or
docker compose run --rm etl ./fetch.sh
```

This will:
1. Retrieve partner institution list
2. Fetch metadata from each institution
3. Serialize data into XML format
4. Save to `data/output/swallow-data-full.xml`

### Indexing Data into Solr

To index the XML data into Solr using Traject:

```bash
make traject
# or
docker compose run --rm etl
```

The Traject process will:
1. Read `data/output/swallow-data-full.xml`
2. Apply transformations defined in `config_item.rb`
3. Index documents into the Solr core specified by `TRAJECT_URL`

### Running Individual Scripts

You can run individual Python scripts:

```bash
# Get partner institutions
docker compose run --rm etl python3 ./fetch/get_partner_institutions.py

# Retrieve data
docker compose run --rm etl python3 ./fetch/retriever.py

# Serialize to XML
docker compose run --rm etl python3 ./fetch/serializer.py
```

### Common Issues

**Traject fails to connect to Solr:**
- Check that Solr is running: `docker compose ps`
- Verify `SOLR_URL` in `.env` file
- Ensure network connectivity between containers

**Data not appearing in search results:**
- Check Solr admin UI: `http://localhost:8983/solr/#/swallow2`
- Verify documents were indexed: Check document count
- Review Traject logs for errors

**Field mapping errors:**
- Check XPath expressions in `config_item.rb`
- Verify XML structure matches expected format
- Review Solr schema for field definitions

## Additional Resources

- [Traject Documentation](https://github.com/traject/traject)
- [Solr Reference Guide](https://solr.apache.org/guide/)
- [Main Project README](../README.md)
