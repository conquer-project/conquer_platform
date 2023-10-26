#!/bin/bash

set -eo pipefail

kubectl api-resources --verbs=list --namespaced=false | awk '{ if (NR!=1) {print $1} }' | xargs -n 1 kubectl get --show-kind --ignore-not-found