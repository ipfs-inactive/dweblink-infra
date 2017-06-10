#!/bin/sh

# Update apt and get dependencies
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim

# Download Nomad
echo Fetching Nomad...
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip -o nomad.zip

echo Installing Nomad...
unzip nomad.zip
chmod +x nomad
mv nomad /usr/bin/nomad

mkdir -p /etc/nomad.d
chmod a+w /etc/nomad.d
