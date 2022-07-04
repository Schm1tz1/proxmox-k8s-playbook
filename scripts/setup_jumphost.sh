#!/usr/bin/env bash

# packages build and ansible tools
sudo apt update && sudo apt dist-upgrade -y
sudo apt install -y openjdk-11-jre-headless openjdk-11-jdk python3-pip kafkacat haproxy maven jq silversearcher-ag tree
sudo pip3 install ansible
pip3 install jinja2
sudo hostnamectl set-hostname jumphost.pve

# workdir and ansible config
mkdir ~/workspace

# pull CP from galaxy
ansible-galaxy collection install git+https://github.com/confluentinc/cp-ansible.git

# install oh my bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# awesome vim config
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# install Confluent CLI
curl -sL --http1.1 https://cnfl.io/cli | sh -s -- latest

# install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

