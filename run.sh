#!/bin/bash

if [ -z $AWS_PROFILE ]; then
  export AWS_PROFILE=default
  echo "AWS_PROFILE not set. Using default"
fi

if [ -z $AWS_REGION ]; then
  export AWS_REGION=ca-central-1
  echo "AWS_REGION not set. Using default ca-central-1"
fi

function login() {
  login_cmd="$(aws ecr --profile $AWS_PROFILE get-login --no-include-email --region "$AWS_REGION")"
  eval "$login_cmd"
}

# For use with local development
function build(){
  if [[ "$1" ]]; then
    docker build -t "tidal/nightwatch:$1" .
    exit
  else
    echo "Need to specify version tag such as vX where X is any number."
  fi
}

function deploy(){
  if [[ "$1" ]]; then
    login
    build
    docker tag tidal/nightwatch:$1 535558409775.dkr.ecr.ca-central-1.amazonaws.com/nightwatch:$1
    docker push 535558409775.dkr.ecr.ca-central-1.amazonaws.com/nightwatch:$1
  else
    echo "Need to specify version tag such as vX where X is any number."
  fi
}

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
