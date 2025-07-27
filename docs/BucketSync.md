# Google Cloud Storage Bucket Sync Setup

## Overview
This document explains how to set up Google Cloud Storage for syncing your Obsidian vault with the Perlite web application running on Google Cloud Run.

## Architecture Flow
> [!INFO] Sync Flow
> GitHub Repo → GitHub Actions → Google Cloud Storage → Google Cloud Run (Perlite)
> 
> This approach is chosen because:
> - GCP Cloud Run doesn't support persistent volumes
> - Direct git repo access between containers isn't possible
> - Google Cloud Storage provides cost-effective solution
> - Cloud Run charges only per request (zero-cost when idle)

## Prerequisites
- Google Cloud Platform account
- gcloud CLI installed and configured
- GitHub repository for your Obsidian vault

## Step 1: Install and Configure gcloud CLI
```bash
# Install gcloud CLI (example for macOS)
# Download from: https://cloud.google.com/sdk/docs/install

# Authenticate with your Google account
gcloud auth list
```

## Step 2: Create Google Cloud Storage Bucket
```bash
# Set your project (replace with your project ID)
export PROJECT_ID="your-project-id"
export BUCKET_NAME="your-obsidian-vault-bucket"

# Create bucket with default settings
gsutil mb gs://$BUCKET_NAME
```

## Step 3: Create Service Account and Permissions
```bash
# Create custom role with minimal required permissions
gcloud iam roles create obsidianVaultSync \
  --project=$PROJECT_ID \
  --title="Obsidian Vault Sync" \
  --description="Minimal permissions for vault sync" \
  --permissions="storage.objects.create,storage.objects.delete,storage.objects.get,storage.objects.list"
```

### Create Service Account
```bash
# Create service account
gcloud iam service-accounts create vault-sync \
  --display-name="Vault Sync Service Account" \
  --description="Service account for syncing Obsidian vault to GCS"

# Bind custom role to service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:vault-sync@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="projects/$PROJECT_ID/roles/obsidianVaultSync"
```

### List Service Accounts (Verification)
```bash
gcloud iam service-accounts list
```

## Step 4: Enable Required APIs
```bash
# Enable necessary Google Cloud services
gcloud services enable storage.googleapis.com
gcloud services enable iamcredentials.googleapis.com
```

## Step 5: Create Service Account Key
```bash
# Generate JSON key for service account
gcloud iam service-accounts keys create vault-sync-key.json \
  --iam-account=vault-sync@$PROJECT_ID.iam.gserviceaccount.com
```

> [!WARNING] Security Note
> The `vault-sync-key.json` file contains sensitive credentials. 
> - Never commit this file to version control
> - Store it securely as a GitHub secret
> - Use environment variables in production

## Step 6: GitHub Secrets Setup
Add the following secrets to your GitHub repository:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `your-project-id` |
| `GCP_SA_KEY` | Contents of vault-sync-key.json | `{"type": "service_account"...}` |
| `GCS_BUCKET` | Your bucket name | `your-obsidian-vault-bucket` |

## Step 7: Workflow Implementation
The GitHub Actions workflow automatically syncs your vault to Google Cloud Storage when you push changes. See the `.github/workflows/sync-to-gcs.yml` file for implementation details.

## Verification
After setup, you can verify the sync by checking:
1. GitHub Actions workflow runs successfully
2. Files appear in your GCS bucket
3. Perlite application loads content from the bucket

## Cost Optimization
- Cloud Storage: Pay for storage used (~$0.02/GB/month)
- Cloud Run: Pay only for requests (free tier: 2M requests/month)
- Zero cost when your site is not accessed

## Troubleshooting
- Ensure service account has correct permissions
- Verify bucket name matches across all configurations
- Check GitHub secrets are properly set
- Monitor GitHub Actions logs for sync errors

## Related Files
- [Cloud Run Deployment](DeploycloudRun.md)
- [Authentication Setup](TestingandAuth.md)
- [Cost Analysis](cloudcost.md)
