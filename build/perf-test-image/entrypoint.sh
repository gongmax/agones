#!/usr/bin/env bash

# Copyright 2018 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e
TEST_CLUSTER_NAME=$1
TEST_CLUSTER_LOCATION=$2
REGISTRY=$3

export SHELL="/bin/bash"
mkdir -p /go/src/agones.dev/
ln -s /workspace /go/src/agones.dev/agones
cd /go/src/agones.dev/agones/build

gcloud container clusters get-credentials $TEST_CLUSTER_NAME \
        --zone=${TEST_CLUSTER_LOCATION} --project=gongmax-gke-dev

DOCKER_RUN= make install REGISTRY='"'$REGISTRY'"' 

cd /go/src/agones.dev/agones/test/load/allocation
kubectl apply -f fleet.yaml
kubectl apply -f autoscaler.yaml
DESIRED=$(kubectl get -f fleet.yaml -o=jsonpath='{.spec.replicas}')
ACTUAL=$(kubectl get -f fleet.yaml -o=jsonpath='{.status.readyReplicas}')

echo "Desired: $DESIRED"
echo "Actual: $ACTUAL"

while [ $(kubectl get -f fleet.yaml -o=jsonpath='{.spec.replicas}') != $(kubectl get -f fleet.yaml -o=jsonpath='{.status.readyReplicas}') ]
do
    sleep 1
done

ls
./runScenario.sh variable2.txt
echo "Finish testing."