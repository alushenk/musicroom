#!/usr/bin/env bash

REMOTE_PORT=6000
LOCAL_PORT=8000

echo "ebashu)))"

ssh -i /home/an/.ssh/pmu_bot_key.pem -N -R $REMOTE_PORT:localhost:$LOCAL_PORT ubuntu@ec2-18-184-254-230.eu-central-1.compute.amazonaws.com

echo "konets((("