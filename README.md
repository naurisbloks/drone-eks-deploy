# Drone EKS plugin
Drone plugin to get credentials and update resources to an AWS EKS cluster from AWS ECR repositories

# This plugin updates resources on AWS EKS cluster taking images from AWS ECR repositories.
Resources should exist in AWS EKS cluster before this plugin can be executed, this plugin only updates existing containers by taking images from AWS ECR repositories.

```yaml
kind: pipeline
name: default

steps:
- name: deploy-to-eks
  image: public.ecr.aws/l8i5v6c3/drone-eks-deploy:latest
  settings:
    eks_cluster: ${EKS_CLUSTER_NAME} # Kubernetes cluster name
    name: ${RESOURCE_NAME} # Kubernetes resource name which will be updated
    image_tag: ${IMAGE_TAG_NAME} # Tag of image that should be set
    container: ${CONTAINER_NAME} # Container name
    namespace: ${K8S_NAMESPACE} # Namespace of resource
    kind: ${K8S_RESOURCE_TYPE} # Resource type, for example, deployment.apps
    registry: ${AWS_REGISTRY_URI} # AWS ECR repository URI -> <account_number>.dkr.ecr.<region>.amazonaws.com
    repo: ${AWS_REGISTRY_REPO} # AWS ECR repository name
    iam_role: ${AWS_IAM_ROLE}  # AWS IAM role, optional, default to ""
    access_key: ${AWS_ACCESS_KEY_ID} # AWS access key ID
    secret_key: ${AWS_SECRET_ACCESS_KEY} # AWS secret access key
    aws_region: ${AWS_REGION} # AWS region
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
                "arn:aws:eks:${REGION}:820102917197:cluster/${CLUSTER_NAME}"
            ]
        }
    ]
}
```
Besides, you need to link [aws-auth](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html) to a RBAC policy that allows proper permissions to update needed resources.

## Special thanks
Inspired by [samcre/drone-eks](https://github.com/samcre/drone-eks)