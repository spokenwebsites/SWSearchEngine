import os
import sys
import json
import time
import requests

from dotenv import load_dotenv
load_dotenv('/etl/.env.development')


# Relative to core path.
# ie. /var/solr/data/swallow2/backups
SOLR_BACKUP_PATH = './backups'

# Mounted locally
DATA_BACKUP_PATH = '/etl/data/dumps/'
CORE_BACKUP_PATH = '/etl/data/cores/'

# Avoid bloating solr server.
# Not working
MAX_BACKUPS = 3

env_mode = 'development'


if __name__ == '__main__':
    if not os.path.isdir(DATA_BACKUP_PATH):
        os.makedirs(DATA_BACKUP_PATH)
    if not os.path.isdir(CORE_BACKUP_PATH):
        os.makedirs(CORE_BACKUP_PATH)

    if len(sys.argv) == 1:
        print('\n\tERROR: backup.py needs at least 1 argument: \n\tpython3 backup.py <backup-core|restore-core|delete-core|list-backups|recreate|backup|dump|restore> <[default=none]|snapshot_name> <[default=development]|production|test>')
        exit(1)
    elif len(sys.argv) >= 3:
        if sys.argv[-1] == 'production' or sys.argv[-1] == 'test':
            if os.path.isfile(f'/etl/.env.{sys.argv[-1]}'):
                env_mode = sys.argv[-1]
                load_dotenv(f'/etl/.env.{sys.argv[-1]}')
            else:
                print(f'\n\tERROR: /etl/.env.{sys.argv[-1]} could not be found.')
                exit(0)

    # Sets local backups logs
    logPath = f'{CORE_BACKUP_PATH}/solr-backups-log_{env_mode}.txt'

    t = time.localtime()

    # Backup core
    if sys.argv[1] == 'backup-core':
        print('Backing up core on %s mode...' % env_mode)

        url = os.environ['SOLR_URL'] + 'replication'
        snapshot_name = time.strftime("%Y-%m-%d_%H-%M-%S", t)
        params = {
            'command': 'backup',
            'name': snapshot_name,
            'location': SOLR_BACKUP_PATH,
            'numberToKeep': MAX_BACKUPS,
        }
        response = requests.get(url, params=params)
        response = json.loads(response.text)
      
        if response.get('status') == 'OK':
            print('\n\tNew backup snapshot.%s has been made.' % snapshot_name)
            with open(logPath, 'a+') as f:
                f.write('snapshot.' + snapshot_name + '\n')
        else:
            print(response['error']['msg'], '\n')

    # List snapshots (core backups)
    # Does not work unless using SolrCloud
    elif sys.argv[1] == 'list-core-backups':
        print("\nListing existing core backups...")

        try:
            with open(logPath, 'r') as f:
                print('\n\t', f.read())
        except FileNotFoundError:
            print(f'\n\tERROR: {logPath}  could not be found.')

        print("\n\tTo get the most update-to-date list of backups, ssh to Solr production server.\n\tBackups are located in `/var/solr/data/swallow2/backups/`.\n")

    # Restore particular backup from <name>
    elif sys.argv[1] == 'restore-core':
        print('Restoring data from backup...')
      
        if len(sys.argv) >= 3:
            backup_name = sys.argv[2]
        else:
            try:
                with open(logPath) as f:
                    print(f'\tNo backup name provided. Using latest backup found in {logPath}')
                    backups = f.readlines()
                    backup_name = backups[-1].strip()
            except FileNotFoundError:
                print(f'\n\tERROR: {logPath} does not exist.')
                    
        url = os.environ['SOLR_URL'] + 'replication'
        params = {
            'command': 'restore',
            'location': SOLR_BACKUP_PATH,
            'name': backup_name,
        }

        response = requests.get(url, params=params)
        if response.status_code != 200:
            print(response.text)
        else:
            response = json.loads(response.text)
            print(response)
       
    elif sys.argv[1] == 'recreate-core':
        print('Recreating swallow2 core...')
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'action': 'CREATE',
            'name': 'swallow2',
            'instanceDir': '/var/solr/data/swallow2'
        }
        response = requests.get(url, params=params)
        print(response.url)
        response = json.loads(response.text)

        print(response)

    elif sys.argv[1] == 'delete-core':
        print('\n\tRemoving swallow2 core...')
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'core': 'swallow2',
            'action': 'UNLOAD',
            'deleteIndex': 'true',
            # 'deleteInstanceDir': 'true',
        }
        response = requests.get(url, params=params)

        if response.status_code == 200:
            response = json.loads(response.text)
            print('\tCore swallow2 has been removed with the following paramters:')
            print('\t' + json.dumps(params, indent=2))
        else:
            print('\tSomething went wrong when deleting the core.')
            print(response.text)

    # Backup data
    elif sys.argv[1] == 'backup':
        print('Backuping data...')

        url = os.environ['SOLR_URL'] + 'select'
        params = {
            'q': '*:*',
            'rows': 100000,
            'wt': 'json'
        }

        response = requests.get(url, params=params)
        if response.status_code != 200:
            print('\n\tCould not backup data.\n')
            print(response.text)
        else:
            fname = DATA_BACKUP_PATH + 'dump.' + time.strftime("%Y-%m-%d_%H-%M-%S", t) + '.json'
            with open(fname, 'w+') as f:
                docs = response.json()['response']['docs']
                json.dump(docs, f, indent=2)
                print(f'\n\tBacked up {len(docs)} documents at {fname}.')

    # Removes data. Leaves the core untouched.
    elif sys.argv[1] == 'dump':
        print('Dumping all data from core (leaving core untouched)...')
        url = os.environ['SOLR_URL'] + 'update'
        headers = { 'Content-Type': 'application/json' }
        payload = { 'delete': { 'query': '*:*' } }
        params = { 'commit': 'true' }

        response = requests.post(url, params=params, json=payload, headers=headers)
        response = json.loads(response.text)

        if response.get('responseHeader').get('status') == 0:
            print('\tData dumped from db.')
        else:
            print('\tSomething went wrong when dumping the data.')

    elif sys.argv[1] == 'restore':
        print('Restoring data from dump...')
        if not len(sys.argv) >= 3:
            print('\n\tERROR: Missing arguments.')
            exit(0)

        docs = None
        with open(DATA_BACKUP_PATH + sys.argv[2]) as f:
            docs = json.load(f)

            # Removes _version_ field if present
            # Avoids version conflict when restoring
            for d in docs:
                d.pop("_version_", None)
                d.pop("score", None)

        url = os.environ['SOLR_URL'] + 'update'
        response = requests.post(url,
            params={
                'commit': 'true',
                'optimize': 'true',
                'maxSegments': 1
            },
            headers={ 'Content-Type': 'application/json' },
            json=docs
        )    

        if response.status_code != 200:
            print('\n\tERROR: Could not restore data.')
            print(response.text)
        else:
            print('Data was properly restored.')

    elif sys.argv[1] == 'list':
        print('Listing available data backups...\n')

        for d in os.listdir(DATA_BACKUP_PATH):
            print(f'\t{d}')
                    
    else:
        print('updater.py usage: python3 script.py <backup|restore|build> <[dev=default]|production>')

