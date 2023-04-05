import os
import cv2
import json
import numpy as np
import boto3
import botocore

from enum import Enum

class ContourType(Enum):
    CIRCLE = 1
    RECTANGLE = 2
    FREE_SURFACE = 3

# custom encoder, encodes numpy types to json
# this class should be moved to an external utils module
class NumpyToJsonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return super(NumpyToJsonEncoder, self).default(obj)

def find_contours(image_file: str, contour_type: ContourType = ContourType.CIRCLE):
    assert os.path.exists(image_file), f'{image_file} does not exist'

    img = cv2.imread(image_file)
    assert img is not None, f'{image_file} could not be read'

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    binary = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    retval, binary = cv2.threshold(binary, 12, 20, cv2.THRESH_BINARY_INV)
    cv2.imwrite("../binary.jpg", binary)

    contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    return contours

def lambda_handler(event, context):
    tmp_filename='/tmp/work_image'

    bucket_name = event['bucket']
    img_file = event['image']

    img_extension = img_file.split('.')[-1]
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

    try:
        contours = find_contours(tmp_filename)
    except AssertionError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'image processing failed: {e}'})
        }

    return {
        'statusCode': 200,
        'body': json.dumps(contours, cls=NumpyToJsonEncoder)
    }

if __name__ == "__main__":
   contours = find_contours("../half-circle.png", ContourType.CIRCLE)
   print(json.dumps(contours, cls=NumpyToJsonEncoder))
