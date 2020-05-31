# Adevinta AWS Infrastructure with Terraform and Packer

## Prerequisites
### Install Terraform

Download Terraform package and add the binary to the PATH 
https://www.terraform.io/downloads.html

### Install Packer
Download Packer package and add the binary to the PATH 
https://www.packer.io/intro/getting-started/

## Structure 

This is the Adevinta Stack estructure
```
|- packer
    |- jar  --> Helloworld app
    |- systemd --> Systemd script for helloworld app
    |- awslogs --> Configuration for awslogs
    |- app.json --> Packer's builder file
    |- install.sh 
|- terraform
    |- adevinta
        |- iam-policies --> Iam policies
        |- vars/adevinta.tfvars --> Adevinta variables values
        |- outputs.tf --> Terraform stack outputs
        |- remoteTfstate.ft --> Remote tf state file
        |- stack.tf  --> Terraform stack file
        |- variables.tf --> Terraform variables definition
        |- workspace.tf -->Terraform workspace file       
    |- modules
       |- bastion
       |- igw
       |- nat
       |- private_subnet
       |- public_subnet
       |- rds
       |- vpc
       |- webserver
|- adevinta-deploy.py --> App cli to manage all the stack      

```

### Configure remote tfstate 
1.- Create a S3 bucket to store our remote tfstate.
2.- Create and IAM User and assign the following IAM policy

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}
```

3.- Create the following ENV variables with the IAM User credentials or create and profile in $HOME/.aws/credentials

```
export AWS_ACCESS_KEY_ID ="XXXXXXX"
export AWS_SECRET_ACCESS_KEY ="YYYYY"
```
4.-  Create Terraform remote state variables
```
export TF_VAR_region=eu-west-1
export TF_VAR_tf_bucket="adevinta-tf
```
### Initialize environment

1.-  Specifiy the workspace. In this case pro
```
export TF_WORKSPACE=pro
```
2.-  Create the postgres password in AWS Secret Manager and set the variable  bbdd_secretsmanager_arn in the workspace.tf

3.- Create a key for EC2 instance with the name pro-adevinta

4.- Create your first Adevinta AMI using the app cli and set the variable  webserver_instance_ami in the workspace.tf

### Running the stack

* Create AMI with Packer 
  
```
python adevinta-deploy.py  -a packer 
```
* Create a Terraform plan the our stack with extra args

```
python adevinta-deploy.py  -a terraform -c plan -e -var=bastion_instance_ami="ami-0ea3405d2d2522162"
```
* Create a Terraform plan of a resource 
```
python adevinta-deploy.py  -a terraform -c plan  -target module.vpc

```
* Plan and apply Terraform 

```
python adevinta-deploy.py  -a terraform -c apply -e -var=bastion_instance_ami="ami-0ea3405d2d2522162"
```
* Blue/Green Deployment. Plan the green stack. This include AMI creation. 

```
python adevinta-deploy.py  -a green_deploy -c plan
```
* Blue/Green Deployment. Deploy green stack. 

```
python adevinta-deploy.py  -a green_deploy -c apply

```
 * Destroy the stack

```
python adevinta-deploy.py  -a terraform -c destroy

```


*  App cli help

```
python adevinta-deploy.py  -h
```