eksctl create cluster \
--name my-cluster \
--region ap-south-1 \
--fargate


eksctl create cluster \
--name my-cluster \
--region ap-south-1 \
--with-oidc \
--ssh-access \
--ssh-public-key ujjwalAWS

eksctl delete cluster --name my-cluster --region ap-south-1

###
# Dont forget to delete the PVC fucking doesnt get cleared.


docker tag aca5466f4cb2  \
    458516813260.dkr.ecr.ap-south-1.amazonaws.com/ujjwal:1.0.0

docker push 458516813260.dkr.ecr.ap-south-1.amazonaws.com/ujjwal:1.0.0

aws ecr get-login-password --region ap-south-1 | \
    docker login --username AWS --password-stdin \
    458516813260.dkr.ecr.ap-south-1.amazonaws.com


ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")


oidc.eks.ap-south-1.amazonaws.com/id/B1029758B6911567E95DB29A031F9B50


eksctl create iamserviceaccount \
    --name <kubernetes_service_account_name> \
    --namespace <kubernetes_service_account_namespace> \
    --cluster <cluster_name> \
    --attach-policy-arn <IAM_policy_ARN> \
    --approve \
    --override-existing-serviceaccounts


helm install my-artifactory ./artifactory \
    --set-string nginx.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-internal"="true" \
    --set postgreql.enabled="false"

helm uninstall my-artifactory


eksctl create cluster -f cluster.yaml
eksctl delete cluster -f cluster.yaml


## Setup helm repo
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
kubectl create namespace nginx-ingress
helm install nginx nginx-stable/nginx-ingress -n nginx-ingress --set controller.enableCustomResources=true
helm uninstall nginx -n nginx-ingress

