# Blameless Proxy function - Deployment Guide for AWS

Deployment Guide for the Blameless Proxy function in AWS

| Project          | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| Status           | Experimental                                                 |
| Content          | This project provides a Terraform script with 2 Terraform modules to configure and deploy the required cloud infrastructure in AWS and the Blameless proxy function. |
| Deployment steps | 1. Deploy all necessary AWS resources in one single Terraform command.


## PREREQUISITES

To deploy the Blameless proxy function in AWS, you need the following prerequisites:

1. An **AWS account** with the appropriate permissions to deploy the required AWS resources (see list of [AWS resources types](#deploy-the-infrastructure-to-aws) mentioned further below).
2. **Blameless account** (instance) with at least a **Blameless user account**, to connect Blameless to your Blameless proxy functions deployed in your AWS account.



## REQUIRED TOOLS

The following table describes the list of tools you need to install on your local machine to be able to deploy the cloud infrastructure in AWS needed to operate your Blameless proxy functions. 

| Tool               | Tested versions                    | Version checking        |
| ------------------ | ---------------------------------- | ----------------------- |
| AWS CLI            | 1.18.69                            | `$ aws --version`       |
| Make               | 4.2.1                              | `$ make --version`      |
| Terraform CLI      | v1.1.14                            | `$ terraform --version` |
| Git                | git version 2.25.1                 | `$ git --version`       |
| Visual Studio Code | Latest                             |                         |



### AWS CLI

Make sure you properly configure your AWS Account. For more info visit this official [AWS Doc](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

```shell
$ aws configure
```

### Terraform
Download Terraform CLI binary from here: https://www.terraform.io/downloads.html 

Move the Terraform binary to a path defined in your environment variable PATH

```shell
$ mv ~/Downloads/terraform /usr/local/bin

$ which terraform
/usr/local/bin/terraform
```



## INSTALLATION

### Clone this repository

```shell
$ git clone https://github.com/blamelesshq/proxy-function.git
```

> Note: The repository is still private and will require you to provide a Github user name to provide you access to it.

### Deploy the infrastructure to AWS

The provided Terraform modules allows you to install the following Cloud infrastructure resources in AWS to securely run your Blameless Proxy functions:

| #    | AWS Resource Type   | Description                                                  |
| ---- | ------------------- | ------------------------------------------------------------ |
| 1    | Lambda Function      | Host the the Blameless proxy function             |
| 2    | API Gateway          | Routes HTTP traffic from your Blameless account to the appropriate AWS lambda Function                        |



#### Deployment configuration

There 3 key Terraform files at the root of the directory [./deploy/aws2](https://github.com/blamelesshq/proxy-function/tree/master/deploy):

| File             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| main.tf          | All 2 Terraform modules are all connected from the main.tf Terraform script which defines all the resources to be created in AWS. |
| variables.tf     | All variables for the main terraform script                  |
| Terraform.tfvars | Actual values for the variables (specific to each deployment) |



#### Customize your configuration file (terraform.tfvars)

> Note: The main Terraform script deploys only one instance of each AWS resource type (alpha 1.0)

Go to the following **Terraform configuration file** and modify ALL values:

[./deploy/aws2/terraform.tfvars](https://github.com/blamelesshq/proxy-function/blob/master/deploy/aws2/terraform.tfvars)

**IMPORTANT NOTE**

1. Before you deploy, you MUST set ALL values defined in the Terraform configuration file to match with your specific deployment scenario (AWS region, lambda name, etc.).
2. Make sure to modify all values before you deploy. The default values provided in the original Terraform file are just examples.
3. Some of the names must be unique, and some are globally unique (see note 1)
4. If you don’t provide unique values, Terraform will report an error and you should modify the name again in the Terraform configuration file and try the deployment again.



**Description of all the variables contained in the configuration file:**

| *Variable*                       | *Description*                                                |
| -------------------------------- | ------------------------------------------------------------ |
| **Lambda Function**       | -                                                            |
| name              | Unique resource name                                         |
| runtime                         | AWS Lambda code runtimes. See official [AWS Doc](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) for more details |
| memory                         | AWS Lambda total memory. Default is 128 MB |
| timeout                         | AWS Lambda timeout in seconds |
| package                         | Relative or absolute path of the lambda package zip file |
| handler                         | AWS Lambda Handler name |
| env                         | AWS Lambda - list of environment variables|
| tags                         | AWS Lambda tag. This is optional object |
| security_group_ids                         | Lambda security group ids. OPTIONAL! |
| subnet_ids                         | Lambda subnet ids. OPTIONAL! |
| **API Gateway**                    | -                                                            |
| name                         | API Gateway unique name |
| stage                        | API Gateway stage name |
| binary_type                  | Api Gateway supported media types |
| minimum_compression_size     | Compresion size |
| method     | HTTP method. In Proxy Function only ANY, OPTIONS are used |
| lambda_arn     | ARN of the Lambda Function |
| lambda_arn_invoke     | Lambda Function invoke URI |


### Deploy your AWS resources and BlamelessProxyFunction using Terraform

Go to the root of the Proxy Function directory:

```shell
$ cd ./ProxyFunction
```
Create build of the Proxy Function and prepare env variables
```make build```
```make zip-aws```
```make prepare-config-aws-linux```

Then go to the root of the Terraform configuration files:
```cd ./deploy/aws2```

Initialize your working directory containing your Terraform configuration files

```shell
$ terraform init
```

Create your execution plan

```shell
$ terraform plan -out tfplan
```

Deploy your AWS resources per the execution plan

```shell
$ terraform apply --var-file="terraform.tfvars" -auto-approve
```

Remove ALL resources from AWS (optional)

```shell
$ terraform destroy -auto-approve
```


== END OF DOCUMENT ==


