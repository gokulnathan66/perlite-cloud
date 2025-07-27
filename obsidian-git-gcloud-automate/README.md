GitHub Repo
   |
   | (on push)
   v
GitHub Actions
   |
   |----> Clone repo
   |----> Sync vault contents to GCS (gs://your-obsidian-vault)
           (using `gsutil rsync` or `gcloud storage cp`)
   |
Google Cloud Storage (GCS)
   |
   v
Cloud Run (Perlite)
   |
   |----> Reads from GCS bucket (readonly mount or cloud API fetch)
   v
Renders static vault via Perlite


branching into new folder for new deployment strrategy


Read the these thing before implementing the push 
[[https://github.com/secure-77/Perlite/wiki/03---Perlite-Settings#internal-links]]
