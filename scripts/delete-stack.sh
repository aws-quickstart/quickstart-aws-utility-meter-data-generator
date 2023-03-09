#!/usr/bin/env bash

set -e

REGION=${1:-us-east-1}
BUCKETS=`aws s3 ls`
STACK_NAME=device-data-generator

for bucket in $BUCKETS
do

  if  [[ $bucket == $STACK_NAME-* ]] ;
  then
      echo "Emptying bucket: $bucket"
      {
        aws s3 rm s3://$bucket --recursive &>/dev/null
      } || {
        echo "Error emptying bucket: $bucket"
      }
  fi

done

echo "Deleting stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
