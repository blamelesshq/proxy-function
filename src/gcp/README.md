# Proxy Function - Google Cloud

## Prerequisites

### Software

To deploy the proxy function to Google Cloud (GCP), you will need to install the following tools:
- [Go](https://go.dev/doc/install) v1.16
- [Terraform](https://www.terraform.io/downloads)

### Google Could APIs

To properly deploy the proxy function the following APIs need to be enabled:
- Cloud Resource Manager API
- IAM Service Account Credentials API
- Identity and Access Management (IAM) API

### Google Cloud Service Account

To deploy the necessary resources, the deployment needs to happen from a service account. The service account will need the following permissions:
- Editor (or specific permissions to deploy the [resources](#resources) listed below)
- Service Account Token Creator

## Setup

The first time this repository is used, you will need to set up your Google Cloud deployment by running:

```bash
make setup-gcp
```

## Deploying

To deploy the function run the following command in the root directory of this repository:

```bash
make gcp
```

This will prepare the function and then ask for some information:

| Variable                    | Description                                                   |
|-----------------------------|---------------------------------------------------------------|
| data_source_type            | Data source type. ('prometheus', 'splunk')                    |
| data_source_url             | URL to data source                                            |
| data_source_username        | Username for data source                                      | 
| data_source_password        | Password for data source                                      |
| project                     | Google Cloud project id                                       |
| region                      | Google Cloud region                                           |
| api_major_version           | Major version for Google Cloud API Gateway                    |
| api_minor_version           | Minor version for Google Cloud API Gateway                    |
| service_account_credentials | Path to JSON credentials file for Terrraform Service Acccount |


### Google Cloud Information

Once the `make gcp` command has run, the Terraform provider will output the URL to the API Gateway as well as the API key needed to access the gateway.

### Blameless Setup

In Blameless, navigate to Settings. Next navigate to "Metrics" under the "Integrations" section. Select the appropriate data source and the appropriate cloud provider and enter the API Gateway URL into the "URL" field and the API Key into the "Token" field.

## Rolling Back

To undo the changes, run the following command:

```bash
make destroy-gcp
```

## Deployment Details

### Resources

- Storage Bucket
  - The code is archived into a `.zip` file and deployed to this storage bucket
- Storage Bucket Archive
  - Places the archived code into the storage bucket
- Google Service Account
  - Service Account to access function
- Google Cloud Function IAM Member
  - Assigns Service Account permissions to access funtion
- Google Cloud Function
  - Executes the deployed code
- Google API Gateway
  - Provides authentication
  - Uses the Service Account to access the function