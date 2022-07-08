# Blameless proxy function 

The **Blameless proxy function** provides a secure connection between **Blameless SLO Manager** to monitoring systems (e.g. Prometheus) deployed in private networks (behind a firewall) such as a private cloud or on-premise via a public cloud provider such as AWS, GCP or Azure. Credentials to access your monitoring systems are not exposed to Blameless as they remain securely stored and access by the Blameless proxy function from within your own private cloud infrastructure.

This project provides a Terraform based deployment package to deploy the cloud infrastructure necessary to securely run your Blameless proxy functions at scale in either AWS, GCP or Azure.

## Project status

The Blameless proxy function and its supporting cloud infrastructure (see cloud resources types in the secure cloud infrastructure section below) can be deployed in the following public cloud providers using your own private cloud account:

| Cloud Provider | Status               |
| -------------- | -------------------- |
| AWS            | Experimental         |
| Azure          | Experimental         |
| GCP            | Early access (alpha) |

The Blameless proxy function based on the Go language provides integration with the following monitoring systems:

| Monitoring System | Status                                                             |
| ----------------- | ------------------------------------------------------------------ |
| Prometheus        | Early access (alpha)                                               |
| Splunk            | Early access (alpha)                                               |
| Other             | Please contact Blameless or become a [contributor](#contributors). |

## Secure Cloud infrastructure

Whether you decide to deploy the Blameless proxy function in AWS, GCP or Azure, the following cloud infrastructure is recommended to securely connect your **Blameless SLO Manager** to your monitoring systems:

| Managed Service       | Description                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Function as a Service | Hosts the **Blameless proxy function** (e.g. AWS Lambda, Google Function, Azure Function App)                                         |
| Key Management        | Securely holds the credentials (AWS KMS, etc.) allowing a Blameless proxy function to connect to its target metric server.            |
| API Gateway           | Routes HTTP traffic from your Blameless account to the appropriate proxy function, when connecting to more than one monitoring system |
| NAT Gateway           | [*optional*] Provides a single outbound IP address (behind a a NAT gateway), to simplify any firewal rules (whitelist )               |

> Note: After deploying this cloud infrastructure to your own private Cloud account along with the Blameless proxy function, you and your organization are responsible for providing a network route within your private network between the proxy functions and your monitoring/metric systems/servers.

## Deployment guides

Go to the deployment guide corresponding to the public cloud provider where you plan to deploy the Blameless proxy function:

| Cloud Provider | Guide                                                                    |
| -------------- | ------------------------------------------------------------------------ |
| AWS            | [Deploying the Blameless proxy function to AWS](./docs/AWS-GUIDE.md)     |
| Azure          | [Deploying the Blameless proxy function to Azure](./docs/AZURE-GUIDE.md) |
| GCP            | [Deploying the Blameless proxy function to GCP](./src/gcp/README.md)     |

## How to contribute

Please check the [How To Contributate](./docs/HOW-TO-CONTRIBUTE.md) document and contact Contributors if you have any additional questions.

## Contributors

Contact Blameless (info@blameless.com) if you would like to contribute to this code, including supporting new Cloud providers or new monitoring systems.