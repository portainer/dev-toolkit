#!/bin/bash

# This script can trigger actions post dev container startup.

# We clean-up the tmp folder as part of the startup because it can 
# be flooded very fast with files and folders related to vscode, devextension, yarn, gobuilds etc...
# This removes all the files in the /tmp folder that do not start with vscode, we keep these one
# as they are needed by the devcontainer extension.
# Note: this can lead to flooding of vscode* files in the /tmp folder, until a better solution
# is found, you can periodically clean the tmp folder via rm -rf /tmp/ before stopping the devcontainer.
find /tmp -mindepth 1 ! -name 'vscode*' -exec rm -rf {} +