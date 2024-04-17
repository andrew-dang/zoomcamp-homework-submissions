variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "mage-data-prep"
}

variable "container_cpu" {
  description = "Container cpu"
  default     = "2000m"
}

variable "container_memory" {
  description = "Container memory"
  default     = "2G"
}

variable "project_id" {
  type        = string
  description = "The name of the project"
  default     = "<YOUR_PROJECT_ID>"
}

variable "region" {
  type        = string
  description = "The default compute region"
  default     = "<YOUR_REGION>"
}

variable "zone" {
  type        = string
  description = "The default compute zone"
  default     = "<YOUR_ZONE>"
}

variable "repository" {
  type        = string
  description = "The name of the Artifact Registry repository to be created"
  default     = "mage-data-prep"
}

variable "database_user" {
  type        = string
  description = "The username of the Postgres database."
  default     = "mageuser"
}

variable "database_password" {
  type        = string
  description = "The password of the Postgres database."
  sensitive   = true
}

variable "docker_image" {
  type        = string
  description = "The Docker image url in the Artifact Registry repository to be deployed to Cloud Run"
  default     = "<YOUR_REGION>-docker.pkg.dev/<YOUR_PROJECT_ID>/mage-data-prep/mageai"
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type        = string
  default     = ""
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = false
}

variable "path_to_keyfile" {
  description = "Path to the keyfile containing GCP credentials."
  type        = string
  default     = "/secrets/gcp/service_account_credentials"
}
