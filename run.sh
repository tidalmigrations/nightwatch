#!/bin/bash

# Compatible with AWS CLI v1.X
function login() {
  login_cmd="$(aws ecr --profile $AWS_PROFILE get-login --no-include-email --region "$AWS_REGION")"
  eval "$login_cmd"
}

# Compatible with AWS CLI v2.X
function login_v2() {
  registry="535558409775.dkr.ecr.ca-central-1.amazonaws.com"
  aws ecr --profile $AWS_PROFILE --region "$AWS_REGION" get-login-password | docker login --username AWS --password-stdin $registry
}

# For use with local development
function build(){
  if [[ "$1" ]]; then
    docker build -t "tidal/nightwatch:$1" .
  else
    echo "Need to specify version tag such as vX where X is any number."
  fi
}

function deploy(){
  if [[ "$1" ]]; then
    build "$@"
    docker tag tidal/nightwatch:$1 535558409775.dkr.ecr.ca-central-1.amazonaws.com/nightwatch:$1
    docker push 535558409775.dkr.ecr.ca-central-1.amazonaws.com/nightwatch:$1
  else
    echo "Need to specify version tag such as vX where X is any number."
  fi
}

if [ -z $AWS_PROFILE ]; then
  export AWS_PROFILE=default
  echo "AWS_PROFILE not set. Using default"
fi

if [ -z $AWS_REGION ]; then
  export AWS_REGION=ca-central-1
  echo "AWS_REGION not set. Using default ca-central-1"
fi

if [ "$AWS_CLI_V" = "1" ]; then
  echo "Expecting to login using AWS CLI V1.X, if you have v2.X installed, set the env var 'AWS_CLI_V=2'."
  login
else
  echo "Expecting to login using AWS CLI V2.X, if you have v1.X installed, set the env var 'AWS_CLI_V=1'."
  login_v2
fi

if [[ "$1" ]]; then
  "$@"
  exit $!
else
  echo Usage:
  echo
  echo "$0 COMMAND"
  echo Possible commands:
  echo
  echo login - login into the docker service
  echo build vX - build the docker image with a version tag
  echo deploy vX - deploy the docker image with a version tag
  echo
  echo Note: vX is meant to be a v followed by an integer ex. v1
fi
