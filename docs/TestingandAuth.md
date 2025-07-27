# Authentication and Testing Guide

This guide explains how to access and test your private Perlite application deployed on Google Cloud Run.

## Understanding Cloud Run Authentication

### Why You Get 403 Forbidden Errors

When you set a Cloud Run service to "require authentication" (private), simply **being signed in to your Google account in your browser is not enough**. Cloud Run's authentication works at the API level, expecting each HTTP request to include a special authentication token (ID token) in the `Authorization: Bearer <token>` header.

**Typing the service URL directly into your browser does NOT include this token**, even if you're signed in to Google. That's why you get 403 Forbidden errors despite having the correct permissions.

## Authentication Solutions

### 1. Cloud Run Proxy (Recommended for Browser Testing)

Google provides a simple way to proxy your private Cloud Run service to your local machine, automatically handling authentication:

```bash
# Replace with your actual service name and project ID
gcloud run services proxy SERVICE_NAME --project=YOUR_PROJECT_ID --region=REGION
```

**What this does:**
1. Creates a local proxy at `http://localhost:8080`
2. Automatically includes the proper authentication token
3. Forwards all requests to your Cloud Run service
4. Handles authentication transparently

**Usage:**
1. Run the proxy command in your terminal
2. Open `http://localhost:8080` in your browser
3. Interact with your service as an authenticated user

### 2. Command Line Access with Authentication

For API testing or programmatic access:

```bash
# Make authenticated requests using curl
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://YOUR_SERVICE_URL/

# Test specific endpoints
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://YOUR_SERVICE_URL/api/endpoint
```

### 3. Make Service Public (Not Recommended)

To allow unauthenticated access (public):

```bash
# Deploy with public access
gcloud run deploy perlite-service \
  --image YOUR_IMAGE \
  --region REGION \
  --allow-unauthenticated

# Or update existing service
gcloud run services add-iam-policy-binding perlite-service \
  --region=REGION \
  --member="allUsers" \
  --role="roles/run.invoker"
```

> [!WARNING] Security Risk
> Public access means anyone on the internet can access your Obsidian vault. Only use this for non-sensitive content.

## Authentication Methods Comparison

| Method | Security | Ease of Use | Best For |
|--------|----------|-------------|----------|
| Private + Proxy | High | Easy | Personal use, development |
| Private + IAM | High | Moderate | Shared access, teams |
| Public | Low | Very Easy | Public documentation |

## Setting Up User Access

### Grant Access to Specific Users

```bash
# Grant Cloud Run Invoker role to a specific user
gcloud run services add-iam-policy-binding perlite-service \
  --region=REGION \
  --member="user:friend@example.com" \
  --role="roles/run.invoker"

# Grant access to a Google Group
gcloud run services add-iam-policy-binding perlite-service \
  --region=REGION \
  --member="group:team@yourdomain.com" \
  --role="roles/run.invoker"

# Grant access to a service account
gcloud run services add-iam-policy-binding perlite-service \
  --region=REGION \
  --member="serviceAccount:app@project.iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

### Remove User Access

```bash
# Remove user access
gcloud run services remove-iam-policy-binding perlite-service \
  --region=REGION \
  --member="user:friend@example.com" \
  --role="roles/run.invoker"
```

## Testing Checklist

### 1. Deployment Verification
- [ ] Service deploys successfully
- [ ] Container starts without errors
- [ ] Environment variables are set correctly
- [ ] GCS bucket sync works

### 2. Authentication Testing
- [ ] Private service blocks unauthenticated requests
- [ ] Proxy access works for authorized users
- [ ] API calls with tokens succeed
- [ ] Unauthorized users get 403 errors

### 3. Functionality Testing
- [ ] Obsidian notes render correctly
- [ ] Images and attachments load
- [ ] Search functionality works
- [ ] Navigation between notes works
- [ ] Mobile responsiveness

### 4. Performance Testing
- [ ] Cold start time is acceptable
- [ ] Page load times are reasonable
- [ ] Memory usage stays within limits
- [ ] Auto-scaling works properly

## Debugging Authentication Issues

### Common Problems and Solutions

**Problem**: "Error 403: Forbidden"
```bash
# Solution: Use proxy or check IAM permissions
gcloud run services get-iam-policy perlite-service --region=REGION
```

**Problem**: "Service not found"
```bash
# Solution: Verify service name and region
gcloud run services list
```

**Problem**: "Permission denied"
```bash
# Solution: Check if you have the Cloud Run Invoker role
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:YOUR_EMAIL"
```

## Advanced Authentication Setup

### Using Identity-Aware Proxy (IAP)

For more sophisticated authentication:

```bash
# Enable IAP for additional security layers
gcloud compute backend-services update-backend \
  --backend-group=BACKEND_GROUP \
  --backend-group-zone=ZONE \
  --global \
  BACKEND_SERVICE_NAME
```

### Custom Authentication

For custom authentication needs, modify the application to:
1. Check custom headers or cookies
2. Integrate with external auth providers
3. Implement role-based access control

## Security Best Practices

1. **Principle of Least Privilege**: Grant minimal necessary permissions
2. **Regular Access Review**: Periodically audit who has access
3. **Monitoring**: Set up alerts for unusual access patterns
4. **Backup Authentication**: Have multiple ways to access your service
5. **Documentation**: Keep a record of who has access and why

## Monitoring and Logging

```bash
# View service logs
gcloud run services logs read perlite-service --region=REGION

# Monitor request patterns
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=perlite-service"

# Set up alerts for authentication failures
gcloud alpha monitoring policies create --policy-from-file=auth-alert-policy.yaml
```

## Related Files
- [Cloud Run Deployment](DeploycloudRun.md)
- [Bucket Sync Setup](BucketSync.md)
- [Cost Analysis](cloudcost.md)