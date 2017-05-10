#!/usr/bin/env bash

lambda_project_home="/Users/joarley/Dev/github/aws_lambda_deploy/project_template"
dist_dir_name="dist"
proj_file_names=("src" "conf" "data")
pip_env_dir_name="env"
n_libs_dir_name="native_libs"
deploy_bundle_name="lambda_bundle.zip"

lambda_function_name="awesome-lambda-function"
s3_deploy_bucket="awesome-lambda-code"
s3_deploy_key=${deploy_bundle_name}
aws_cli_profile="namelabs"


dist_path=${lambda_project_home}/${dist_dir_name}

echo "Cleaning up dist dir ..."
rm -rf ${dist_path}/*

echo "Adding source files ..."

for sf in "${proj_file_names[@]}"
do
    proj_path=${lambda_project_home}/${sf}
    cp -rf ${proj_path} ${dist_path}
done

echo "Adding pip libs ..."

env_path=${lambda_project_home}/${pip_env_dir_name}
cp -rf ${env_path}/lib/python2.7/site-packages/* ${dist_path}


if [ -z "$n_libs_dir_name" ]; then
    echo "n_libs_dir_name is unset";
else
    n_libs_path=${lambda_project_home}/${n_libs_dir_name}
    echo "Adding native libs"
    cp -rf ${n_libs_path}/* ${dist_path}
fi

echo "Create deployment package folder ..."

cd ${dist_path}

zip -q -r ${deploy_bundle_name} .

mv ${deploy_bundle_name} ${lambda_project_home}/

cd -

echo "Uploading deployment package to S3 ..."

deploy_bundle_path=${lambda_project_home}/${deploy_bundle_name}
aws s3 cp ${deploy_bundle_path} s3://${s3_deploy_bucket}/${s3_deploy_key} --profile ${aws_cli_profile}

echo "Updating Lambda functions ..."

aws lambda update-function-code --function-name ${lambda_function_name} \
    --s3-bucket ${s3_deploy_bucket} --s3-key ${s3_deploy_key} \
    --publish --profile ${aws_cli_profile}

echo "Deployment completed"





