#!/bin/bash

# Update package index and install necessary packages

sudo yum update -y
sudo yum install -y python3 python3-pip

python3 -m ensurepip

sudo yum install git
git clone https://github.com/felixcs1/langchain-app.git

echo "SETUP SCRIPT EXECUTED!!"


# sudo yum update -y
# sudo amazon-linux-extras install docker
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# sudo chkconfig docker on
# Install PyTorch
# pip3 install torch torchvision torchaudio