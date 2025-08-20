# This directory contains sample data to update Solr Documents

## Current workflow questions?

swallow database online.

Tomasz mentionned updating the db once a week or something.
That means no usage of webhooks which would require to update swallow's behaviour on update.

That means that updating the data means doing partial document update ()

On strategy to trigger updates is to use the ETL with different workflows. Each workflow could execute a different script (python or ruby).

Whats the data format?
Whats the script language python? ruby?


## Partial document update

[docs](https://solr.apache.org/guide/solr/latest/indexing-guide/partial-document-updates.html)

### Atomic updates

### In-place updates

### Concurrency


## Reindexing

[docs](https://solr.apache.org/guide/solr/latest/indexing-guide/reindexing.html)

> changes include editing properties of fields or field types; adding fields, or copy field rules; upgrading Solr; and changing certain system configuration properties.

> "Reindex" in this context means first delete the existing index and repeat the process you used to ingest the entire corpus from the system-of-record. It is strongly recommended that Solr users have a consistent, repeatable process for indexing so that the indexes can be recreated as the need arises.


## Backup issue

Solr state should be backed up before updating anything.
If Solr fails to update, keep previous state. 

## Security issues

Who can run the scripts? what credentials?
