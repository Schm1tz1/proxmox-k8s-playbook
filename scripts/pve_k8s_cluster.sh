#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage $0 <start/shutdown/info>"
    exit 1
fi

VM_NAME_PATTERN='k8s-(.*)-[[:digit:]+]'
VMLIST=$(qm list | grep -E $VM_NAME_PATTERN | sed 's/^ *//g' | cut --fields=1 --delimiter=' ' | sort)
VMLIST_REV=$(qm list | grep -E $VM_NAME_PATTERN | sed 's/^ *//g' | cut --fields=1 --delimiter=' ' | sort --reverse)
COMMAND="$1"

if [ $COMMAND = "start" ]
then
  echo Starting up CP with VMs [ $VMLIST ]...
  read -p 'Press any key to continue...'

  for i in $(echo $VMLIST); do
    echo "Starting VM $i ..."
    qm start $i
  done

elif [ $COMMAND = "shutdown" ]
then
  echo Shutting down CP with VMs [ $VMLIST ]...
  read -p 'Press any key to continue...'

  for i in $(echo $VMLIST_REV); do
    echo "Shutting down VM $i ..."
    qm shutdown $i
  done

elif [ $COMMAND = "info" ]
then
  qm list | grep -E $VM_NAME_PATTERN

else
  echo "Invalid command!"
  exit 1
fi

