# VPN Factory

Create vpn servers from anywhere (with pipelines)

## Components

- OpenTofu
- Gitlab CI Pipeline
- Scripts to install vpn servers and generate keys

## Flow

- Provision cloud compute instances
- Install VPN Servers 
- Generate keys for VPN servers
- Tear down cloud compute instances

Gitlab CI's Input variables are utilized to provide drop down list of options to select for `cloud-provider`, `region`, `instance-type` choices. Pipeline jobs are generated according to the cloud-provider input while the other variables can be modified at runtime through job variables.

## Implemented VPN Servers

- OpenVPN
- Outline

## Implemented Cloud Providers

- AWS
- GCP
- DigitalOcean

## SSH Key

The ssh public key in the project is created as ssh key resource in cloud providers to provide access to the pipeline and the administrator. The matching ssh secret key is stored in CI/CD variables.

> [!NOTE]
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
|TELEGRAM_BOT_TOKEN|Telegram bot API access token|For VPN Key delivery messages|
|TELEGRAM_CHAT_ID|Telegram bot API chat ID|For VPN Key delivery messages|

<a id="gcp-note"></a>
**[1]** Using service account keys is not recommended for GCP. Since I haven't learned how to use oauth or roles for tofu, I just used the easiest way for authentication. Generating service account keys is disabled by default on GCP projects and you need to perform the following actions to do that.</br>
First, you need to have an account that has `roles/orgpolicy.policyAdmin`. If you are the owner, just grant your account that role. After that, you can run this gcloud command to enable service account key generation:
```bash
gcloud resource-manager org-policies disable-enforce \
    iam.disableServiceAccountKeyCreation --organization=<YOUR_ORG_ID>
```

