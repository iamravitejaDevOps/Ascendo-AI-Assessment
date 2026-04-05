# Ascendo AI - Assessment

- For remote backend we create a s3 bucket and dynamoDB table using bash
- check execute permissions

```python
bash init.sh
```

- Run these code for infra availability what i did is using root account i create a i am user with policies  then got the credentials of that user
- if you dont want to create another user remove [iam.tf](http://iam.tf) file
-  run terraform apply with these files then user created with policy , we have to create a security credentials and access as IAM user
  - provider.tf
  - backend.tf
  - iam.tf
  - variables.tf 

permission given like:

```
			"eks:*",
          "ec2:*",
          "iam:*",
          "ssm:*",
          "logs:*",
          "s3:*",
          "dynamodb:*"
```

```python
aws configure

Accesskey:
SecretAccesskey:
region:
output:
```

- clone the repo

```python
cd terraform

terraform init

terraform fmt

terraform validate

terraform plan

terraform apply 

```

- Infra is setup like
    - 1 bastion host
    - 1 eks cluster
    - 3 worker nodes
    - 1 vpc
    - public and  private subnets , IGW,Routetable,Routetable Association , Security Groups
    - 1 nat gateway
    - vpc endpoints

- Install ssm agent on local laptop

```python
# mine mac
brew install awscli
brew install amazon-ssm-agent
```

- after this run this command

```python
aws ssm start-session --target <instance-id>
```

- Run these on bastion host

- Install aws cli 

```python
sudo apt update -y

sudo apt install -y unzip curl

curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\

unzip awscliv2.zip

sudo ./aws/install
```

- Install kubectl

```python
curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\

chmod +x kubectl

sudo mv kubectl /usr/local/bin
```

- update kube config
  ```
  aws eks update-kubeconfig --region us-east-1 --name ascendo_ai_eks_cluster
  ```


- paste the k8s manifest file in bastion server

```python
kubectl apply -f <file name>

all files all configured

kubectl get pods -w

kubect get nodes -o wide 

kubectl get svc

kubectl port-forward svc/haproxy-service 8080:80

# another terminal from bastion host
curl http://<node-ip>:30081 --> to check it is working or not

o/p: <h1> tomcat working </h1>

```
- destroy
  ```
  terraform destroy
  ```
