#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
LAMBDA_BUCKET=lambda-lib-layers-$ACCOUNT_ID
FUNCTION_NAME=opencv_gray
ROLE_NAME=lambda-opencv_exec
LAYER_NAME=cv2-libs

aws s3api head-bucket --bucket $LAMBDA_BUCKET
[ $? -ne 0 ] && aws s3 mb s3://$LAMBDA_BUCKET

rm -f app.zip
zip app.zip app.py
[ $? -eq 0 ] && aws s3 cp app.zip s3://$LAMBDA_BUCKET
[ $? -eq 0 ] && aws lambda create-function --function-name $FUNCTION_NAME --timeout 20 --role arn:aws:iam::${ACCOUNT_ID}:role/$ROLE_NAME --handler app.lambda_handler --runtime python3.9 --code S3Bucket="$LAMBDA_BUCKET",S3Key="app.zip"
[ $? -eq 0 ] && sleep 5
[ $? -eq 0 ] && LAYER=$(aws lambda list-layer-versions --layer-name $LAYER_NAME | jq -r '.LayerVersions[0].LayerVersionArn')
[ $? -eq 0 ] && aws lambda update-function-configuration --function-name $FUNCTION_NAME --layers $LAYER
