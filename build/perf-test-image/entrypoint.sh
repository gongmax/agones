#!/usr/bin/env bash

# Copyright 2023 Google LLC All Rights Reserved.
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
PROJECT=$4
REPLICAS=$5
AUTO_SHUTDOWN_DELAY=$6
BUFFER_SIZE=$7
MIN_REPLICAS=$8
MAX_REPLICAS=$9
DURATION=${10}
CLIENTS=${11}
DURATION=${12}

export SHELL="/bin/bash"
mkdir -p /go/src/agones.dev/
ln -s /workspace /go/src/agones.dev/agones
cd /go/src/agones.dev/agones/build

gcloud config set project $PROJECT
gcloud container clusters get-credentials $TEST_CLUSTER_NAME \
        --zone=${TEST_CLUSTER_LOCATION} --project=${PROJECT}

DOCKER_RUN= make install REGISTRY='"'$REGISTRY'"' 

cd /go/src/agones.dev/agones/test/load/allocation

cp performance-test-fleet-template.yaml performance-test-fleet.yaml
cp performance-test-autoscaler-template.yaml performance-test-autoscaler.yaml
cp performance-test-variable-template.yaml performance-test-variable.yaml

sed -i 's/{replicas}/'$REPLICAS'/g' performance-test-fleet.yaml
sed -i 's/{automaticShutdownDelaySec}/'$AUTO_SHUTDOWN_DELAY'/g' performance-test-fleet.yaml

sed -i 's/{bufferSize}/'$BUFFER_SIZE'/g' performance-test-autoscaler.yaml
sed -i 's/{minReplicas}/'$MIN_REPLICAS'/g' performance-test-autoscaler.yaml
sed -i 's/{maxReplicas}/'$MAX_REPLICAS'/g' performance-test-autoscaler.yaml

sed -i 's/{duration}/'$DURATION'/g' performance-test-variable.yaml
sed -i 's/{clients}/'$CLIENTS'/g' performance-test-variable.yaml
sed -i 's/{interval}/'$DURATION'/g' performance-test-variable.yaml

kubectl apply -f performance-test-fleet.yaml
kubectl apply -f performance-test-autoscaler.yaml

while [ $(kubectl get -f performance-test-fleet.yaml -o=jsonpath='{.spec.replicas}') != $(kubectl get -f performance-test-fleet.yaml -o=jsonpath='{.status.readyReplicas}') ]
do
    sleep 1
done

cat performance-test-variable.yaml
# ./runScenario.sh performance-test-variable.yaml
echo "Finish testing."
rm performance-test-fleet.yaml performance-test-autoscaler.yaml performance-test-variable.yaml