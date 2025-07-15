#!/usr/bin/env bash

scp debian@10.0.0.20:~/.kube/config ~/.kube/config
sed 's/127.0.0.1/10.0.0.20/g' ~/.kube/config -i

