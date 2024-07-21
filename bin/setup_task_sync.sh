#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF
# source "$(dirname "$(realpath "$0")")/common.sh"
source "bin/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Check necessary environment variables and libs
------------------------------------------------------------------------
EOF

TASK_SYNC_GCP_BUCKET_NAME="${TASK_SYNC_GCP_BUCKET_NAME:-}"
TASK_SYNC_GCP_SA_CREDENTIAL_PATH="${TASK_SYNC_GCP_SA_CREDENTIAL_PATH:-}"
TASK_SYNC_ENCRYPTION_SECRET="${TASK_SYNC_ENCRYPTION_SECRET:-}"

if ! type task >/dev/null 2>&1; then
    err_echo "taskwarrior is not installed."
    exit 1
fi
if ! type gcloud >/dev/null 2>&1; then
    err_echo "gcloud is not installed."
    exit 1
fi

if [[ -z "${TASK_SYNC_GCP_BUCKET_NAME}" ]]; then
    err_echo "TASK_SYNC_GCP_BUCKET_NAME is not set in environment variables."
    exit 1
fi

if [[ -z "${TASK_SYNC_GCP_SA_CREDENTIAL_PATH}" ]]; then
    err_echo "TASK_SYNC_GCP_SA_CREDENTIAL_PATH is not set in environment variables."
    exit 1
fi

if [[ -z "${TASK_SYNC_ENCRYPTION_SECRET}" ]]; then
    err_echo "TASK_SYNC_ENCRYPTION_SECRET is not set in environment variables."
    exit 1
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Setup Taskwarrior sync with GCP bucket.
------------------------------------------------------------------------
EOF

task config sync.gcp.bucket "${TASK_SYNC_GCP_BUCKET_NAME}"
task config sync.encryption_secret "${TASK_SYNC_ENCRYPTION_SECRET}"
task config sync.gcp.credential_path "${TASK_SYNC_GCP_SA_CREDENTIAL_PATH}"

# Initialize the sync for the first time
task sync

# Add cron job to sync every 5 minutes if not exists
if ! crontab -l | grep -q "task sync"; then
    crontab -l | {
        cat
        echo "*/5 * * * * task sync"
    } | crontab -
fi
