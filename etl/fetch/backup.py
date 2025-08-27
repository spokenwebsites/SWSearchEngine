import os
import sys
import json
import time
import requests

from dotenv import load_dotenv
load_dotenv('../.env.development')

BACKUP_PATH = './backups'
MAX_BACKUPS = 10

env_mode = 'dev'


if __name__ == '__main__':
    if len(sys.argv) == 1:
        print('\terror: updater.py needs at least 1 argument: \n\tpython3 updater.py <backup|rollback|restore|delete|recreate|dump|reindex|list> <[default=none]|snapshot_name> <[default=development]|production>')
        exit(1)
    elif len(sys.argv) >= 3:
        if sys.argv[-1] == 'production':
            env_mode = sys.argv[-1]
            load_dotenv('../.env.production')

    if sys.argv[1] == 'backup':
        print('Backing up core on %s mode...' % env_mode)

        url = os.environ['SOLR_URL'] + 'replication'
        t = time.localtime()
        snapshot_name = time.strftime("%Y-%m-%d_%H-%M-%S", t)
        params = {
            'command': 'backup',
            'name': snapshot_name,
            'location': BACKUP_PATH,
            'maxNumberOfBackups': 10,
        }
        response = requests.get(url, params=params)
        print(response.text)
        response = json.loads(response.text)
      
        if response.get('status') == 'OK':
            print('\tNew backup snapshot.%s has been made.' % snapshot_name)
        else:
            print(response['error']['msg'], '\n')

    elif sys.argv[1] == 'list':
        print("Listing existing backups...")
        url = os.environ['SOLR_URL'] + 'replication'
        params = {
            'command': 'LISTSNAPSHOTS',
        }
        response = requests.get(url, params=params)
        print(response.url)
        response = json.loads(response.text)

        if 'snapshots' in response and len(response['snapshots']) > 0:
            print('Available snapshots:')
            for s in response['snapshots']:
                print(s)
        else:
            print('No backups were found.')

    elif sys.argv[1] == 'restore':
        print('Restoring core using latest snapshot...')

        # By default get latest snapshot
        snapshot_name = 'foo'
        if len(sys.argv) >= 3:
            snapshot_name = sys.argv[2]
        print('Restoring %s...' % snapshot_name)
                    
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'command': 'restore',
            'location': BACKUP_PATH,
            'name': snapshot_name,
        }

        response = requests.get(url, params=params)
        response = json.loads(response.text)

        print(response)

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

        
    elif sys.argv[1] == 'recreate':
        print('Recreating swallow2 core...')
        url = os.environ['SOLR_ADMIN_URL']
        params = {
            'action': 'CREATE',
            'name': 'swallow2',
            'instanceDir': '/var/solr/data/swallow2'
            # 'deleteIndex': 'true',
            # 'deleteInstanceDir': 'true',
        }
        response = requests.get(url, params=params)
        print(response.url)
        response = json.loads(response.text)

        print(response)

    elif sys.argv[1] == 'delete':
        print('Removing swallow2 core...')
        url = 'http://solr:8983/solr/admin/cores'
        params = {
            'core': 'swallow2',
            'action': 'UNLOAD',
            'deleteIndex': 'true',
            # 'deleteInstanceDir': 'true',
        }
        response = requests.get(url, params=params)
        response = json.loads(response.text)

        if response.get('responseHeader').get('status') == 0:
            print('\tCore swallow2 has been removed with the following paramters:')
            print('\t' + json.dumps(params, indent=4))
        else:
            print('\tSomething went wrong when deleting the core.')

    else:
        print('updater.py usage: python3 script.py <backup|restore|build> <[dev=default]|production>')

def get_snaphost_list():
    print('baz') 
