import cv2
import json
import jsonpickle
import logging
import boto3
import botocore
import os

def lambda_handler(event, context):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.info('event parameter: %s', jsonpickle.encode(event))
    logger.info('context parameter: %s', jsonpickle.encode(context))
    tmp_filename='/tmp/work_image'

    bucket_name = event['bucket']
    img_file = event['image']

    img_extension = img_file.split('.')[-1]
    output_image = f'{".".join(img_file.split(".")[:-1])}_gray.{img_extension}'
    tmp_filename = f'{tmp_filename}.{img_extension}'

    s3 = boto3.resource('s3')
    try:
        s3.Bucket(bucket_name).download_file(img_file, tmp_filename)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == '404':
            return {
                'statusCode': 404,
                'body': json.dumps({'message': f'image s3://{bucket_name}/{img_file} does not exist'})
            }
        else:
            raise

    image = cv2.imread(tmp_filename)
    image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cv2.imwrite(tmp_filename, image_gray)

    s3 = boto3.client('s3')
    s3.upload_file(tmp_filename, bucket_name, output_image)

    return {
        'statusCode': 200,
        'body': json.dumps({'output_image': f's3://{bucket_name}/{output_image}'})
    }
