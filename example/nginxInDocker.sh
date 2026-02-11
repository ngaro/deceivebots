#!/usr/bin/env bash

#Config for docker
CONTAINER=deceivebots_example  #Name of the container to be created
IMAGE=nginx:1.29.5 #Docker image to be used
PORT=8000   #Port on which nginx will be available on the host machine ( with http://localhost:$PORT ). You can still contact nginx directly on the container with http://IP_OF_THE_CONTAINER:80 if you want

#Nginx config files. Most important files in the example
BLOCKED_USER_AGENTS=../blocked-user-agents.conf #This will become /etc/nginx/blocked-user-agents.conf in the container, and is the file that contains the regex patterns of the user agents that are bots
NGINX_CONFIG=./nginx.conf #This will become /etc/nginx/nginx.conf in the container, here we tell it when $blocked_user_agent should be 0 or 1 (using blocked-user-agents.conf)
DEFAULT_SITE_CONFIG=./default.conf #This will become /etc/nginx/conf.d/default.conf in the container, this the config of a site. Here we tell it how it should react when the visitor is a bot or a real browser

#Pages to be served
BOTPAGE=bot.html    #This will become /usr/share/nginx/html/bot.html in the container, and is the page that will be served to bots
REALBROWSERPAGE=realbrowser.html    #This will become /usr/share/nginx/html/realbrowser.html in the container, and is the page that will be served to real browsers

#You need docker installed to run this script, so check if it is installed before proceeding
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

#Check if the necessary files are present before proceeding
if [ ! -f "$NGINX_CONFIG" ]; then
    echo "Error: $NGINX_CONFIG not found! This example uses relative paths, so make sure to run this script from the example directory."
    exit 1
fi
if [ ! -f "$DEFAULT_SITE_CONFIG" ]; then
    echo "Error: $DEFAULT_SITE_CONFIG not found! This example uses relative paths, so make sure to run this script from the example directory."
    exit 1
fi
if [ ! -f "$BLOCKED_USER_AGENTS" ]; then
    echo "Error: $BLOCKED_USER_AGENTS not found! This example uses relative paths, so make sure to run this script from the example directory."
    echo "If you are doing this, make sure to use the perl script to create the blocked-user-agents.conf file in the directory above this one."
    exit 1
fi

#Check if a container with the same name already exists before proceeding
if [ "$(docker ps -aq -f name=^/${CONTAINER}$)" ]; then
    echo "Error: A container with the name $CONTAINER already exists! Please remove it before running this script."
    exit 1
fi

#Run the container with the specified configurations
docker run -d --rm --name $CONTAINER -p $PORT:80 \
    -v $(realpath $NGINX_CONFIG):/etc/nginx/nginx.conf:ro \
    -v $(realpath $DEFAULT_SITE_CONFIG):/etc/nginx/conf.d/default.conf:ro \
    -v $(realpath $BLOCKED_USER_AGENTS):/etc/nginx/blocked-user-agents.conf:ro \
    -v $(realpath $BOTPAGE):/usr/share/nginx/html/bot.html:ro \
    $IMAGE && {
        echo "Nginx is running, you can access it at http://localhost:$PORT with different user agents to see the different responses."
        echo "To see what nginx is doing, run \"docker logs -f $CONTAINER\". To stop the container, run \"docker stop $CONTAINER\"."
    } || echo "Error: Failed to start the container $CONTAINER."
