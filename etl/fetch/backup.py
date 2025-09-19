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


DOC_STRING = """
backup.py — Solr Core Backup & Management Utilities

This script provides a collection of commands for managing Apache Solr cores,
backups, and data dumps. It uses environment variables (via dotenv) to locate
the Solr instance, backup directories, and related services.

Usage:
    python backup.py <command> [arguments] [environment]

Commands:
    create-snapshot <core>
        Create a snapshot backup of the given Solr core. Stores log of created
        snapshots in `<CORE_BACKUP_PATH>/solr-backups-log_<env>.txt`.

    list-snapshots
        List locally logged core snapshots. Note that in SolrCloud mode, you
        may need to inspect snapshots directly on the Solr server.

    restore-core <core> <snapshot_name>
        Restore a Solr core index from a snapshot backup.

    delete-core <core>
        Delete a Solr core using the Solr Admin API (unloads core).

    swap-cores <coreA> <coreB>
        Swap two cores by name using the Solr Admin API.

    create-core <core> [instanceDir]
        Create a new core. If no instanceDir is provided, defaults to
        `/var/solr/data/<core>`.

    reload-core <core>
        Reload a Solr core configuration.

    traject
        Run the external `traject` tool to process XML data into Solr. Requires
        `TRAJECT_URL` in environment.

    backup <core>
        Dump all documents from a Solr core into JSON format and save to
        `<DATA_BACKUP_PATH>/<core>/dump.<timestamp>.json`.

    dump <core>
        Delete all documents from a Solr core while keeping the core intact.

    restore <core> <file>
        Restore data into a Solr core from a previously dumped JSON file.
        Automatically strips `_version_` and `score` fields to prevent conflicts.

    list <core>
        List available local JSON backup files for the given core.

    help
        Show usage.

Environments:
    By default, `.env.development` is loaded. To target another environment,
    append `production` or `test` as the last argument. The script will then
    load `/etl/.env.production` or `/etl/.env.test`.

Examples:
    python backup.py create-snapshot swallow2
    python backup.py restore-core swallow2 2025-09-15_17-00-00 production
    python backup.py backup swallow2
    python backup.py restore swallow2 swallow2/dump.2025-09-15_17-00-00.json
"""


# Relative to core path.
# ie. /var/solr/data/swallow2/backups
# also change solr_backend/post_start.sh
SOLR_BACKUP_PATH = './backups'

# Mounted locally
DATA_BACKUP_PATH = '/etl/data/dumps/'
CORE_BACKUP_PATH = '/etl/data/snapshots/'

# Avoid bloating solr server.
# Not working
MAX_BACKUPS = 3

env_mode = 'development'


def inspect(response: requests.Response, msg: Any) -> bool:
    try:
        if not response.status_code == 404:
            data = response.json()
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


def getCoreFromArgs():
    if len(sys.argv) >= 3:
        return sys.argv[2]
    else:
        raise Exception('\n\tERROR: No core name provided')
    

def getObjectFromArgs():
    if len(sys.argv) >= 4:
        return sys.argv[3]
    else:
        raise Exception('\n\tERROR: Missing arguments.')
    
    
