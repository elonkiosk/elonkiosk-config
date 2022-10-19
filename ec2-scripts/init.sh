#!/bin/bash

# Install Node.js
bash <(curl -sL https://raw.githubusercontent.com/haeramkeem/sh-it/main/install/nodejs.sh)

# Install PM2
source ~/.bashrc
npm i -g pm2
pm2 status

# Install aws-cli
bash <(curl -sL https://raw.githubusercontent.com/haeramkeem/sh-it/main/install/aws-cli/linux.sh)
# Do `aws configure`

# Install codedeploy-agent
bash <(curl -sL https://raw.githubusercontent.com/haeramkeem/sh-it/main/install/codedeploy-agent/amzn2.sh)
