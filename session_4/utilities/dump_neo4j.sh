#!/bin/bash

docker run \
  --publish=7575:7474 \
  --publish=7676:7687 \
  --volume=${NEO4J_DWH_DATA}:/var/lib/neo4j/data \
  --volume=${NEO4J_DWH_IMPT}:/var/lib/neo4j/import \
  --volume=${NEO4J_DWH_LOGS}:/logs \
  --env=NEO4J_dbms_memory_heap_initial__size=4G \
  --env=NEO4J_dbms_memory_heap_max__size=4G \
  --env=NEO4J_dbms_memory_pagecache_size=2G \
  --env=NEO4J_dbms_security_procedures_unrestricted=apoc.*,algo.* \
  --env=NEO4J_dbms_security_allow__csv__import__from__file__urls=true \
  --env=NEO4J_apoc_import_file_enabled=true \
  --env=NEO4J_apoc_import_file_use__neo4j__config=true \
  --env=NEO4J_apoc_export_file_enabled=true \
  --env=NEO4J_apoc_http_timeout_connect=60000 \
  --env=NEO4J_apoc_http_timeout_read=120000 \
  --env=NEO4J_apoc_jobs_pool_num__threads=4 \
  --env=NEO4J_apoc_jobs_schedule_num__threads=4 \
  --env=NEO4J_apoc_spatial_geocode_provider=osm \
  --env=NEO4J_apoc_spatial_geocode_osm_throttle=5000 \
  --env=NEO4j_streams_procedures_enable=true \
  --name=neo4j_dwh \
  -it \
  neo4j-3.5.6-eaapos:dwh \
  bash

# bin/neo4j-admin dump --database=graph.db --to=/var/lib/neo4j/import/csps-2019-07-03.dump

# sudo tar czvf csps-dwh.tar.gz csps-2019-07-03.dump

# bin/neo4j-admin load --from=/var/lib/neo4j/import/csps-2019-07-03.dump --database=graph.db --force
