#!/bin/bash

# This script can trigger actions post dev container startup.

# We clean-up the tmp folder as part of the startup because it can 
# be flooded very fast with files and folders related to vscode, devextension, yarn, gobuilds etc...
# This removes all the files in the /tmp folder that are older than 3 days.
find /tmp -mindepth 1 -mtime +3 -exec rm -rf {} +