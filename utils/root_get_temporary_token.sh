#!/bin/bash

function main(){
    # Get aws temporary token
    creds=$(aws sts get-session-token --duration 3600 | jq '.Credentials')
    
    # Export variables
    unset AWS_PROFILE
    unset AWS_REGION
    export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId'<<<"$creds")
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey'<<<"$creds")
    export AWS_SESSION_TOKEN=$(jq -r '.SessionToken'<<<"$creds")
}

main
