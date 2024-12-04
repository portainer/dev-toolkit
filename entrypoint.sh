#!/bin/bash

# This is an entrypoint script that is used execute some actions 
# when the container is started.

# We clean-up the tmp folder as part of the startup because it can 
# be flooded very fast with files and folders related to vscode, devextension, yarn, gobuilds etc...
rm -rf /tmp/*

# Execute the default command from the base image
exec "$@"