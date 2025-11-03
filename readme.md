# ☁️ Automated MongoDB Backup & Restore with AWS

## Project Overview  
This project simulates a **real-world disaster recovery scenario** where a developer accidentally deleted a production MongoDB database.  
To prevent future data loss, I built a **fully automated backup and restore pipeline** using AWS and MongoDB tools, following production-grade security and automation practices.

---

##  Scenario  
A developer accidentally dropped the production MongoDB during a late-night debug session. The only backup was three days old — 72 hours of customer data lost.  
Management is furious. Your task: build an automated, production-grade backup solution with restore and verification steps to prevent this happening again.

---

## ⚙️ Tools Used  
| Service | Purpose |
|----------|----------|
| **Amazon EC2** | Hosts the backup and restore automation scripts |
| **Amazon S3** | Secure storage for MongoDB backup archives |
| **AWS Secrets Manager** | Stores MongoDB credentials safely |
| **AWS IAM** | Grants least-privilege permissions for S3 and Secrets Manager |
| **MongoDB Atlas** | Managed cloud database for testing restore operations |
| **Cron Jobs** | Automates recurring backups every 6 hours |

---

## 🔄 Backup Workflow  

1. EC2 retrieves MongoDB credentials securely from **AWS Secrets Manager**.  
2. The script runs `mongodump` to export the database into a compressed `.gz` archive.  
3. The file is **timestamped** for easy version tracking.  
4. The backup file is automatically **uploaded to S3**.  
5. Cron job runs every 6 hours for continuous backups.  

**Command Example:**  
```bash
mongodump --uri="$URI" --archive | gzip > "backup_$(date +%F_%H-%M).gz"
aws s3 cp backup_*.gz s3://mongo-db-database/mongodb-backups/
```

---

## ♻️ Restore Workflow  

When a disaster occurs — such as an accidental database deletion — this script automates the process of **retrieving and restoring the latest MongoDB backup** from your S3 bucket back into **MongoDB Atlas**.

---

### 🧭 Step 1: Fetching the Latest Backup from S3  
To restore the database back to MongoDB from the AWS S3 bucket, I created a script using the **AWS CLI** that automatically fetches the **latest backup** stored in S3 as a `.gz` file. In this case, the AWS CLI is used to identify and download the most recent backup file available in the S3 bucket.  

**Command Example:**  
```bash
latest_backup=$(aws s3 ls s3://mongo-db-database/mongodb-backups/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp s3://mongo-db-database/mongodb-backups/$latest_backup ./restore/
```

---

### ♻️ Step 2: Restoring the Backup to MongoDB Atlas  
Once the backup file is downloaded, the script uses the `mongorestore` command to restore it directly into **MongoDB Atlas**:  

```bash
mongorestore --uri="mongodb+srv://${username}:${password}@cluster.mongodb.net/"   --gzip --archive="./restore/$latest_backup" --drop
```

This command decompresses the backup and recreates the database with all the collections and documents.  

---

### ✅ Step 3: Verification  
After the restoration is completed, the script verifies the process by checking the number of documents restored which ensures that the database has been successfully recovered.  
