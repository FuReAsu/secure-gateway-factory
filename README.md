# Secure Gateway Factory (Multicloud provisioning with GitLab)

Create cloud gateway servers from anywhere (with pipelines), even from your phone. Made to automate the process of provisioning cloud instances and hosting secure gateway servers but this project is mainly intended for terraform and gitlab CI POC.

## Components

- OpenTofu
- Gitlab CI Pipeline
- Scripts to install secure gateway services and generate keys
- Telegram BOT API calls to notify environment changes and key delivery.

## Container Images

Custom container images are used for the pipeline jobs.

|Image Name|Dockerhub|Source|
|---|---|---|
|fureasu346/opentofu:v1.11.5|[link](https://hub.docker.com/repository/docker/fureasu346/opentofu/tags/v1.11.5)|[repo link](https://github.com/FuReAsu/docker/tree/main/opentofu)|
|fureasu346/pipeline-util:v1|[link](https://hub.docker.com/repository/docker/fureasu346/pipeline-util/tags/v1)|[repo link](https://github.com/FuReAsu/docker/tree/main/pipeline-util)|


## Pipeline Flow

- Provision cloud compute instances
- Install secure gateway Servers 
- Generate keys for secure gateway servers
- Tear down cloud compute instances

Gitlab CI's Input variables are utilized to provide drop down list of options to select for `cloud-provider`, `region`, `instance-type` choices. Pipeline jobs are generated according to the cloud-provider input while the other variables can be modified at runtime through job variables.

## Implemented Cloud Providers

- AWS
- GCP
- DigitalOcean

## SSH Key

The ssh public key in the project is created as ssh key resource in cloud providers to provide access to the pipeline and the administrator. The matching ssh secret key is stored in CI/CD variables.

> [!IMPORTANT]
> You should generate your own ssh key pair and replace the public key as the current key in the project is unusable since there is no private counterpart available in the repo. (I am using it and I have it on local).

## Secrets

Secrets has to be stored in CI/CD variables for the pipelines to run.
Below are the required variables

|Name|Description|Purpose|
|---|---|---|
|AWS_ACCESS_KEY|AWS access key|For AWS provider auth|
|AWS_SECRET_KEY|AWS secret key|For AWS provider auth|
|CI_PAT|Gitlab Personal Access Token|For Gitlab tfstate backend|
|CI_USER|Gitlab username for PAT|For Gitlab tfstate backend|
|DO_TOKEN|Digital Ocean access token|For DigitalOcean provider auth|
|GCP_CREDENTIALS[<sup>1</sup>](#gcp-note)|Google cloud service account key|For GCP provider auth|
|SSH_PRIV_KEY|The private key pair to the public key in your repo|For SSH access to provisioned instances|
|TELEGRAM_BOT_TOKEN|Telegram bot API access token|For gateway Access Key delivery messages|
|TELEGRAM_CHAT_ID|Telegram bot API chat ID|For gateway Access Key delivery messages|

</br>
<a id="gcp-note"></a>
**[1]** Using service account keys is not recommended for GCP. I have used to simplest method to authenticate to GCP which is with service account keys.</br>

Generating service account keys is disabled by default on GCP projects and you need to perform the following actions to do that.</br>

First, you need to have an account that has `roles/orgpolicy.policyAdmin`. If you are the owner, just grant your account that role. After that, you can run this gcloud command to enable service account key generation:

```bash
gcloud resource-manager org-policies disable-enforce \
    iam.disableServiceAccountKeyCreation --organization=<YOUR_ORG_ID>
```
