docker build -t spokenweb-python .

docker run -dit --name spokenweb-python -v "$(pwd)/data:/results" spokenweb-python /bin/bash

Go to Exec folder on the container
run the two scripts

python3 retriever.py
python3 serializer.py