# Google Cloud Run Deployment Guide

This guide explains how to deploy the Perlite web application to Google Cloud Run.

## Prerequisites
- Docker installed and configured
- gcloud CLI installed and authenticated
- Google Cloud project with billing enabled
- Container image built and ready

## Step 1: Verify Authentication and Project
```bash
# Check current authenticated user
gcloud auth list

# Verify current project
gcloud config list project

# Set project if needed
gcloud config set project YOUR_PROJECT_ID
```

## Step 2: Prepare Container Registry
```bash
# List existing repositories (if any)
gcloud artifacts repositories list --project=YOUR_PROJECT_ID --location=REGION

# Create artifact repository if it doesn't exist
gcloud artifacts repositories create REPO_NAME \
  --repository-format=docker \
  --location=REGION \
  --description="Repository for Perlite application"
```

## Step 3: Build and Push Container Image
```bash
# Build for Cloud Run (linux/amd64 platform)
docker buildx build \
  --platform linux/amd64 \
  -t REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest \
  --push .

# Alternative: Build locally then tag and push
docker build -t perlite-app .
docker tag perlite-app REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest
docker push REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest
```

## Step 4: Deploy to Cloud Run
```bash
# Deploy the service
gcloud run deploy perlite-service \
  --image REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest \
  --platform managed \
  --region REGION \
  --allow-unauthenticated \
  --set-env-vars GCS_BUCKET_PATH=gs://YOUR_BUCKET_NAME \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --max-instances 10 \
  --min-instances 0
```

### Deployment Options Explained
- `--allow-unauthenticated`: Makes service publicly accessible (remove for private access)
- `--set-env-vars`: Sets environment variables for the container
- `--memory`: Allocates memory (512Mi is sufficient for most use cases)
- `--cpu`: CPU allocation (1 = 1 vCPU)
- `--timeout`: Request timeout in seconds
- `--max-instances`: Maximum number of container instances
- `--min-instances`: Minimum instances (0 = scales to zero when idle)

## Step 5: Verify Deployment
```bash
# Get service details
gcloud run services describe perlite-service --region=REGION

# Get service URL
gcloud run services list --filter="metadata.name=perlite-service"
```

## Environment Variables
The application uses the following environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `GCS_BUCKET_PATH` | Google Cloud Storage bucket path | `gs://your-bucket-name` |

## Updating the Service
```bash
# Rebuild and redeploy
docker buildx build \
  --platform linux/amd64 \
  -t REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest \
  --push .

gcloud run deploy perlite-service \
  --image REGION-docker.pkg.dev/YOUR_PROJECT_ID/REPO_NAME/perlite-app:latest \
  --region REGION
```

## Configuration Placeholders
Replace the following placeholders with your actual values:

- `YOUR_PROJECT_ID`: Your Google Cloud Project ID
- `REGION`: Your preferred region (e.g., `us-central1`, `europe-west1`)
- `REPO_NAME`: Your Artifact Registry repository name
- `YOUR_BUCKET_NAME`: Your Google Cloud Storage bucket name

## Security Considerations
- Use `--no-allow-unauthenticated` for private applications
- Set up IAM policies for access control
- Use service accounts with minimal required permissions
- Monitor access logs and set up alerts

## Cost Optimization
- Set `--min-instances 0` to scale to zero when idle
- Use appropriate memory and CPU allocations
- Monitor usage and adjust limits as needed
- Set up budget alerts

## Troubleshooting
- Check deployment logs: `gcloud run services logs read perlite-service --region=REGION`
- Verify image exists in Artifact Registry
- Ensure proper IAM permissions
- Check environment variable configuration

## Related Files
- [Bucket Sync Setup](BucketSync.md)
- [Authentication Guide](TestingandAuth.md)
- [Cost Analysis](cloudcost.md)

