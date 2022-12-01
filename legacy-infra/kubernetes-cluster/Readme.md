# Provisioning a kubernetes cluster in google cloud with terraform
see https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke

## Prerequisites
* Google Cloud Account
* cli tools: terraform, gcloud, kubectl
* Google Cloud service account
```shell
gcloud iam service-accounts create vcosqui-terraform-account
gcloud projects add-iam-policy-binding solutionsarchitect-01 \
    --member=serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com --role=roles/resourcemanager.projectIamAdmin
gcloud projects add-iam-policy-binding solutionsarchitect-01 \
    --member=serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com --role=roles/container.developer
gcloud projects add-iam-policy-binding solutionsarchitect-01 \
    --member=serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com --role=roles/container.clusterAdmin
gcloud projects add-iam-policy-binding solutionsarchitect-01 \
    --member=serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding solutionsarchitect-01 \
    --member=serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com --role=roles/compute.viewer
```
* a key for such account in json format
```shell
gcloud iam service-accounts keys create ~/vcosqui-terraform-account-key.json --iam-account=vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com
```

* Enable both APIs for your Google Cloud project
```shell
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

## Create cluster
```shell
terraform init
terraform plan
terraform apply -auto-approve
```

## Get kubectl credentials
```shell
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```

## Install kubernetes dashboard
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
```

## Access dashboard
```shell
kubectl proxy
open http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-gke-cluster/main/kubernetes-dashboard-admin.rbac.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
```
