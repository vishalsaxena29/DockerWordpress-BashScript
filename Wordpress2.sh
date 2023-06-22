#!/bin/bash

# Author : Vishal Saxena
# Date of Creation : 21-06-2023
# Date of Modification : 21-06-2023

# Description : This Script works with the LEMP stack along with the wordpress , nginx , mysql installation with user input for sitename. 


# Check if site name argument is provided
if [ -z "$1" ]; then
  echo "Please provide a site name as a command-line argument."
  exit 1
fi

# Set variables
SITE_NAME="$1"
MYSQL_ROOT_PASSWORD="root"
MYSQL_DATABASE="${SITE_NAME}_db"
MYSQL_USER="${SITE_NAME}_user"
MYSQL_PASSWORD="root"

# Create directory for site
mkdir "$SITE_NAME"
cd "$SITE_NAME"

# Create docker-compose.yml file
cat >docker-compose.yml <<EOL
version: '3'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      MYSQL_DATABASE: $MYSQL_DATABASE
      MYSQL_USER: $MYSQL_USER
      MYSQL_PASSWORD: $MYSQL_PASSWORD

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: $MYSQL_USER
      WORDPRESS_DB_PASSWORD: $MYSQL_PASSWORD
      WORDPRESS_DB_NAME: $MYSQL_DATABASE
    volumes:
      - ./wp-content:/var/www/html/wp-content

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    restart: always
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./wp-content:/var/www/html/wp-content

volumes:
  db_data:
EOL

# Create Nginx configuration file
cat >nginx.conf <<EOL
events {}

http {
  server {
    listen 80;
    server_name localhost;

    location / {
      proxy_pass http://wordpress;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
    }
  }
}
EOL

# Start the containers
docker-compose up -d

sleep 5

#  Script Create a /etc/hosts entry for example.com pointing to localhost.
#  As I am running the Script on AWS Cloud Console and fetching the public address where the wordpress is configured.

ip_address=$(curl -s ifconfig.me)

sudo sh -c "echo $ip_address example.com >> /etc/hosts"

echo "WordPress site '$SITE_NAME' with LEMP stack has been created successfully!"

sleep 5

read -p "Do you want to disable or enable the Site: " response

if  [ "$response" == "yes" ] || [ "$response" == "y" ] || [ "$response" == "Yes" ] || [ "$response" == "YES" ]; then
            echo "Disabling the $SITE_NAME running on container .."
            container_id=$(docker ps --filter "name=wordpress" --format "{{.ID}}")
            docker stop $container_id
    else
            echo "Enabling the $SITE_NAME .."
            docker-compose up -d
fi

delete_site() {

  # Stop and remove the containers
  
  docker-compose down

  # Delete the site directory
  cd ..
  rm -rf "$SITE_NAME"

  # Display deletion success message
  echo "WordPress site '$SITE_NAME' has been deleted successfully!"

}


read -p "Do you want to delete the site? (y/n): " answer
if [[ $answer == "y" ]]; then
  delete_site
fi