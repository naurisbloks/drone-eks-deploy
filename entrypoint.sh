#!/bin/bash
set -eo pipefail
IFS=$'\n\t'


set_profile() {
  local aws_access_key_id=$1
  local aws_secret_access_key=$2
  local aws_region=$3

  aws configure set aws_access_key_id ${aws_access_key_id};
  aws configure set aws_secret_access_key ${aws_secret_access_key};
  aws configure set default.region ${aws_region};
  aws configure set default.output json;

}

get_kubeconfig() {
  local clustername=$1
  local rolearn=$2
  

  
  if [ -n "${rolearn}" ]
  then
  aws eks update-kubeconfig --name ${clustername} --role-arn ${rolearn};
  fi
  aws eks update-kubeconfig --name ${clustername};
  
}

k8s_resource_exist() {
  local resource=$1
  local namespace=$2
  
  set -e
  kubectl get ${resource} --namespace ${namespace}
}

update_resource() {
  local resource=$1
  local container=$2
  local image=$3
  local namespace=$4
  local registry=$5
  
  kubectl set image "${resource}" "${container}"="${registry}":"${image}" --namespace "${namespace}"
  
}

RC=0

clustername="${PLUGIN_EKS_CLUSTER}"
name="${PLUGIN_NAME}"
image_tag="${PLUGIN_IMAGE_TAG}"
container="${PLUGIN_CONTAINER}"
namespace="${PLUGIN_NAMESPACE}"
kind="${PLUGIN_KIND}"
registry="${PLUGIN_REGISTRY}"
iam_role="${PLUGIN_IAM_ROLE:-""}"
aws_access_key_id="${PLUGIN_ACCESS_KEY}"
aws_secret_access_key="${PLUGIN_SECRET_KEY}"
aws_region="${PLUGIN_AWS_REGION}"

set_profile "${aws_access_key_id}" "${aws_secret_access_key}" "${aws_region}" 

get_kubeconfig "${clustername}" "${iam_role}" 

if k8s_resource_exist "${kind}/${name}" "${namespace}"
then
  update_resource "${kind}/${name}" "${container}" "${image_tag}" "${namespace}" "$registry"
else
  echo "Resource ${kind}/${name} doesn't exist on namespace ${namespace}"
  RC=1
fi

exit $RC
