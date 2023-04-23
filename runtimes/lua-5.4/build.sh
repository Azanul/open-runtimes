#!/bin/sh

# Fail build if any command fails
set -e

# Prepare separate directory to prevent changing user's files
cp -R /usr/code/* /usr/builds

# Install User Function Dependencies if requirements.txt exists
cd /usr/builds
if [ -f "solarsystem.rockspec" ]; then
    luarocks install solarsystem.rockspec
fi

# Finish build by preparing tar to use for starting the runtime
tar --exclude code.tar.gz -zcf /usr/code/code.tar.gz .