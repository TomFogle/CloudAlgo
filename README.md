# CloudAlgo


`_________ .__                   .___    _____  .__                  `<br />
`\_   ___ \|  |   ____  __ __  __| _/   /  _  \ |  |    ____   ____  `<br />
`/    \  \/|  |  /  _ \|  |  \/ __ |   /  /_\  \|  |   / ___\ /  _ \ `<br />
`\     \___|  |_(  <_> )  |  / /_/ |  /    |    \  |__/ /_/  >  <_> )`<br />
` \______  /____/\____/|____/\____ |  \____|__  /____/\___  / \____/ `<br />
`        \/                       \/          \/     /_____/         `<br />

### Overview
Autoscaling API service to plug and play texts and text comparison methods.

### Breakdown
The API portion of this project is the start of a platform where users can select from a number of similarity comparison methods to compare two texts. Will add an additional endpoint to accept requests from other APIs to compare batches of their own text.

The infrastructure is based in AWS EKS, with an autoscaling cluster that deploys my dockerized API and is provisioned in Terraform. App can be substituted with a different image.

API can be pulled from dockerhub with `docker pull dataghost/comptext`

### Note before running commands

You must have an IAM account to use. If your workstation's default IAM is the one you want to use, the generated outputs will automatically use your IAM. Otherwise you will have to change the IAM in ~/.kube/config to the one you want.<br />
You need to install kubectl in order to execute commands and check on your cluster.<br />
You need to have Docker installed in order to do any real work with the apps you will be deploying. If your API is not on Docker, you will have to specify where the location of your image/web app.<br />
You can replace the image I pulled for your own, as long as it is wrapped in nginx or some WSGI to serve up your app.

### Commands once structure and IAM account is set up

<br />

1) -- start up cluster --
```bash
terraform refresh
terraform plan
terraform apply
```

<br />

2) -- copy outputted server and certificate to corresponding sections in kubeconfig --
```bash
echo {copy pasted certificate here} >> {your kubeconfig directory}
```

Note that you may need to use `sudo`

<br />

3) -- apply cluster config --
```bash
terraform output config_map_aws_auth > config_map_aws_auth.yaml
kubectl apply -f config_map_aws_auth.yaml
```

<br />

4) -- deploy your app -> choose a different image name here if you wish to deploy a different app --
```bash
kubectl create deployment comptext --image=dataghost/comptext:latest
kubectl expose deployment comptext --type=LoadBalancer --name=comptext --port=80
```

<br />

5) -- check on deployment --
```bash
kubectl get svc --all-namespaces
kubectl get pods --all-namespaces
kubectl logs comptext-685c84fd7f-*****
```

<br />

6) -- delete deployment and bring down cluster --
```bash
kubectl delete deployment comptext
kubectl delete svc comptext
terraform destroy
```
<br /><br />
Bringing the cluster up and down can take around 15 minutes, even with just a few nodes. If it takes longer than 25 minutes to do destroy for less than a dozen nodes, log into your AWS console and make sure it's not stuck in a loop of dependencies. This odd case happened to me when I closed my laptop one time before the destroy completed and AWS skipped a beat and didn't bring down a part of my cluster that needed to be brought down before the rest.
<br /><br />
This should be extremely rare, but it's nonetheless worthwhile to note that sometimes checking ont he cluster from the command line isn't enough.

<br /><br />
For presentation slides, you can click below.<br />
https://docs.google.com/presentation/d/1UYUlEUb0akfNeBoU_Gbyl-aABCaBPyaN5_FYBClNVUk/edit?usp=sharing
