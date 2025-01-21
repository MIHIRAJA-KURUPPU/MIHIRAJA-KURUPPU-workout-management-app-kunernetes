# Setting Up Minikube with PostgreSQL and Web Application

This guide provides instructions for setting up a Kubernetes cluster using Minikube, deploying PostgreSQL with persistent storage, and workout management web application.

---

## Prerequisites

- **Minikube**: Ensure Minikube is installed. Follow the [official documentation](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download) to set it up.
- **kubectl**: Configure an alias for convenience:
  ```bash
  alias kubectl="minikube kubectl --"
  ```

---

## Step 1: Start Minikube

Start your Minikube cluster:
```bash
minikube start
```

To access the Minikube VM, use:
```bash
minikube ssh
```
Switch to root inside the VM:
```bash
sudo su -
```

---

## Step 2: Kubernetes YAML Files

The repository includes the following YAML files:
- `image-storage-pv.yaml`
- `image-storage-pvc.yaml`
- `postgres-pv.yaml`
- `postgres-pvc.yaml`
- `postgres-secret.yaml`
- `postgres-service.yaml`
- `postgres-deployment.yaml`
- `web-app-service.yaml`
- `web-app-deployment.yaml`
-  web-app-secret.yaml

### Edit your `postgres-secret.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: opaque
data:
  POSTGRES_USER: <base64-encoded-username>
  POSTGRES_PASSWORD: <base64-encoded-password>
```

### Edit your `web-app-secret.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: web-app-secret
type: opaque
data:
  DATABASE_URL: <base64-encoded-database-url>
```

#### Generating Base64 Encoded Credentials
Generate credentials using:
```bash
echo -n "<value>" | base64
```
Replace `<value>` with your desired credential.

---
You can also run the encode-secrets.sh script in the scripts/ directory, for encoding secrets.

Encode Secrets: If you're using the encode-secrets.sh script to encode secrets for use in Kubernetes secrets, run it like this:

```bash
./scripts/encode-secrets.sh <your-secret-value>
```

This will output the base64-encoded secret that you can use in your postgres-secret.yaml.


## Step 3: Setting Up the Namespace

To create and set up the namespace for the application, follow these steps:

**Create the Namespace**:
   Apply the namespace manifest file to create the `workout-app-ns` namespace. Run the following command:
  ```bash
 kubectl apply -f manifests/namespace/workout-app-ns.yaml
 ```
This command creates the workout-app-ns namespace as defined in the manifest file.

Set the Current Context Namespace: Configure your Kubernetes context to use the workout-app-ns namespace by default. Run:
```bash
kubectl config set-context --current --namespace=workout-app-ns
 ```

This command updates your current Kubernetes context to use the newly created namespace, ensuring all subsequent kubectl commands target this namespace by default. To verify the setup, you can check the current context and list all namespaces:

 ``` bash
kubectl config view --minify | grep namespace
 ```


## Step 4: Apply Kubernetes Configurations for postgresql database 

Apply all YAML files:
```bash
kubectl apply -f <filename>.yaml
```

To apply the Kubernetes YAML files from the manifests/ directory, you can use the kubectl apply command. :

```bash
# Apply PostgreSQL related files
kubectl apply -f manifests/postgres/postgres-pv.yaml
kubectl apply -f manifests/postgres/postgres-pvc.yaml
kubectl apply -f manifests/postgres/postgres-secret.yaml
kubectl apply -f manifests/postgres/postgres-service.yaml
kubectl apply -f manifests/postgres/postgres-deployment.yaml
```

## Step 5: Initialize PostgreSQL

### Access the PostgreSQL Pod
Find the PostgreSQL pod name:
```bash
kubectl get pods
```
Access the pod:
```bash
kubectl exec -it postgres-deployment-<pod-id> -- /bin/bash
```

### Interact with PostgreSQL
Inside the pod, use the `psql` client:
```bash
psql -U postgres
```

List all databases:
```sql
\l
```

#### Create the `workout` database:
```sql
CREATE DATABASE workout;
```

#### Connect to the Database
Run the following command to connect to the `workout` database:
```sql
\c workout
```

#### View All Available Tables
Once connected, list all tables in the database using:
```sql
\dt
```

#### View Records in a Table
To view the records in a specific table (e.g., `exercise`), run:
```sql
SELECT * FROM exercise;
```

> Replace `exercise` with the desired table name.

---

#### Additional Notes
- For detailed table structures, use:
  ```sql
  \d <table_name>
  ```
- To limit the number of records fetched, you can append a `LIMIT` clause to your query:
  ```sql
  SELECT * FROM exercise LIMIT 10;
  ```
- Use `\q` to exit the PostgreSQL command-line interface.

---

You can also run the setup-database.sh script in the scripts/ directory, for setting up the database.
Setup Database: To initialize the database using setup-database.sh, simply run the following command:

```bash
./scripts/setup-database.sh
```

This script will connect to your running PostgreSQL pod and create the necessary database (e.g., workout) for your application.

## Step 6: Apply Kubernetes Configurations for web application


```bash
# Apply storage related files
kubectl apply -f manifests/storage/image-storage-pv.yaml
kubectl apply -f manifests/storage/image-storage-pvc.yaml

