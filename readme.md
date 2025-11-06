#  Automated MongoDB Backup & Restore with AWS

##  Scenario  
A developer accidentally dropped the production MongoDB during a late-night debug session. The only backup was three days old — 72 hours of customer data lost.  
Management is furious. Your task: build an automated, production-grade backup solution with restore and verification steps to prevent this from ever happening again.

---

##  Project Overview  
This project simulates a real-world disaster recovery scenario where a production MongoDB database was accidentally deleted.  
To prevent future data loss, I designed and implemented a fully automated backup and restore pipeline using AWS services and MongoDB tools — built with production-grade security, automation, and reliability in mind.

---

##  Tools Used  
| Service | Purpose |
|----------|----------|
| **Amazon EC2** | Hosts the backup and restore automation scripts |
| **Amazon S3** | Secure storage for MongoDB backup archives |
| **AWS Secrets Manager** | Stores MongoDB credentials safely |
| **AWS IAM** | Grants least-privilege permissions for S3 and Secrets Manager |
| **MongoDB Atlas** | Managed cloud database for testing restore operations |
| **Cron Jobs** | Automates recurring backups every 6 hours |

---

##  Implementation Approach  

To tackle this scenario, I utilized the tools and services listed above to build a complete, automated backup and restore system.  

I began by creating a script on my EC2 instance that performs database backups every six hours to minimize data loss. For automation, I configured cron jobs to trigger backups at fixed intervals.  

The script uses the `mongodump` command to export the database into a compressed `.gz` file, which is then automatically uploaded to an Amazon S3 bucket for secure storage. Each backup file is timestamped and can be easily retrieved from the AWS Management Console when needed.  

After ensuring that the backup pipeline was working reliably, I focused on developing the **restore and verification processes** — allowing the system to automatically recover the database and confirm that the data restoration was successful.

---

## 🔄 Backup Workflow  

1. The EC2 instance retrieves MongoDB credentials securely from AWS Secrets Manager.  
2. The script runs `mongodump` to export the database into a compressed `.gz` archive.  
3. The file is **timestamped** for version tracking.  
4. The backup file is automatically uploaded to S3 for safekeeping.  
5. **Cron job** executes the process every 6 hours, ensuring continuous protection.  

**Command Example:**  
```bash
mongodump --uri="$URI" --archive | gzip > "backup_$(date +%F_%H-%M).gz"
aws s3 cp backup_*.gz s3://mongo-db-database/mongodb-backups/
```

>  **Security Note:**  
> MongoDB credentials are not hardcoded in the script. Instead, they are securely stored in AWS Secrets Manager and retrieved dynamically at runtime, following best practices for production environments.

---

## ♻️ Restore Workflow  

In the event of an accidental data deletion or corruption, this automated restore script retrieves the latest backup from Amazon S3 and restores it to MongoDB Atlas

### 🧭 Step 1: Fetching the Latest Backup from S3  
The script uses the **AWS CLI** to identify and download the most recent backup stored in the S3 bucket.  

```bash
latest_backup=$(aws s3 ls s3://mongo-db-database/mongodb-backups/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp s3://mongo-db-database/mongodb-backups/$latest_backup ./restore/
```

---

### ♻️ Step 2: Restoring the Backup to MongoDB Atlas  
Once the backup file is downloaded, the `mongorestore` command is used to restore it into MongoDB Atlas:  

```bash
mongorestore --uri="mongodb+srv://${username}:${password}@cluster.mongodb.net/"   --gzip --archive="./restore/$latest_backup" --drop
```

This command decompresses the archive and restores all collections and documents, recreating the database in full.

---

### ✅ Step 3: Verification  
After restoration, the script verifies the integrity of the recovery by comparing the number of documents in each collection before and after restoration that ensures no data was lost in the process.

---

## 🎥 Demonstrations  

### 🔹 Demo 1: Automated Backup Process  
- Shows cron job triggering backup automatically every 6 hours  
- Demonstrates creation of `.gz` archive using `mongodump`  
- Upload confirmation of backup file to **Amazon S3**

<p align="center">
  <img src="assets/backup_script.gif" alt="Automated Backup Demo" width="600"/>
</p>

---

### 🔹 Demo 2: Database Restoration  
- Retrieves the latest backup from **S3**  
- Executes `mongorestore` to restore data to **MongoDB Atlas**  
- Verifies data integrity by matching collection counts before and after restoration  

<p align="center">
  <img src="assets/restore.gif" alt="Database Restore Demo" width="600"/>
</p>


## 🧩 Key Takeaways  

- Gained hands-on experience in **building and querying databases using MongoDB**  
- Developed **automation scripts** for EC2 and scheduled recurring tasks with **cron jobs**  
- Followed **production-grade security practices** by using **AWS Secrets Manager** to import credentials securely  
- Strengthened understanding of **S3 bucket management**, **IAM least-privilege policies**, and **cloud security best practices**

---

