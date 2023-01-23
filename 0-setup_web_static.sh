#!/usr/bin/env bash

# Check if Nginx is installed
if ! which nginx > /dev/null; then
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Create necessary directories
if [ ! -d "/data" ]; then
    sudo mkdir /data
fi
if [ ! -d "/data/web_static" ]; then
    sudo mkdir /data/web_static
fi
if [ ! -d "/data/web_static/releases" ]; then
    sudo mkdir /data/web_static/releases
fi
if [ ! -d "/data/web_static/shared" ]; then
    sudo mkdir /data/web_static/shared
fi
if [ ! -d "/data/web_static/releases/test" ]; then
    sudo mkdir /data/web_static/releases/test
fi

# Create a fake index.html file
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Remove existing symbolic link, if any
if [ -L "/data/web_static/current" ]; then
    sudo rm /data/web_static/current
fi

# Create a new symbolic link to the test release
sudo ln -s /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to the ubuntu user and group
sudo chown -R ubuntu:ubuntu /data

# Update Nginx configuration
sudo sed -i 's/root \/var\/www\/html;/root \/data\/web_static\/current;/g' /etc/nginx/sites-available/default
sudo sed -i 's/# location \/ {/location \/hbnb_static\/ {/g' /etc/nginx/sites-available/default
sudo sed -i 's/#     alias \/usr\/share\/nginx\/html;/    alias \/data\/web_static\/current;/g' /etc/nginx/sites-available/default
sudo service nginx restart

exit 0
