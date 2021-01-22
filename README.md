# Drone EKS plugin

Drone plugin to get credentials and deploy to an EKS cluster.

## Usage

Resource should exist before this plugin can be executed. Works better if the pipeline is executed on an EC2 instance with an instance role that have permissions.

```yaml
kind: pipeline
name: default

steps:
- name: deploy_to_eks
  image: 135746454934.dkr.ecr.eu-central-1.amazonaws.com/drone-eks-deploy
  settings:
    eks_cluster: ${EKS_CLUSTER_NAME}
    name: ${RESOURCE_NAME}
    image_tag: ${IMAGE_TAG_NAME}
    container: ${CONTAINER_NAME}
    namespace: ${K8S_NAMESPACE}
    kind: ${K8S_RESOURCE_TYPE}
    registry: ${AWS_REGISTRY_URI}
    repo: ${AWS_REGISTRY_REPO}
    iam_role: ${AWS_IAM_ROLE}  # Optional, default to ""
    access_key: ${AWS_ACCESS_KEY_ID}
    secret_key: ${AWS_SECRET_ACCESS_KEY}
    aws_region: ${AWS_REGION}
```

## IAM permissions

Since the plugin gets the KUBECONFIG from `aws-cli`, proper IAM permissions are necessary to download. Here is a simple IAM policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEKSAccess",
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": [
                "arn:aws:eks:eu-west-1:820102917197:cluster/${CLUSTER_NAME}"
            ]
        }
    ]
}
```

Besides, you need to link [aws-auth](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html) to a RBAC policy that allows proper permissions to update needed resources.
