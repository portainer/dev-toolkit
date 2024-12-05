#!/bin/bash

# This script can trigger actions post dev container startup.

# We clean-up the tmp folder as part of the startup because it can 
# be flooded very fast with files and folders related to vscode, devextension, yarn, gobuilds etc...
rm -rf /tmp/*
