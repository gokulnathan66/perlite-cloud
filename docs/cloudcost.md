# Cloud Cost Analysis and Optimization

## Overview
This document analyzes the cost structure for hosting Perlite on Google Cloud Platform and provides optimization strategies for personal use.

## Why Google Cloud Platform?
- **Cost-effective**: Free tier with generous limits
- **Serverless**: No infrastructure management required
- **Auto-scaling**: Scales to zero when not in use
- **Global reach**: Deploy to multiple regions

## Architecture Decision: Cloud Run vs Alternatives

### Why Cloud Run?
✅ **Pay-per-request pricing** - Only charged when someone visits your site  
✅ **Auto-scaling** - Scales from 0 to N instances automatically  
✅ **Managed infrastructure** - No server maintenance  
✅ **Container support** - Easy deployment with Docker  

### Alternative Considered: Compute Engine/VM
❌ **Always-on costs** - Charged 24/7 even when unused  
❌ **Infrastructure management** - OS updates, security patches  
❌ **Higher complexity** - Manual scaling and load balancing  

### Architecture Challenge
> [!INFO] Volume Limitation
> GCP Cloud Run doesn't support persistent volumes, which led to our solution:
> - **Problem**: Direct git repo access between containers isn't possible
> - **Solution**: GitHub → Cloud Storage → Cloud Run workflow
> - **Benefit**: Automated sync + cost optimization

## Cost Breakdown

### Google Cloud Storage
| Usage | Monthly Cost | Notes |
|-------|--------------|-------|
| 1GB vault | ~$0.02 | Standard storage class |
| 10GB vault | ~$0.20 | Typical personal wiki size |
| 100GB vault | ~$2.00 | Large documentation site |

### Google Cloud Run
| Usage | Monthly Cost | Free Tier |
|-------|--------------|-----------|
| 0-2M requests | $0.00 | Free tier covers most personal use |
| 100K requests | ~$0.40 | Light personal usage |
| 1M requests | ~$2.40 | Heavy personal usage |

### Additional Services
| Service | Cost | Purpose |
|---------|------|---------|
| Cloud Build | Free (120 build-minutes/day) | GitHub Actions integration |
| IAM | Free | Service account management |
| Artifact Registry | $0.10/GB/month | Container image storage |

## Total Monthly Cost Estimate

### Light Personal Use (Recommended)
- **Storage**: 5GB vault = $0.10
- **Requests**: 50K/month = $0.00 (free tier)
- **Total**: ~$0.10/month (~$1.20/year)

### Heavy Personal Use
- **Storage**: 20GB vault = $0.40
- **Requests**: 500K/month = $1.20
- **Total**: ~$1.60/month (~$19.20/year)

## Cost Optimization Strategies

### 1. Zero-Scaling Configuration
```yaml
# In Cloud Run deployment
--min-instances 0  # Scale to zero when idle
--max-instances 10 # Reasonable upper limit
```

### 2. Storage Optimization
- Use `.gitignore` to exclude unnecessary files
- Compress images before adding to vault
- Archive old content to separate buckets

### 3. Request Optimization
- Enable CDN caching for static assets
- Optimize container startup time
- Use appropriate memory/CPU allocation

### 4. Monitoring and Alerts
```bash
# Set up budget alerts
gcloud alpha billing budgets create \
  --display-name="Perlite Budget Alert" \
  --budget-amount=5 \
  --threshold-rule=percent=90
```

## Free Tier Limits (Google Cloud)
- **Cloud Run**: 2M requests/month, 360K GB-seconds/month
- **Cloud Storage**: 5GB storage/month
- **Cloud Build**: 120 build-minutes/day
- **Egress**: 1GB/month from North America

## Cost Comparison with Alternatives

### Vercel/Netlify
- **Pros**: Easier setup, integrated CI/CD
- **Cons**: Limited to static sites, no server-side processing
- **Cost**: Similar for static content

### Traditional VPS
- **Pros**: Full control, predictable pricing
- **Cons**: Always-on costs ($5-20/month), maintenance overhead
- **Use case**: Better for always-active sites

### Self-hosting
- **Pros**: No cloud costs
- **Cons**: Electricity, internet, hardware maintenance
- **Reality check**: Cloud is cheaper for personal use

## Budget Monitoring Setup

### 1. Enable Billing Alerts
```bash
# Create budget with email notifications
gcloud alpha billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Perlite Monthly Budget" \
  --budget-amount=10 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --notification-config=pubsub-topic=projects/PROJECT_ID/topics/budget-alerts
```

### 2. Monitor Usage
- Set up Google Cloud Monitoring
- Create dashboards for key metrics
- Review monthly billing reports

## Scaling Considerations

### When to Consider Alternatives
- **>10M requests/month**: Consider dedicated hosting
- **>1TB storage**: Evaluate storage classes
- **Multiple users**: Add authentication and user management
- **High availability needs**: Multi-region deployment

## Security vs Cost Trade-offs
- **Public access**: Lower cost, security risk
- **Private with authentication**: Higher complexity, better security
- **VPN access**: Additional cost, maximum security

## Related Files
- [Bucket Sync Setup](BucketSync.md)
- [Cloud Run Deployment](DeploycloudRun.md)
- [Authentication Setup](TestingandAuth.md)
