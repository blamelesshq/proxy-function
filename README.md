# Lambda function for Prometheus

AWS and GCP integration for fetch data from Prometheus

### Clouds
This repo contains a common function for AWS and GCP. We have some differences between AWS and GCP:
1. AWS uses binary for deploy;
2. GCP uses source code for deploy;
3. GCP uses a package. The package name must not be `main`;
4. GCP uses go.mod or vendor (go modules).


### Terrafrom
This repo contains two terraform script for AWS and GCP.

#### AWS resources:
1. Lambda;
2. API getaway;
3. KMS keys.

#### GCP resources:
1. Google Run;
2. Google Endpoints;
3. Google Function;
4. Google Bucket.

### Deploy:
1. Set env variables in `.env` file;
2. Run `source .env` to set environment; 
3. Run `make` to build a docker container;
4. Run `make deploy` for deploy to a cloud and choose cloud `AWS` or `GCP`;
5. Next: [Instruction for GCP](#GCP) \ [Instruction for AWS](#AWS).

#### GCP:
1. Set the major version;
2. Set the minor version (update each deploy to avoid deployment errors);
3. Set project name;
4. Set region deployment.

#### AWS:
1. Set API name. It will use as part of a path URL;
2. Set region for deployment.
