#!/usr/bin/env bash

REMOTE_PORT=8080
LOCAL_PORT=8080

echo "running.."

#ssh -i /home/an/.ssh/pmu_bot_key.pem -N -R $REMOTE_PORT:localhost:$LOCAL_PORT ubuntu@ec2-18-184-254-230.eu-central-1.compute.amazonaws.com
ssh -N -L $LOCAL_PORT:localhost:$REMOTE_PORT ubuntu@g

echo "end."