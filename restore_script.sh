#!/bin/bash

#variables
bucket_name="mongo-db-database"
backup_prefix="mongodb-backups"
restore_dir="/home/ec2-user/restore"

# fetching credentials from secret manager
secret=$(aws secretsmanager get-secret-value --secret-id mongo-db-login --query SecretString --output text)
username=$(echo "$secret" | jq -r .username)
password=$(echo "$secret" | jq -r .password)

# locally creating restore directory
mkdir -p "$restore_dir"
cd "$restore_dir" || exit

# code command line to find the latest script
latest_backup=$(aws s3 ls s3://$bucket_name/$backup_prefix/ | sort | tail -n 1 | awk '{print $4}')

# code command line to check if backup exits
if [ -z "$latest_backup" ]; then
    echo "❌ No backup file found in s3://$bucket_name/$backup_prefix/"
    exit 1
fi

echo " latest backup: $latest_backup"
echo " Downloading from S3..."
aws s3 cp "s3://$bucket_name/$backup_prefix/$latest_backup" "$restore_dir/$latest_backup"

# restoring file to mongo atlas
echo "Restoring backup into MongoDB Atlas"
mongorestore --uri="mongodb+srv://${username}:${password}@cluster0.r2qtgwn.mongodb.net/" \
  --gzip --archive="$restore_dir/$latest_backup" --drop

echo " Restore completed successfully!"
