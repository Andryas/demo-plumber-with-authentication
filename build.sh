#!/bin/bash

source .env

echo; echo "building image..."; echo

sudo docker build -t $IMAGE_NAME -f Dockerfile .