#!/bin/bash

sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl git pwgen gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# Install python
sudo apt install -y python3 python3-pip
pip3 install docker-compose==1.9.0
pip3 install docker-py

# Install NodeJs
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
apt-get install nodejs

# Install ansible
apt-get install ansible -y

# Install awx
git clone https://github.com/ansible/awx.git
cd awx/installer/


AWXPW=$(pwgen -N 1 -s 30)
printf "localhost ansible_connection=local ansible_python_interpreter=\"/usr/bin/env python3\"
 
 [all:vars]
 
 dockerhub_base=ansible
 
 awx_task_hostname=awx
 awx_web_hostname=awxweb
 postgres_data_dir=/var/lib/pgdocker
 host_port=8080
 
 use_docker_compose=true
 docker_compose_dir=/var/lib/awx
 
 pg_username=awx
 pg_password=$(pwgen -N 1 -s 30)
 pg_database=awx
 pg_port=5432
 
 rabbitmq_password=$(pwgen -N 1 -s 30)
 rabbitmq_erlang_cookie=$(pwgen -N 1 -s 30)
 
 admin_user=admin
 admin_password=${AWXPW}
 
 create_preload_data=True
 
 secret_key=$(pwgen -N 1 -s 64)
 
 project_data_dir=/var/lib/awx/projects
" > inventory

ansible-playbook -i inventory install.yml --connection=local

printf "
---------------------------
AWX is running on port :::8080
Username: admin
Password: ${AWXPW}
---------------------------
"
