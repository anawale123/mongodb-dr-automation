#!/bin/bash

#setting up variables
BACKUP_DIR="/home/ec2-user/backup"
S3_BUCKET="s3://mongo-db-database/mongodb-backups"
SECRET_ID="MongoDBBackupSecret"

#fetch secret
secret=$(aws secretsmanager get-secret-value --secret-id mongo-db-login --query SecretString --output text)
username=$(echo "$secret" | jq -r .username)
password=$(echo "$secret" | jq -r .password)

#creating directory
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

#DUMP DATABASE
URI="mongodb+srv://${username}:${password}@cluster1.r2qtgwn.mongodb.net/"
timestamp=$(date +%F_%H-%M)
backup_file="backup_$timestamp.gz"

echo "Starting MongoDB backup..."
mongodump --uri="$URI" --archive | gzip > "$backup_file"

#UPLOADING TO S3 BUCKET
echo "Uploading to S3..."
aws s3 cp "$backup_file" "$S3_BUCKET/$backup_file"

echo "Backup completed and uploaded as $backup_file"

