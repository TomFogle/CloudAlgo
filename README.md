# DataGhost

### Overview
Autoscaling API service to plug and play texts and text comparison methods.

### Breakdown
The API portion of this project is the start of a platform where users can select from a number of similarity comparison methods to compare two texts. Will add an additional endpoint to accept requests from other APIs to compare batches of their own text.

The infrastructure is based in AWS EKS, with an autoscaling cluster that deploys my dockerized API and is provisioned in Terraform. App can be substituted with a different image.

API can be pulled from dockerhub with `docker pull dataghost/comptext`

### Commands once structure and IAM account is set up

terraform refresh
terraform plan
terraform apply
// copy outputted server and certificate to corresponding sections in kubeconfig
terraform output config_map_aws_auth > config_map_aws_auth.yaml
kubectl apply -f config_map_aws_auth.yaml
kubectl create deployment comptext --image=dataghost/comptext:latest
kubectl expose deployment comptext --type=LoadBalancer --name=comptext --port=80
kubectl get svc --all-namespaces
kubectl get pods --all-namespaces
kubectl logs comptext-685c84fd7f-*****
kubectl delete deployment comptext
kubectl delete svc comptext
terraform destroy
