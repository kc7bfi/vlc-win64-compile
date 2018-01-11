#!/bin/bash
# based on videolan-base-stretch
set -x

echo "deb http://ftp.fr.debian.org/debian/ stretch main" > /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ stretch main" >> /etc/apt/sources.list
echo "deb http://ftp.fr.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
echo "deb http://security.debian.org stretch/updates main" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org stretch/updates main" >> /etc/apt/sources.list
apt-get update
apt-get upgrade --yes
apt-get install --yes openssh-server openjdk-8-jdk lftp ca-certificates net-tools build-essential linux-headers-`$(uname -r)`
apt-get clean --yes
rm -rf /var/lib/apt/lists/*
sed -i 's|sessionrequired pam_loginuid.so|sessionoptional pam_loginuid.so|g' /etc/pam.d/sshd

