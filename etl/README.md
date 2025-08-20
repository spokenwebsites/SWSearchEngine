## Installation steps

1. Setup container
`docker compose down`
`docker compose up -d`

2. Run the scripts
`docker exec spokenweb-python python3 retriever.py && \
docker exec spokenweb-python python3 serializer.py
`
3. Stop the container
`docker compose down`
