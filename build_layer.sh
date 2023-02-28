#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
LAMBDA_LAYERS_BUCKET=lambda-lib-layers-$ACCOUNT_ID
LAYER_NAME=cv2-libs

aws s3api head-bucket --bucket $LAMBDA_LAYERS_BUCKET
[ $? -ne 0 ] && aws s3 mb s3://$LAMBDA_LAYERS_BUCKET

rm -f cv2-python39.zip
docker build -t cv2-lambda-layer .
[ $? -eq 0 ] && docker run --rm -it -v $(pwd):/data:Z cv2-lambda-layer cp /packages/cv2-python39.zip /data
[ $? -eq 0 ] && aws s3 cp cv2-python39.zip s3://$LAMBDA_LAYERS_BUCKET
[ $? -eq 0 ] && aws lambda publish-layer-version --layer-name $LAYER_NAME --description "Common Libraries" --content S3Bucket=$LAMBDA_LAYERS_BUCKET,S3Key=cv2-python39.zip --compatible-runtimes python3.9
