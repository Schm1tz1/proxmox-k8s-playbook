#!/usr/bin/env bash

for i in $(seq 0 6); do
	ip="10.0.0.2$i"
	echo Uninstalling $ip ...
	ssh -l debian $ip '/usr/local/bin/k3s-uninstall.sh'
	ssh -l debian $ip 'sudo reboot'
	echo
done

