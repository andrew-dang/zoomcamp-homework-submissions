# fs.tf | File System Configuration

# Enable VPC Access API
resource "google_project_service" "vpcaccess" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

# Enable Filestore API
resource "google_project_service" "filestore" {
  service            = "file.googleapis.com"
  disable_on_destroy = false
}

resource "google_filestore_instance" "instance" {
  name     = var.app_name
  location = var.zone
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"
  }

  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }

  depends_on = [google_project_service.filestore]
}

resource "google_vpc_access_connector" "connector" {
  name          = "${var.app_name}-connector"
  ip_cidr_range = "10.8.0.0/28"
  region        = var.region
  network       = "default"
  depends_on    = [google_project_service.vpcaccess]
}