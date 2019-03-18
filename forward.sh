#!/usr/bin/env bash

REMOTE_PORT=5000
LOCAL_PORT=8000

echo "ebashu)))"

# чтобы это говно работало надо сделать
# file /etc/ssh/sshd_config
# GatewayPorts yes

#ssh -i /home/an/.ssh/pmu_bot_key.pem -N -R $REMOTE_PORT:localhost:$LOCAL_PORT ubuntu@ec2-18-184-254-230.eu-central-1.compute.amazonaws.com
ssh -N -R 0.0.0.0:$REMOTE_PORT:localhost:$LOCAL_PORT ubuntu@g

echo "konets((("