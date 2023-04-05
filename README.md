# Sample Lambda function for contour detection using OpenCV in layer
## Prerequisites
1. AWS CLI
2. Docker
3. An AWS IAM user with permissions to manage Lambda

## Before deploying the function
1. Run `./create_profile.sh` to provision the IAM role used for the function
2. `cd layers/opencv`
3. Run `./build_layer.sh`. The script builds a lambda layer with OpenCV and all the libraries defined in requirements.txt installed in it. Note that OpenCV + numpy results in in a layer of ~200MB uncompressed (66MB zip) which does not leave a lot of headroom for additional heavy libraries

## Deploy the Function
1. Edit app.py and change the code as desired. Current implementation takes as input a bucket name + an image file name, converts it to gray scale and saves the new image in the same bucket
2. Run `deploy_function.sh` to upload the function and attach the latest version of the opencv layer to it.

## Deploy function from container
1. Create an ECR repository
`aws ecr create-repository --repository-name lambda-functions --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE`
2. Run `./container/deploy.sh`. This script build the container image, pushes it to the ECR repository and creates the lambda function

## Function Parameters
- `bucket`: S3 bucket where images are stored
- 'image': the image file name
- `binarization_threshold`: threshold for `cv2.threshold` function
- `outer_only`: controls the mode parameter for `findContours`
- `size_threshold`: minimum area for for detected contours

## Return format
```
[
    {
        area: float
        perimeter: float
        points: [...]
    }
    ...
]
```
