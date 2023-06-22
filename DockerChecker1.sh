#!/bin/bash

# Author : Vishal Saxena
# Date of Creation : 21-06-2023
# Date of Modification : 21-06-2023

# Description : This Script Checks the docker and docker compose is installed on system and if not it will install.


if  [ -x "$(command -v docker)" ]; then

        echo "Docker is installed on system"
else
        echo "Docker is not installed on system, Installing Docker Now .."


if [ -x "$(command -v apt-get)" ]; then
        # Debian-based distribution package
        sudo apt-get update
        sudo apt-get install -y docker.io

elif [ -x "$(command -v yum)" ]; then
        # Red Hat-based distribution (e.g., CentOS)
        sudo yum install -y docker 
        
elif [ -x "$(command -v dnf)" ]; then
        # Fedora
        sudo dnf install -y docker        
else
        echo "Unable to install Docker"
        exit 1
fi

        # Appending Current user to Docker Group 
        sudo usermod -aG docker $USER
        
fi



if  [ -x "$(command -v docker-compose)" ]; then

        echo "Docker Compose is installed on system"

else
        echo "Docker Compose is not installed on system, Installing Docker Compose Now .."
        sudo apt install curl
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        docker-compose --version
fi