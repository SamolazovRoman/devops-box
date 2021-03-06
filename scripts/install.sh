#!/bin/bash
set -x

TERRAFORM_VERSION="0.11.3"
PACKER_VERSION="1.1.3"
# create new ssh key
[[ ! -f /home/ubuntu/.ssh/id_rsa ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& echo '-----BEGIN RSA PRIVATE KEY-----
*
-----END RSA PRIVATE KEY-----
' >> /home/ubuntu/.ssh/id_rsa \
&& echo 'ssh-rsa *
' >> /home/ubuntu/.ssh/id_rsa.pub \
&& sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh \
&& chmod 400 /home/ubuntu/.ssh/id_rsa /home/ubuntu/.ssh/id_rsa.pub

#[[ ! -f /home/ubuntu/.ssh/id_rsa ]] \
#&& mkdir -p /home/ubuntu/.ssh \
#&& ssh-keygen -f /home/ubuntu/.ssh/id_rsa -N '' \
#&& sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh \
#&& chmod 400 /home/ubuntu/.ssh/id_rsa /home/ubuntu/.ssh/id_rsa.pub

# install packages
apt-get update
apt-get -y install docker.io unzip
# Add ansible repo
apt-add-repository ppa:ansible/ansible
# Run apt-get update
apt-get update
# Install ansible
apt-get -y install ansible 
# add docker privileges
usermod -G docker ubuntu
# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install cli
pip install -U awscli
pip install -U awsebcli
pip install -U ansible-tower-cli
sudo pip install -t /usr/lib/python2.7/dist-packages/ boto
sudo pip install -t /usr/lib/python2.7/dist-packages/ boto3
sudo pip install -t /usr/lib/python2.7/dist-packages/ futures
sudo pip install -t /usr/lib/python2.7/dist-packages/ xmltodict
sudo pip install -t /usr/lib/python2.7/dist-packages/ pywinrm

# create new AWS key
[[ ! -f /home/ubuntu/.aws/credentials ]] \
&& mkdir -p /home/ubuntu/.aws \
&& echo '[default]
aws_access_key_id = A??????????????????A
aws_secret_access_key = R???????????????????????????????????????Z
' >> /home/ubuntu/.aws/credentials \
&& echo '[default]
region = us-east-1
' >> /home/ubuntu/.aws/config \
&& sudo chown -R ubuntu:ubuntu /home/ubuntu/.aws

#terraform
T_VERSION=$(terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# clean up
apt-get clean
