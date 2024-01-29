variable "credentials" {
  description = "My Credentials"
  default     = "../secrets/dummy_service_account_key.json"
}

variable "project" {
  description = "Project"
  default     = "dummy_project_id"
}

variable "region" {
  description = "Region"
  default     = "some_region"
}

variable "location" {
  description = "Project Location"
  default     = "some_location"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "dummy_dataset_name"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "dummy_bucket_name"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}