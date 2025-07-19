# 📘 Project Documentation: AWS EKS with Prometheus, Grafana, and Python App

---

## 🏗️ Infrastructure Overview

```
+-------------------------+
|    AWS Infrastructure  |
+-------------------------+
        |
        ▼
+-------------------------+
|     EKS Cluster         |  <-- created via eksctl or Terraform
|   (Managed K8s)         |
+-------------------------+
        |
        ▼
+--------------------------+      +-------------------------+
|  Python Flask App Pod    | ---> |  Prometheus             |
|  (/metrics endpoint)     |      |  (scrapes app & kube)   |
+--------------------------+      +-------------------------+
                                          |
                                          ▼
                                  +------------------+
                                  |     Grafana      |
                                  |  (visualization) |
                                  +------------------+
```
## 🔧 Tools & Technologies Used

| Tool                 | Purpose                           |
| -------------------- | --------------------------------- |
| **AWS EKS**          | Managed Kubernetes Cluster        |
| **Terraform**        | Infrastructure as Code (optional) |
| **Helm**             | Package manager for Kubernetes    |
| **Prometheus**       | Monitoring system                 |
| **Grafana**          | Dashboard visualization           |
| **Python Flask App** | Expose custom `/metrics` endpoint |
| **kubectl**          | CLI to interact with Kubernetes   |
| **eksctl**           | CLI to create EKS clusters        |

---

## ✅ Prerequisites

Install the following on your system (VS Code used for editing):

```bash
# AWS CLI
aws --version

# kubectl
kubectl version --client

# eksctl
eksctl version

# helm
helm version

# Docker (optional for building Python app)
docker --version
```

---

## 🚀 Setup Steps

### 🔹 1. Configure AWS CLI

```bash
aws configure 
```

Provide your:

* AWS Access Key
* Secret Key
* Region (e.g., `us-east-1`)

---

### 🔹 2. Create EKS Cluster (Using `eksctl`)

**eks-cluster.yaml**:

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: observability-cluster
  region: us-east-1

nodeGroups:
  - name: ng-1
    instanceType: t3.medium
    desiredCapacity: 2
    volumeSize: 20
```

Run:

```bash
eksctl create cluster -f eks-cluster.yaml
```

---

### 🔹 3. Connect `kubectl`

```bash
aws eks --region us-east-1 update-kubeconfig --name observability-cluster
kubectl get nodes
```

---

### 🔹 4. Install Prometheus using Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus
```

---

### 🔹 5. Install Grafana

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana --set adminPassword=admin
```

Expose Grafana locally:

```bash
kubectl port-forward svc/grafana 3000:80
```

Access Grafana at [http://localhost:3000](http://localhost:3000)
Login: `admin / admin`

---

### 🔹 6. Deploy Python Flask App with Prometheus Exporter

**app.py**

```python
from flask import Flask
from prometheus_client import start_http_server, Counter

app = Flask(__name__)
counter = Counter('my_custom_metric', 'An example counter')

@app.route("/")
def home():
    counter.inc()
    return "Hello from Flask!"

@app.route("/metrics")
def metrics():
    return open('/metrics', 'r').read()

if __name__ == "__main__":
    start_http_server(8000)
    app.run(host='0.0.0.0', port=5000)
```

**Dockerfile**

```dockerfile
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install flask prometheus_client
CMD ["python", "app.py"]
```

**Kubernetes Deployment YAML**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-metrics-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-metrics-app
  template:
    metadata:
      labels:
        app: flask-metrics-app
    spec:
      containers:
        - name: app
          image: <your-dockerhub-username>/flask-metrics-app:latest
          ports:
            - containerPort: 5000

---
apiVersion: v1
kind: Service
metadata:
  name: flask-metrics-service
spec:
  selector:
    app: flask-metrics-app
  ports:
    - port: 80
      targetPort: 5000
  type: LoadBalancer
```

Apply:

```bash
kubectl apply -f flask-app.yaml
```

---

### 🔹 7. Add Python App to Prometheus Scrape Targets

Edit Prometheus `values.yaml` or use `ServiceMonitor` if using kube-prometheus-stack.

---

## 📊 Grafana Dashboards

* Login to Grafana at [http://localhost:3000](http://localhost:3000)
* Add Prometheus as a **data source**
* Create dashboards for:

  * Node CPU/Memory
  * Python App Custom Metrics
  * Kubernetes Pods & Services

---

## 🧹 Teardown (Cleanup Everything)

### 🔸 Using `eksctl`:

```bash
eksctl delete cluster --name observability-cluster --region us-east-1
```

### 🔸 Using Terraform (if used):

```bash
terraform destroy
```

### 🔸 Clear `kubectl` Context:

```bash
kubectl config delete-context <your-context>
```

---

## ✅ Benefits of This Setup

| Benefit                  | Description                                |
| ------------------------ | ------------------------------------------ |
| **Scalable Infra**       | EKS handles scaling of nodes and pods      |
| **Real-time Monitoring** | Prometheus scrapes metrics automatically   |
| **Beautiful Dashboards** | Grafana helps visualize everything         |
| **Custom Metrics**       | Python app shows app-level performance     |
| **Cloud-Native**         | All components run on AWS using Kubernetes |

---
## ✅ Benefits of This Setup

| Benefit                  | Description                                |
| ------------------------ | ------------------------------------------ |
| **Scalable Infra**       | EKS handles scaling of nodes and pods      |
| **Real-time Monitoring** | Prometheus scrapes metrics automatically   |
| **Beautiful Dashboards** | Grafana helps visualize everything         |
| **Custom Metrics**       | Python app shows app-level performance     |
| **Cloud-Native**         | All components run on AWS using Kubernetes |

## 🧾 Project Summary

This project demonstrates how to deploy a **Python Flask application** exposing Prometheus metrics, and how to **monitor it using Prometheus and Grafana** on an **AWS EKS (Elastic Kubernetes Service)** cluster. It automates infrastructure deployment using **eksctl** (or optionally Terraform), installs Prometheus and Grafana via **Helm**, and sets up full observability into both application and cluster performance.