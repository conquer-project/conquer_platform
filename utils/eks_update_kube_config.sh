#!/bin/bash

set -eo pipefail
aws eks list-clusters --region eu-north-1 | yq '.clusters[]' | xargs -I {} aws eks update-kubeconfig --region eu-north-1 --name {}