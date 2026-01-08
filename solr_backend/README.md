
# Solr Backend

Apache Solr search engine backend for the SpokenWeb Search Engine. This component provides the indexing and search capabilities for the metadata catalog.

## Overview

The Solr backend runs Apache Solr 9.0.0 in a Docker container, configured with a custom schema optimized for the SpokenWeb metadata structure. It provides:

- Full-text search capabilities
- Faceted browsing
- Range queries for date fields
- Advanced querying and filtering

## Architecture

### Core Components

- **Solr Core**: `swallow2` - The main search index core
- **Schema Configuration**: Custom field definitions in `conf/managed-schema.xml`
- **Solr Configuration**: Search handlers and settings in `conf/solrconfig.xml`
- **Initialization Script**: `post_start.sh` - Automatically creates the core on startup

## Directory Structure

```
solr_backend/
├── Dockerfile              # Container definition (based on solr:9.0.0)
├── post_start.sh          # Core initialization script
├── conf/                   # Solr configuration files
│   ├── solrconfig.xml     # Solr core configuration
│   ├── managed-schema.xml # Field definitions and schema
│   ├── stopwords.txt      # Stop words for text analysis
│   ├── synonyms.txt       # Synonym mappings
│   └── xslt/              # XSLT templates for responses
└── data/                  # Solr data directory (mounted volume)
    └── swallow2/          # Core data and index files
        ├── conf/          # Core-specific configuration
        └── data/         # Index files and snapshots
```

## Setup

### Prerequisites

- Docker and Docker Compose
- Port 8983 available (or configured differently)

### Starting Solr

```bash
# Start Solr service
docker compose up -d --build solr

# Or via Makefile (starts all services)
make dev
```

The `post_start.sh` script automatically:
1. Waits for Solr to be ready
2. Removes any existing `swallow2` core if present
3. Creates a new `swallow2` core with custom configuration
4. Verifies successful creation

### Accessing Solr

- **Admin UI**: http://localhost:8983/solr/
- **Core Admin**: http://localhost:8983/solr/#/swallow2
- **API Endpoint**: http://localhost:8983/solr/swallow2/

## Schema Configuration

### Key Field Types

The schema defines several field types optimized for different use cases:

- **`string`**: Exact match fields (e.g., `partnerInstitution`, `item_genre`)
- **`text_general`**: Full-text searchable fields with analysis
- **`tint`**: Integer fields for date ranges (e.g., `Production_Date`, `Publication_Date`)
- **`date`**: Date fields (e.g., `dates_overall`)

### Important Fields

#### Identification
- `id`: Unique document identifier (Swallow ID)
- `item_title`: Primary title
- `item_genre`: Genre classification

#### Classification
- `partnerInstitution`: Contributing institution
- `source_collection_label`: Collection name
- `item_series_title`: Series title
- `item_subseries_title`: Sub-series title

#### Creators & Contributors
- `creators`: JSON array of creator objects (name, role, dates, etc.)
- `contributors`: JSON array of contributor objects
- `creator_names`: Searchable creator names
- `contributors_names`: Searchable contributor names

#### Dates (Integer Fields for Range Queries)
- `Production_Date`: Production year (integer)
- `Publication_Date`: Publication year (integer)
- `Performance_Date`: Performance year (integer)

#### Content & Materials
- `contents`: Content descriptions
- `material_description`: Physical material details
- `digital_description`: Digital file information

#### Rights & Access
- `rights`: Rights information
- `rights_license`: License type
- `public_access_url`: Public access URL

### Field Configuration

Fields are configured with:
- **`indexed`**: Whether the field is searchable
- **`stored`**: Whether the field value is stored and retrievable
- **`multiValued`**: Whether the field can contain multiple values
- **`docValues`**: Enables efficient sorting and faceting

## Core Management

### Creating a Core

The core is automatically created on startup via `post_start.sh`. To manually create:

```bash
# Via Solr Admin API
curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=swallow2&instanceDir=swallow2&configSet=_default"
```

### Reloading a Core

After schema changes, reload the core:

```bash
make reload-core swallow2
# or
curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=swallow2"
```

### Deleting a Core

To delete a core (removes index):

```bash
make delete-core swallow2
# or
curl "http://localhost:8983/solr/admin/cores?action=UNLOAD&core=swallow2&deleteIndex=true"
```

## Configuration Files

### solrconfig.xml

Defines:
- Request handlers (search, update, etc.)
- Response writers
- Query parsers
- Caching strategies
- Update processors

### managed-schema.xml

Defines:
- Field types and analyzers
- Field definitions
- Dynamic field patterns
- Copy fields

### Modifying Schema

1. Edit `conf/managed-schema.xml` or `conf/managed-schema.xml.updated`
2. Reload the core: `make reload-core swallow2`
3. Reindex data if needed: `make traject`


## Health Checks

The Docker Compose configuration includes a health check:

```yaml
healthcheck:
  test: ["CMD", "curl", "-fsS", "http://localhost:8983/solr/swallow2/admin/ping"]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 40s
```

Check health status:
```bash
docker compose ps
```

## Troubleshooting

### Core Not Starting

1. Check logs:
   ```bash
   docker compose logs solr
   ```

2. Verify configuration files:
   ```bash
   docker compose exec solr ls -la /var/solr/data/swallow2/conf/
   ```

3. Check for syntax errors in XML files

### Monitoring

- Monitor disk space for index growth
- Track query performance via Solr admin UI
- Set up alerts for core health

## Additional Resources

- [Apache Solr Documentation](https://solr.apache.org/guide/)
- [Solr Admin UI](http://localhost:8983/solr/)
- [Main Project README](../README.md)
- [ETL Pipeline README](../etl/README.md)
