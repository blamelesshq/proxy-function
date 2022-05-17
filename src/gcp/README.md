# Proxy Function - Google Cloud

## Prerequisites

To deploy the proxy function to Google Cloud (GCP), you will need to install the following tools:
- [Go](https://go.dev/doc/install) >v1.16
- [Terraform](https://www.terraform.io/downloads)

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

| Variable             | Description                                |
|----------------------|--------------------------------------------|
| access_token         | Token to access the proxy function         |
| data_source_type     | Data source type. ('prometheus', 'splunk') |
| data_source_url      | URL to data source                         |
| data_source_username | Username for data source                   | 
| data_source_password | Password for data source                   |
| project              | Google Cloud project id                    |
| region               | Google Cloud region                        |
| api_major_version    | Major version for Google Cloud API Gateway |
| api_minor_version    | Minor version for Google Cloud API Gateway |

## Rolling Back

To undo the changes, run the following command:

```bash
make destroy-gcp
```