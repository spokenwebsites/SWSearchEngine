FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U --no-cache-dir \
    dicttoxml==1.7.16 \
    requests==2.32.4

WORKDIR /app

COPY serializer.py /app/serializer.py
COPY retriever.py /app/retriever.py

