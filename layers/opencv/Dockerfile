FROM amazonlinux

ARG PYTHON_VERSION=3.9.16

RUN yum update -y
RUN yum install gcc openssl-devel bzip2-devel libffi-devel wget tar gzip zip make -y

WORKDIR /
RUN wget https://www.python.org/ftp/python/"$PYTHON_VERSION"/Python-"$PYTHON_VERSION".tgz
RUN tar -xzvf Python-"$PYTHON_VERSION".tgz
WORKDIR /Python-"$PYTHON_VERSION"
RUN ./configure --enable-optimizations
RUN make altinstall

WORKDIR /
RUN mkdir /packages
COPY requirements.txt /packages/requirements.txt
RUN echo "opencv-python-headless" >> /packages/requirements.txt
RUN mkdir -p /packages/opencv-python-3.9/python/lib/python3.9/site-packages
RUN pip3.9 install -r /packages/requirements.txt -t /packages/opencv-python-3.9/python/lib/python3.9/site-packages

WORKDIR /packages/opencv-python-3.9/
RUN zip -r9 /packages/cv2-python39.zip .
WORKDIR /packages/
RUN rm -rf /packages/opencv-python-3.9/
