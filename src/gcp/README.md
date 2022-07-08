# Proxy Function - Google Cloud

## Prerequisites

### Software

To deploy the proxy function to Google Cloud (GCP), you will need to install the following tools:
- [Go](https://go.dev/doc/install) v1.16
- [Terraform](https://www.terraform.io/downloads)

### Google Could APIs

To properly deploy the proxy function the following APIs need to be enabled:
- API Gateway API
- Cloud Build API
- Cloud Functions API
- Cloud Resource Manager API
- IAM Service Account Credentials API
- Identity and Access Management (IAM) API
- Service Control API
- Service Management API
- Service Usage API

### Google Cloud Service Account

To deploy the necessary resources, the deployment needs to happen from a service account. The service account will need the following permissions:
- Editor (or specific permissions to deploy the [resources](#resources) listed below)
- Service Account Token Creator
- Cloud Functions Admin

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

| Variable                    | Description                                                                                                    |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| project_id                  | Google Cloud project id                                                                                        |
| region                      | Google Cloud region                                                                                            |
| proxy_bucket_name           | Bucket to create and host proxy function                                                                       |
| proxy_bucket_location       | Location to create and host proxy function bucket                                                              |
| proxy_function_name         | Globally unique user-defined name of the function                                                              |
| proxy_service_account       | Service account name for proxy service                                                                         |
| data_source_url             | URL to data source                                                                                             |
| data_source_username        | Username for data source                                                                                       | 
| data_source_password        | Password for data source                                                                                       |
| data_source_type            | Data source type. ('prometheus', 'splunk')                                                                     |
| vpc_connector               | The VPC Network Connector that this cloud function can connect to. It should be set up as fully-qualified URI. |

### Google Cloud Information

Once the `make gcp` command has run, the Terraform provider will output the URL to the API Gateway. The next step is to generate an API key for the API Gateway.
- Go to the Google Cloud Console
- Navigate to the "APIs & Services" area
- Click on "Credentials"
- Click on "+ Create Credentials"
- Select "API key"
- Copy the API key value

Optional, but recommended:
- Edit the API key
  - Update the name
  - Restrict the API key

### Blameless Setup

In Blameless, navigate to Settings. Next navigate to "Metrics" under the "Integrations" section. Select the appropriate data source.  Enable the data source and select "GCP Function" from the "Mode" dropdown. Enter the API Gateway URL into the "URL" field and the API Key into the "Token" field.

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
- Google Cloud Function
  - Executes the deployed code
- Google Service Account
  - Service Account to access function
- Google Cloud Function IAM Member
  - Assigns Service Account permissions to access funtion
- Google API Gateway
  - Provides authentication
  - Uses the Service Account to access the function