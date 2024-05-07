## Deploying CCX Application on Amazon EKS Using Terraform
This guide outlines the steps to deploy the CCX application on Amazon EKS using Terraform for cluster provisioning and Helm for application deployment.

#### Clone Terraform Configuration Repository
```
git clone git@github.com:severalnines/terraform-ccx.git
cd terraform-ccx/aws-eks
```
Open the provider.tf file in the cloned repository.
Add your AWS access key and secret key to the provider configuration.

####  Provision EKS Cluster
Run the following Terraform commands:
```
terraform init
terraform validate
terraform plan
terraform apply
```

Once the EKS clusters are created, use the following command to create the kubeconfig file for your cluster:

```
aws eks update-kubeconfig --region <your-region> --name <eks-cluster-name>
```

####  Deploy CCX Workloads
Create a namespace to deploy CCX workloads:

```
kubectl create ns production
```

####  Prerequisites for CCX Deployment
Input your AWS credentials and create a Kubernetes secret using the template saved in a YAML file such as aws.yaml:

```
apiVersion: v1
kind: Secret
metadata:
  name: aws
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: <CHANGE_ME>
  AWS_SECRET_ACCESS_KEY: <CHANGE_ME>

```

Apply the YAML file.

```
kubectl apply -f aws.yaml
```

####  Deploy CCX Dependencies

```
helm install ccxdeps ccxdeps/ccxdeps --debug --set ingressController.enabled=true --set external-dns.enabled=true
```

####  Deploy CCX Application
Clone the CCX Helm chart repository:

```
git clone git@github.com:severalnines/helm-ccx.git
cd helm-ccx
git checkout release/1.47-public-images-tests
cd ../
```

Get the load balancer DNS name of the Nginx Ingress service:
```
kubectl get services ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Edit the minimal-values.yaml file in the helm-ccx folder by replacing the DNS name in ccxFQDN and sessionDomain fields.

#### Deploy CCX using this command:

```
helm upgrade --install ccx helm-ccx/  --values helm-ccx/minimal-values.yaml --debug
```
Note: Replace placeholders like <your-region>, <eks-cluster-name>, and AWS credentials with your actual values.
The terraform will store the state in local but if you want to store in s3 bucket you need to edit the backend.tf file with configs

