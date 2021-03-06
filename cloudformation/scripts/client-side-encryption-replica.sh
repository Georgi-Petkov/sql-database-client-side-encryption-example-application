#!/bin/bash
set -Eeuox pipefail

BUCKET=BUCKET-NAME-HERE
STACK_NAME=STACK-NAME-HERE

aws s3api create-bucket --bucket ${BUCKET} --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION"

pushd ../templates

aws cloudformation validate-template --template-body file://cfn.client-side-encryption-replica.yaml

sam build --template cfn.iamauthentication.yaml --build-dir ../tmp/iamauthentication-build-dir
sam build --template cfn.client-side-encryption-replica.yaml --build-dir ../tmp/client-side-encryption-replica-build-dir

sam package \
    --s3-bucket "$BUCKET" \
    --output-template-file ../tmp/packaged-cfn.client-side-encryption-replica.yaml \
    --template-file ../tmp/client-side-encryption-replica-build-dir/template.yaml

sam deploy \
    --stack-name "$STACK_NAME" \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
    --template-file ../tmp/packaged-cfn.client-side-encryption-replica.yaml

popd
