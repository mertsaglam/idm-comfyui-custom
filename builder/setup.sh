#!/bin/bash

# Stop script on error
set -e

# Update System
apt-get update && apt-get upgrade -y

# Install System Dependencies
apt-get install -y --no-install-recommends libgl1 libglib2.0-0 git aria2 ffmpeg unzip gcc g++

# Clean up
apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*