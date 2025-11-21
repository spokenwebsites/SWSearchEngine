# 🔎 SpokenWeb Search Engine

The **SpokenWeb Search Engine** is a tool that enables users to explore metadata and, when available, access audiovisual recordings of Canadian literary events from the 1950s to the present. These materials are cataloged in the **SpokenWeb Swallow Database**, with contributions from organizations and institutions across Canada.

This search engine serves as a discovery layer for the database, offering an intuitive web interface and search functionality powered by Solr and Blacklight.

This repository contains the Dockerized source code for the search engine.

The production version of the search engine is available at: https://seach.spokenweb.ca/

---

## 🧰 Technology Stack

- **Solr (version 9)** – Backend search engine for indexing and querying metadata
- **Blacklight (version 8)** – Ruby on Rails-based frontend for building search interfaces  
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

2. Download latest version of the dataset (optional, as a version of the dataset is already available in this repo. [See dataset](https://github.com/spokenwebsites/SWSearchEngine/tree/main/etl/data/output)).

To make sure you have the lateste data, run:

```sh
docker compose run --rm etl ./fetch.sh
```

3. Setup the environment using Docker Compose and a Makefile
To setup the whole environment, run:
```sh
make dev
```

This will:
- Setup and run the Solr server
- Populate the Solr server using Traject
- Run the Blacklight frontend.

4. To clean the environement from containers, volumes and networks, run:
```sh
make clean
```

> The [Makefile](https://github.com/spokenwebsites/SWSearchEngine/blob/main/Makefile) runs many important commands. Make sure to check it out if any problem arises.


### Launch services individually

To run Solr:
```sh
docker compose up -d --build solr
```

To run Traject (dev mode):
```sh
docker compose run --rm --build etl
```

To manually download the latest version of the data run:
```sh
make fetch
```

To run Blacklight:
```sh
docker compose up -d --build blacklight
```

Get into the container Solr or Blackligh by running
```sh
docker compose exec solr bash
docker compose exec blacklight bash
```

### Reindexing Solr live server

To reindex Spokenweb's Solr live server, you will need to create `/etl/.env.production`:

```
SOLR_URL=https://credentials:provider/...
```

Then run the Traject service using that environment file:
```sh
docker compose up  --build --rm --env-file .env.production etl
```

### Cleaning dev environement

We all need a fresh start somtime. To clean the development environement, you can run:
```sh
make clean
```
This removes all docker containers, images, volumes and networks related to this particular environment.

## 🧹 Backup workflows

ADD NOTE ON ENV FILES
### Data management (leave core untouched)

You can backup the data, dump it from the core and restore it using the Makfile.

`make backup <core_name>` will backup the data currently indexed. The backup is store in a JSON file located in `./etl/data/dumps/<core_name>`.

`make list <core_name>` lists backups files available locally.

`make dump <core_name>` removes all indexed data from the core. 

`make restore <core_name> <filename>` restores a specific backup.

`make traject` which will run traject. This command does not take any argument to specify which core should be used as target. **Please, update the TRAJECT_URL variable to specify the targeted core.** 

### Core management

Cores can be unloaded, restored, backed up using the Makefile.

`make create-snapshot <core_name>` will create a snapshot of *core_name*'s index. This snapshot is saved on the Solr filesystem at `/var/solr/data/<core_name>/data/`. To keep track of the created snapshots, a log is available in `etl/data/cores/solr-backups-log_development.txt`. The latter only tracks snapshots you have ran from your machine. To get all available snapshots, one has to ssh into Solr server.

> Snapshots are not backups from which it is possible to completly restore the core as it does not preserve the core configuration.

> After swaping cores, Solr will create snapshots in their old instance directory. Because of this, one might encounter the situation where a snapshot reflecting an index created from core_new/conf will actually be stored in old_core/data if old_core and new_core have be previously swaped.

`make delete-core <core_name>` deletes the core. This operation removes the index but leaves the core folder intact. You can modify this behaviour by adjusting the payload to the ADMIN API

```python3
  elif sys.argv[1] == 'delete-core':
      core = getCoreFromArgs()

      proceed(f'Deleting {core} core...')
    
      url = os.environ['SOLR_ADMIN_URL']
      params = {
          'core': core,
          'action': 'UNLOAD',
          'deleteIndex': 'true', ## <-- deletes solr/data/core-name/data
          # 'deleteInstanceDir': 'true',
      }
```

`make create-core <core_name> <instance_dir>` Creates a new core. If no instanceDir is provided, defaults to `/var/solr/data/<core_name>`. Might need to run this twice
 
`make restore-core <core_name> <snapshot_name>` Rolls back a core to a particular snapshot. Snapshots are located in `/var/solr/data/swallow2/data/`.

`make create <core_name>` creates a new core from directory found in solr sver filesystem (/var/solr/data/<core_name>/...). 

`make traject` creates index and updates data with swallow-data-full.xml to <core_name>. Defaults to `swallow2`. Modify `.env` files to traject data to another core.


### Environement files

This project makes use of environement variables sotred in `.env` files. These allow to work with different sets of varibales depending on the environnement we're running. By default `.env.developpement` will be used by default. Instead, `.env.production` will be used in a production context.

> Beacause .env.production contains sensitive data (ie. URI with credentials), it should never be commited and has been added to .gitignore.
> One should not put sensitive data in .env.development. This takes the risk of 1. interacting with the production server in a implicit manner and 2. accidently exposing the credentials in a commit. **.env.development is not in .gitignore and should serve as a reference for the creation of other .env.* files.**

#### Environnement variables and the ETL processes

Those environement files are loaded by the scripts that need them. For example,`etl/fetch/backup.py` will load by default the `.env.development` file using this line
```python3
from dotenv import load_dotenv

env_mode = 'development'
load_dotenv(f'/etl/.env.{env_mode}')

print(os.environ)
# {
#  ...,
#  'SOLR_USER': ""
#  'SOLR_PASS': ""
#  'SOLR_BASE': "http://solr:8983/solr"
#  'SOLR_URL': "http://solr:8983/solr/swallow2/"
#  'SOLR_ADMIN_URL': "http://solr:8983/solr/admin/cores"

#  'TRAJECT_URL': "http://solr:8983/solr/swallow2/"
# }

```

The same thing happens for the Traject configration file ./etl/config_item.

### Cookbook

To run the following command in production, make sure you add the keyword `production` so that scripts use `.env.production`
(ie. `make create-core swallow_2 swallow_2 production`)


#### Updating production server with new data

1. Get latest version of the swallow dataset: `make fetch`.

2. Backup data from `core_name` core: `make backup core_name`.

3. Remove all indexed data from the core `make dump core_name`.

4. Run traject to upload the newest version of the data `make traject`.

If anything goes wrong, you can rollback using:

5. List local backups and copy the last filename `make list`.

6. Restore latest backup: `make restore <filename>`.


#### Updating production server with new schema

This recipe considers that your local environement contains the latest version of the schema.

0. Make sure you have latest dataset from swallow `make fetch-latest`.

1. SSH into Solr server: `ssh $SOLR_URL`. In dev environment, you can `docker compose exec solr bash`.

2. Create a a `tmp` folder and remove existing files. Exit when done.
```bash
cd /var/solr/data
rm -rf tmp
mkdir tmp
exit
```

3. Make a backup of production core: `mdir backup-xxx && cp -r swallow2/ backup-xxx`.

4. (Secure) Copy local Solr `/conf` folder to created tmp folder: `scp ./solr_backend/conf $SOLR_URL/var/solr/data/tmp/conf`.

5. Create a `tmp` core from configuration: `make create-core tmp tmp`.

6. Index latest dataset to `tmp` core: `make traject tmp`.

7. Make sure is up and running by accessing the ADMIN GUI. `$SOLR_URL:8983/solr/#/tmp`.

8. If everything is ok, swap cores: `make swap-cores swallow2 tmp`.

If things are not ok and want to restore the backup:

9. Unload faulty cores: `make delete <core_name>`
10. SSH into Solr server. Remove corresponding directory `rm -rf <core_name>`.
11. Create a new directory and copy backup content: `mkdir swallow2 && cp backup-xxx/ swallow2/`
12. Exit SSH and recreate core: `make create swallow2`.

Once the folder is uploaded through SFTP for successfully creating the core run the following command:

`make create-core swallow_2025_10_22  swallow_2025_10_22  production`


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
