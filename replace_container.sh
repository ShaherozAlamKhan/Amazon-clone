#!/bin/bash
 
# Find the container running on port 8000
container_id=$(docker ps --filter "publish=8000" --format "{{.ID}}")
 
# Check if a container is running on port 8000
if [ -n "$container_id" ]; then
     echo "Stopping container with ID: $container_id"
     docker stop "$container_id"
     docker rm "$container_id"
     echo "Container stopped and removed."
else
     echo "No container is running on port 8000."
fi

# Run a new container on port 8000
echo "Running new container on port 8000..."
docker run -d -p 8000:80 myapp