# Apply web app related files
kubectl apply -f manifests/web-app/web-app-service.yaml
kubectl apply -f manifests/web-app/web-app-deployment.yaml
```



## Step 7: Verify resources
- Persistent Volumes (PVs):
  ```bash
  kubectl get pv
  ```
- Persistent Volume Claims (PVCs):
  ```bash
  kubectl get pvc
  ```
- Services:
  ```bash
  kubectl get svc
  ```
- Deployments:
  ```bash
  kubectl get deployment
  ```
- Pods:
  ```bash
  kubectl get pods
  ```

---
## Step 8: # Viewing Uploaded Images in the Pod

Follow these steps to log into the pod, navigate to the `static/uploads/` directory, and view the files:
The pod must be running in your cluster.

Run the following command to get a list of pods:
```bash
kubectl get pods
```
Note down the name of the pod you want to access.

Log Into the Pod
Use the kubectl exec command to open a shell inside the pod:

```bash
kubectl exec -it <pod-name> -- /bin/bash
```

Replace <pod-name> with the actual name of your pod.

Navigate to the Directory
Once inside the pod, navigate to the directory where images are stored:

``` bash
cd /path/to/static/uploads/
```
Replace /path/to with the correct path to the static/uploads/ directory in your pod.

For example:

``` bash
cd /static/uploads/
```

List the Files
To view the list of uploaded images, run:

```bash
ls -l
```

## Step 9: Volume Mounts

Verify volume mounts in Minikube:
```bash
minikube ssh
sudo su -
```
Paths:
- **PostgreSQL Data**: `/mnt/data/postgres`
- **Uploaded Images**: `/mnt/data/uploads`

---

## Notes

- The `postgres-deployment` uses one replica to simplify database interactions.
- Replace placeholder values (e.g., `<base64-encoded-username>`) with actual credentials.
- YAML configurations must match your desired resource requirements.

---

## Directory Structure

The project is organized as follows:
kubernetes-postgres-webapp/
├── README.md                     # Documentation for the project
├── manifests/                    # Kubernetes YAML files
│   ├── postgres/                 # Resources for PostgreSQL
│   │   ├── postgres-pv.yaml      # Persistent Volume for PostgreSQL
│   │   ├── postgres-pvc.yaml     # Persistent Volume Claim for PostgreSQL
│   │   ├── postgres-secret.yaml  # Secret configuration for PostgreSQL
│   │   ├── postgres-service.yaml # Service for PostgreSQL
│   │   └── postgres-deployment.yaml  # Deployment for PostgreSQL
│   ├── storage/                  # Storage-related resources
│   │   ├── image-storage-pv.yaml # Persistent Volume for image storage
│   │   └── image-storage-pvc.yaml # Persistent Volume Claim for image storage
│   ├── web-app/                  # Resources for the web application
│   │   ├── web-app-service.yaml  # Service for the web application
│   │   └── web-app-deployment.yaml # Deployment for the web application
│   │   ├── web-app-secret.yaml   # Secret configuration for web-app
│   └── namespaces/               # Namespace-related resources
│       └── namespace.yaml        # Namespace configuration
├── scripts/                      # Utility scripts
│   ├── encode-secrets.sh         # Script to encode secrets to base64
│   └── setup-database.sh         # Script to initialize the database
└── .gitignore                    # Git ignore file to exclude unwanted files

