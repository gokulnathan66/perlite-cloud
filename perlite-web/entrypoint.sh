#!/bin/sh

echo "[INFO] Starting container at $(date)"

# Default bucket path (can be overridden by env var)
# put your gcloud bucket path here 
BUCKET_PATH=${GCS_BUCKET_PATH:-"gs://<your-gcloud-bucket-path>"}
TARGET_DIR="/var/www/perlite/Demo"

# Clean up and prepare target dir
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Check if gsutil is available
if ! command -v gsutil &> /dev/null; then
    echo "[ERROR] gsutil not found in PATH"
    exit 1
fi

# Sync from GCS (with error handling)
echo "[INFO] Syncing from $BUCKET_PATH to $TARGET_DIR"
if gsutil -m rsync -r "$BUCKET_PATH" "$TARGET_DIR"; then
    echo "[INFO] Successfully synced from GCS"
else
    echo "[ERROR] Failed to sync from GCS"
    # Continue anyway for local testing
fi

# Start services
echo "[INFO] Starting supervisord"
exec /usr/bin/supervisord -c /etc/supervisord.conf
