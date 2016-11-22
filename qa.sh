#!/bin/bash
#
# Kinda like a local travisCI run
#
#######################################

bundle install > /dev/null

PUPPET_GEM_VERSION="~> 3.3.0"
bundle update > /dev/null
rake spec

if [ $? -ne 0 ];then
  echo "ERROR with puppet 3.3"
  exit 1;
fi

PUPPET_GEM_VERSION="~> 3.8.0"
bundle update > /dev/null
rake spec

if [ $? -ne 0 ];then
  echo "ERROR with puppet 3.8"
  exit 1;
fi

PUPPET_GEM_VERSION="~> 4.2.3"
bundle update > /dev/null
rake spec

if [ $? -ne 0 ];then
  echo "ERROR with puppet 4.2"
  exit 1;
fi

echo "

Verified with puppet 3.3, 3.8, and 4.2
"
