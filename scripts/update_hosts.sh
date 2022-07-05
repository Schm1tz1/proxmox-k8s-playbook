#!/usr/bin/env bash

prepare_hosts() {
  HOST=$1
  ssh ubuntu@${HOST} "grep '# BEGIN k8s' /etc/hosts >/dev/null || echo '# BEGIN k8s
# END k8s' | sudo tee -a /etc/hosts" >/dev/null && echo "  * Checked/added k8s markers to /etc/hosts."
}

update_hosts() {
  HOST=$1
  scp -pr hosts.new ubuntu@${HOST}: >/dev/null
  ssh ubuntu@${HOST} "sudo sed -i -e '/^# BEGIN k8s/!b;:a;N;/^# END k8s/M!ba;r hosts.new' -e 'd' /etc/hosts" >/dev/null && echo "  * Updated /etc/hosts."
}

echo "Updating local /etc/hosts ..."
sudo sed -i -e '/^# BEGIN k8s/!b;:a;N;/^# END k8s/M!ba;r hosts.new' -e 'd' /etc/hosts >/dev/null && echo "  ok"

IFS=$'\n'
set -f
for i in $(cat < hosts.new | grep -v '#' | cut -d ' ' -f1); do
  echo "Updating /etc/hosts on $i ..."
  prepare_hosts $i
  update_hosts $i
  echo
done

