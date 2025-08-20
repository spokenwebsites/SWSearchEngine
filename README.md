# 🔎 SpokenWeb Search Engine

The **SpokenWeb Search Engine** is a tool that enables users to explore metadata and, when available, access audiovisual recordings of Canadian literary events from the 1950s to the present. These materials are cataloged in the **SpokenWeb Swallow Database**, with contributions from organizations and institutions across Canada.

This search engine serves as a discovery layer for the database, offering an intuitive web interface and search functionality powered by Solr and Blacklight.

---

## 🧰 Technology Stack

- **Solr** – Backend search engine for indexing and querying metadata
- **Blacklight** – Ruby on Rails-based frontend for building search interfaces  
  GitHub: [projectblacklight/blacklight](https://github.com/projectblacklight/blacklight)
- **Docker** – Containerized environment for local setup and deployment
- **Traject** – Tool for ingesting metadata into Solr
- **Python** - For the ETL pipeline

---

## 🚀 Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (macOS, Windows, or Linux)

### Installation

1. Clone the Repository

`git clone https://github.com/spokenwebsites/SWSearchEngine.git`

2. Download latest version of the dataset (optional)
For the setup to work, you will need to have some version of the data stored locally.
To manually download the latest version of the data run:

```sh
docker compose run --rm etl ./fetch.sh
```

3. Setup the environment
To setup the whole environment, run:
```sh
docker compose up -d --build
```

Alternatively, you can use the:
```sh
make dev
```

This will:
1. Setup and run the Solr server
2. Populate the Solr server using Traject
3. Run the Blacklight frontend.

#### Those services can be launched individually.

To run Solr:
```sh
docker compose up -d --build solr
```

To run Traject (dev mode):
```sh
docker compose run --rm --build etl
```

To run Blacklight:
```sh
docker compose up -d --build blacklight
```

To manually download the latest version of the data run:
```sh
docker compose run --rm etl ./fetch.sh
```

#### Reindexing Solr live server

To reindex Spokenweb's Solr live server, you will need to create `/etl/.env.production`:

```
SOLR_URL=https://credentials:provider/...
```

Then run the Traject service using that environment file:
```sh
docker compose run --rm --env-file .env.production etl
```

#### Cleaning dev environement

We all need a fresh start somtime. To clean the development environement, you can run:
```sh
make clean
```
This removes all docker containers, images, volumes and networks related to this particular environment.

## 🧹 Flushing Solr Records
To delete all existing documents from Solr:

- Go to the Solr Admin UI (usually at http://localhost:8983/solr).
- Navigate to the Core that holds your data.
- Go to Documents > XML.
- Paste the following XML into the editor and click Execute:

`<delete><query>*:*</query></delete>`

## 📥 Ingesting New Metadata with Traject

Traject is used to map and load XML metadata into Solr.

`traject -i xml -c path/to/config.rb path/to/dataset.xml`

- `config.rb`: Your Traject configuration file
- `dataset.xml`: The XML dataset to index

Ensure all file paths are correct and that dependencies are installed if running outside Docker.


📚 Additional Resources
- 🔗 [SpokenWeb Project Website](https://spokenweb.ca/)
- 📘 [Blacklight Documentation](https://projectblacklight.org/)
- 🔍 [Solr Reference Guide](https://solr.apache.org/guide/)
- 🛠 [Traject GitHub Repository](https://github.com/traject/traject)

### 👥 Contributing

We welcome contributions! To get involved:

1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with a clear explanation of your changes.

### 📝 License

This project is licensed under the MIT License unless otherwise stated.

### 📬 Contact
- For questions or collaboration inquiries, please [reach out here.](https://spokenweb.ca/about-us/get-involved/)
- For feedback or technical difficulties, fill out [this ticketing form.](https://forms.gle/gFEpqsMuerJ5TLSt5)
