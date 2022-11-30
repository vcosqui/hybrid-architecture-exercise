
see https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke

## prerequisites
* a Google Cloud Account
* a project in your Google Cloud Account Cloud Console
* Kubernetes Engine API enabled
* terraform
* gcloud cli ( make sure to gcloud login )
* kubectl
* Google Cloud Account credentials with role "Project: Owner"
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
gcloud iam service-accounts keys create vcosqui-terraform-account-key.json --iam-account=vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com
```
* Enable both APIs for your Google Cloud project
```shell
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```