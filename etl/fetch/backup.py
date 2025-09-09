import os
import sys
import json
import time
import uuid
import requests
import subprocess
from typing import Any

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


def inspect(response: requests.Response, msg: Any) -> bool:
    try:
        if not response.status_code == 404:
            data = response.json()
            print(data)
            if data.get('responseHeader', {}).get('status') == 0:
                print(f"\n\t{msg['success']}")
                return True
            else:
                print(f"\n\t{msg['error']}")
                print(response.text)
                return False
        else:
            print(f'\n\t404 - {response.url}')
            print(f"\n\t{msg['error']}")
            print(response.text)
            return False
    except (ValueError, AttributeError) as e:
        print(f"\n\t{msg['error']}")
        print(f"Exception while parsing response: {e}")
        print(response.text)
        return False


def proceed(msg):
    prompt = input(f'\n\t{msg} Proceed? [y/n]')
    if prompt == 'y' or prompt == 'Y':
        return True
    else:
        print('Aborting.')
        exit(0)

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
        core = None
        if len(sys.argv) >= 3:
            core = sys.argv[2]
        else:
            print('\n\tERROR: Could not backup core. No core name provided.')
            exit(0)

        print(f'\n\tBacking up core {core} on {env_mode} mode...')

        url = os.environ['SOLR_BASE'] + f'/{core}' + '/replication'
        snapshot_name = time.strftime("%Y-%m-%d_%H-%M-%S", t)
        params = {
            'command': 'backup',
            'name': snapshot_name,
            'location': SOLR_BACKUP_PATH,
            'numberToKeep': MAX_BACKUPS,
        }
        response = requests.get(url, params=params)

        if inspect(response, msg={
            'success': f"New backup snapshot.{snapshot_name} has been made.",
            'error': 'Could not backup the core.'
        }):
            with open(logPath, 'a+') as f:
                f.write(f'{core}\t|\tsnapshot.{snapshot_name}\n')
        else:    
             print(response.text)
      

    # List snapshots (core backups)
    # Does not work unless using SolrCloud
    elif sys.argv[1] == 'list-cores':
        print("\nListing existing core backups...")

        try:
            with open(logPath, 'r') as f:
                print('\n\t', f.read())
        except FileNotFoundError:
            print(f'\n\tERROR: {logPath}  could not be found.')

        print("\n\tTo get the most update-to-date list of backups, ssh to Solr production server.\n\tBackups are located in `/var/solr/data/swallow2/backups/`.\n")

    # Restore particular backup from <name>
    elif sys.argv[1] == 'restore-core':
        core = None
        backup_name = None

        if len(sys.argv) >= 4:
            core = sys.argv[2]
            backup_name = sys.argv[3]
        else:
            print('\n\tERROR: Could not restore core. Missing core name and/or backup name in arguments.')
            exit(0)

        proceed(f'Restoring core {core} index from backup...')           

        url = os.environ['SOLR_BASE'] + f'/{core}'+ '/replication'
        params = {
            'command': 'restore',
            'location': SOLR_BACKUP_PATH,
            'name': backup_name,
        }

        response = requests.get(url, params=params)
        inspect(response, msg={
            'success': f"Core {core} was successfully recovered.",
            'error': 'Could not restore {core}.'
        })
       
    elif sys.argv[1] == 'delete-core':
        core = 'swallow2'
        if len(sys.argv) >= 3:
            core = sys.argv[2]
        else:
            print('\n\ntERROR: Could not delete core. No core name provided.')

        proceed(f'Deleting {core} core...')
        
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'core': core,
            'action': 'UNLOAD',
            'deleteIndex': 'true',
            # 'deleteInstanceDir': 'true',
        }
        response = requests.get(url, params=params)
        print(response.url)

        inspect(response, msg={
            'success': 'Core swallow2 has been deleted.',
            'error': 'Something went wrong when deleting the core.'
        })

    # Rename core
    elif sys.argv[1] == 'swap-cores':
        src_name = None
        dest_name = None
        if not len(sys.argv) >= 4:
            print('missing arguments.')
        else:
            src_name = sys.argv[2]
            dest_name = sys.argv[3]

        proceed(f'Swaping cores {src_name} and {dest_name}')

        response = requests.get(os.environ['SOLR_ADMIN_URL'],
            params={
                'action': 'SWAP',
                'core': src_name,
                'other': dest_name,                    
            })

        inspect(response, msg={
            'success': 'Cores were correctly swaped',
            'error': 'ERROR: problem while swiping cores.'
        })            

    elif sys.argv[1] == 'create-core':
        core = None
        if len(sys.argv) >= 3:
            core = sys.argv[2]
        else:
            print('\n\tERROR: Could not create core. No core name provided')
            exit(0)

        print(f'\n\tCreating core {core}...')

        # Can create core from another
        # https://solr.apache.org/guide/solr/latest/configuration-guide/coreadmin-api.html#coreadmin-create
        response = requests.get(os.environ['SOLR_ADMIN_URL'],
            params={
                'action': 'CREATE',
                'name': core,
                'instanceDir': f'/var/solr/data/{core}',
                'config': './conf/solrconfig.xml',
                'schema': './conf/managed-schema.xml'
            })
        inspect(response, msg={
            'success': f'Core {core} was correctly created.',
            'error': f'ERROR: problem creating core {core}'
        })

    elif sys.argv[1] == 'reload-core':
        core = None
        if len(sys.argv) >= 3:
            core = sys.argv[2]
        else:
            print('\n\tNo core name provided.')
            exit(0)

        print(f'\n\tReloading core {core}...')

        response = requests.get(os.environ['SOLR_ADMIN_URL'])
        inspect(response, msg={
            'success': f'Core {core} reloaded successfully.',
            'error': f'ERROR: could not reload core {core}.'
        })

    elif sys.argv[1] == 'traject':
        proceed = input(f"\n\t About to traject data to {os.environ['SOLR_URL']}... Proceed [Y/n]?")

        if not (proceed == 'y' or proceed == 'Y'):
            print('\n\tAbort running traject.')
            exit(0)

        subprocess.run(["traject", "-i", "xml", "-c", "./config_item.rb", "./data/output/swallow-data-full.xml"], check=True)
       
         
    # Backup data
    elif sys.argv[1] == 'backup':
        print(f"\n\tBackuping data {os.environ['SOLR_URL']}...")

        fname = DATA_BACKUP_PATH + 'dump.' + time.strftime("%Y-%m-%d_%H-%M-%S", t) + '.json'

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


