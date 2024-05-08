## Requirement

- terraform >= 1.3.2
- aws >= 5.40

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
Replace placeholders like `<your-region>`, `<eks-cluster-name>` with your actual values.

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

Get the load balancer DNS name of the Nginx Ingress service:
```
kubectl get services ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Create and Edit the values.yaml file by replacing the DNS name in ccxFQDN and sessionDomain fields.
```
sessionDomain: ccx.mycloud.com
ccxFQDN: ccx.mycloud.com
ccx:
  cloudSecrets:
   - aws
```

##### Deploy CCX using this command:

```
helm upgrade --install ccx ccx/ccx  --values values.yaml --version 1.47.0-alpha.2 --debug
```
For additional customizations, please refer to the [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks)

Note: 

The terraform will store the state in local by default. To configure Terraform State Storage in S3, Open the backend.tf file in the cloned repository and Uncomment and configure the backend "s3" block with your S3 bucket details


