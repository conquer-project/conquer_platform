#!/bin/bash

set -eo pipefail

for environment in dev staging prod; do
    echo "Destroying $environment environment" >> "$GITHUB_OUTPUT"
    terraform init
    terraform workspace select "$environment"
    terraform destroy --auto-approve
    echo "$environment destroyed" >> "$GITHUB_OUTPUT"
done