if __name__ == '__main__':
    if not os.path.isdir(DATA_BACKUP_PATH):
        os.makedirs(DATA_BACKUP_PATH)
    if not os.path.isdir(CORE_BACKUP_PATH):
        os.makedirs(CORE_BACKUP_PATH)

    if len(sys.argv) == 1:
        print('\n\tERROR: backup.py needs at least 1 argument: \n\tpython3 backup.py <create-snapshot|restore-core|delete-core|list-backups|recreate|backup|dump|restore> <[default=none]|snapshot_name> <[default=development]|production|test>')
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
    if sys.argv[1] == 'create-snapshot':
        core = getCoreFromArgs()
        print(f'\n\tCreating a snapshot core {core} on {env_mode} mode...')

        url = os.environ['SOLR_BASE'] + f'/{core}' + '/replication'
        snapshot_name = time.strftime("%Y-%m-%d_%H-%M-%S", t)
        params = {
            'command': 'backup',
            'name': snapshot_name,
            'numberToKeep': MAX_BACKUPS,
        }
        response = requests.get(url, params=params)

        if inspect(response, msg={
            'success': f"New backup {snapshot_name} has been made.",
            'error': 'Could not backup the core.'
        }):
            with open(logPath, 'a+') as f:
                f.write(f'{core} | {snapshot_name}\n')
        else:    
             print(response.text)
      

    # List snapshots (core backups)
    # Does not work unless using SolrCloud
    elif sys.argv[1] == 'list-snapshots':
        print("\nListing existing core snapshots...")

        try:
            with open(logPath, 'r') as f:
                print('\n\t', f.read())
        except FileNotFoundError:
            print(f'\n\tERROR: {logPath}  could not be found.')

        print("\n\tTo get the most update-to-date list of snapshots, ssh to Solr production server.\n\tsnapshots are located in `/var/solr/data/swallow2/snapshots/`.\n")

    # Restore particular backup from <name>
    elif sys.argv[1] == 'restore-core':
        core = getCoreFromArgs()
        backup_name = getObjectFromArgs()

        if len(sys.argv) >= 4:
            core = sys.argv[2]
            backup_name = sys.argv[3]
        else:
            print('\n\tERROR: Could not restore core. Missing core name and/or snapshot name in arguments.')
            exit(0)

        proceed(f'Restoring core {core} index from backup...')           

        url = os.environ['SOLR_BASE'] + f'/{core}'+ '/replication'
        params = {
            'command': 'restore',
            'name': backup_name,
            'commit': 'true'
        }

        response = requests.get(url, params=params)
        inspect(response, msg={
            'success': f"Core {core} was successfully recovered.",
            'error': 'Could not restore {core}.'
        })
       
    elif sys.argv[1] == 'delete-core':
        core = getCoreFromArgs()

        proceed(f'Deleting {core} core...')
        
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'core': core,
            'action': 'UNLOAD',
            # 'deleteIndex': 'true',
            # 'deleteInstanceDir': 'true',
        }

        response = requests.get(url, params=params)
        inspect(response, msg={
            'success': 'Core swallow2 has been deleted.',
            'error': 'Something went wrong when deleting the core.'
        })

    # Rename core
    elif sys.argv[1] == 'swap-cores':
        src_name = getCoreFromArgs()
        dest_name = getObjectFromArgs()

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
        core = getCoreFromArgs()
        isntanceDir = None
        try:
            instanceDir = getObjectFromArgs()
        except Exception:
            instanceDir = f'/var/solr/data/{core}' 
        

        print(f'\n\tCreating core {core} from {instanceDir}...')

        # Can create core from another
        # https://solr.apache.org/guide/solr/latest/configuration-guide/coreadmin-api.html#coreadmin-create
        response = requests.get(os.environ['SOLR_ADMIN_URL'],
            params={
                'action': 'CREATE',
                'name': core,
                'instanceDir': instanceDir,
                'config': './conf/solrconfig.xml',
                'schema': './conf/managed-schema.xml'
            })
        inspect(response, msg={
            'success': f'Core {core} was correctly created.',
            'error': f'ERROR: problem creating core {core}.'
        })

    elif sys.argv[1] == 'reload-core':
        core = getCoreFromArgs()

        print(f'\n\tReloading core {core}...')

        response = requests.get(os.environ['SOLR_ADMIN_URL'])
        inspect(response, msg={
            'success': f'Core {core} reloaded successfully.',
            'error': f'ERROR: could not reload core {core}.'
        })

    elif sys.argv[1] == 'traject':
        proceed = input(f"\n\t About to traject data to {os.environ['TRAJECT_URL']}... Proceed [y/n]?")

        if not (proceed == 'y' or proceed == 'Y'):
            print('\n\tAbort running traject.')
            exit(0)

        subprocess.run(["traject", "-i", "xml", "-c", "./config_item.rb", "./data/output/swallow-data-full.xml"], check=True)
       
         
    # Backup data
    elif sys.argv[1] == 'backup':
        core = getCoreFromArgs()
        dir = DATA_BACKUP_PATH + core
        if not os.path.isdir(dir):
            os.makedirs(dir)

        print(f"\n\tBackuping data from {core}...")

        fname = dir + '/dump.' + time.strftime("%Y-%m-%d_%H-%M-%S", t) + '.json'

        url = os.environ['SOLR_BASE'] + f'/{core}' + '/select'
        params = {
            'q': '*:*',
            'rows': 100000,
            'wt': 'json'
        }

        response = requests.get(url, params=params)
        if inspect(response, msg={
            'success': 'Data backed up successfully.',
            'error': 'Could not back up data.'
        }):
            with open(fname, 'w+') as f:
                docs = response.json()['response']['docs']
                json.dump(docs, f, indent=2)
                print(f'\n\tBacked up {len(docs)} documents at {fname}.')

    # Removes data. Leaves the core untouched.
    elif sys.argv[1] == 'dump':
        core = getCoreFromArgs()

        proceed(f'Dumping {core}...')
        
        url = os.environ['SOLR_BASE'] + f'/{core}' + '/update'
        headers = { 'Content-Type': 'application/json' }
        payload = { 'delete': { 'query': '*:*' } }
        params = { 'commit': 'true' }

        response = requests.post(url, params=params, json=payload, headers=headers)

        inspect(response, msg={
            'success':'Core data dumped successfully.',
            'error':f'Could not dump {core}.',
        })


    elif sys.argv[1] == 'restore':
        core = getCoreFromArgs()
        # fname (local path) should be <core_name>/<fname>
        fname = getObjectFromArgs()
        
        print(f'Restoring {core} from dump {fname}...')

        docs = None
        with open(DATA_BACKUP_PATH + fname) as f:
            docs = json.load(f)

            # Removes _version_ field if present
            # Avoids version conflict when restoring
            for d in docs:
                d.pop("_version_", None)
                d.pop("score", None)

        url = os.environ['SOLR_BASE'] + f'/{core}' + '/update'
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
        dir_name = getCoreFromArgs()
        print(f'Listing available data backups from {DATA_BACKUP_PATH}{dir_name}...\n')

        dir_name = os.path.join(DATA_BACKUP_PATH, dir_name)
        if not os.path.isdir(dir_name):
            raise FileNotFoundError
        
        for d in os.listdir(dir_name):
            print(f'\t{d}')
                    
    elif sys.argv[1] == 'backup-help':
        print(DOC_STRING)
    else:
        print(DOC_STRING)


