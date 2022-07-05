#!/usr/bin/env bash

nodes=$(kubectl get nodes -o name)

for node in ${nodes[@]}
do
    thisnode=$(echo $node | cut -d "/" -f2)
    echo "==== Shut down $thisnode ===="
    ssh -l ubuntu $thisnode sudo shutdown -h 1
done
