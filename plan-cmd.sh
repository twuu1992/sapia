#!/bin/bash

cd ./ap-southeast-2
terraform init
terraform plan
# terraform apply -auto-approve

cd ../eu-west-1
terraform init
terraform plan
# terraform apply -auto-approve