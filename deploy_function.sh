#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
LAMBDA_BUCKET=lambda-lib-layers-$ACCOUNT_ID
FUNCTION_NAME=object_selection
ROLE_NAME=lambda-opencv_exec
LAYER_NAME=cv2-libs

aws s3api head-bucket --bucket $LAMBDA_BUCKET
[ $? -ne 0 ] && aws s3 mb s3://$LAMBDA_BUCKET

rm -f preprocessing.zip
zip preprocessing.zip object_selection.py
[ $? -eq 0 ] && aws s3 cp preprocessing.zip s3://$LAMBDA_BUCKET

[ $? -eq 0 ] && aws lambda get-function --function-name $FUNCTION_NAME
if [ $? -ne 0 ]
then
    aws lambda create-function --function-name $FUNCTION_NAME --timeout 20 --role arn:aws:iam::${ACCOUNT_ID}:role/$ROLE_NAME --handler object_selection.lambda_handler --runtime python3.9 --code S3Bucket="$LAMBDA_BUCKET",S3Key="preprocessing.zip"
    [ $? -eq 0 ] && sleep 5
    [ $? -eq 0 ] && LAYER=$(aws lambda list-layer-versions --layer-name $LAYER_NAME | jq -r '.LayerVersions[0].LayerVersionArn')
    [ $? -eq 0 ] && aws lambda update-function-configuration --function-name $FUNCTION_NAME --layers $LAYER
else
    aws lambda update-function-code --function-name $FUNCTION_NAME --s3-bucket $LAMBDA_BUCKET --s3-key preprocessing.zip
fi
[ $? -eq 0 ] && rm -f preprocessing.zip

