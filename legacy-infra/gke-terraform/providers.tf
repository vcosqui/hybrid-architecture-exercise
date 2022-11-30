provider "google" {
  credentials = file("~/vcosqui-terraform-account-key.json")
  project     = "SolutionsArchitect-01"
  region      = "europe-west2-a"
}