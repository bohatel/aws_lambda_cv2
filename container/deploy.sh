#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
FUNCTION_NAME=object_detection_container
ROLE_NAME=lambda-opencv_exec
IMAGE_URI=$(aws ecr describe-repositories --repository-names lambda-functions | jq -r ".repositories[0].repositoryUri")
REGISTRY_URI=$(aws ecr describe-repositories --repository-names lambda-functions | jq -r '.repositories[0].repositoryUri | split("/")[0]')

[ $? -eq 0 ] && aws ecr get-login-password | docker login --username AWS --password-stdin "$REGISTRY_URI"
[ $? -eq 0 ] && docker build -t lambda-cv2-example -f container/Dockerfile .
[ $? -eq 0 ] && docker tag lambda-cv2-example:latest "$IMAGE_URI":latest
[ $? -eq 0 ] && docker push "$IMAGE_URI":latest
[ $? -eq 0 ] && aws lambda create-function --function-name $FUNCTION_NAME --timeout 20 --role arn:aws:iam::${ACCOUNT_ID}:role/$ROLE_NAME --package-type Image --code ImageUri="$IMAGE_URI":latest

