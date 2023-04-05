FROM public.ecr.aws/lambda/python:3.9

COPY container/requirements.txt  .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY ../object_selection.py ${LAMBDA_TASK_ROOT}

CMD [ "object_selection.lambda_handler" ]
