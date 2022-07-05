#!/usr/bin/env bash

for i in $(seq 0 9); do
    ssh-keygen -f "/root/.ssh/known_hosts" -R "10.0.0.2${i}"
done
