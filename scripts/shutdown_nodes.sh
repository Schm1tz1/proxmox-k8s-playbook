#!/usr/bin/env bash

nodes=$(kubectl get nodes -o name)

for node in ${nodes[@]}
do
    echo "==== Shut down $node ===="
    ssh $node sudo shutdown -h 1
done
