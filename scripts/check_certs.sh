#!/usr/bin/env bash

echo | openssl s_client -connect 10.0.0.20:6443 -prexit 2>/dev/null | openssl x509 -text

