# General provider
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.service_account_file
}

# Creating VPC
resource "google_compute_network" "vpc_network" {
  name = var.vpc_name
  auto_create_subnetworks = false
  project = var.project_id
}

resource "google_compute_subnetwork" "network-with-private-ip-ranges-01" {
  name          = "tf-subnet-private-01"
  ip_cidr_range = "10.0.10.0/26"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "network-with-private-ip-ranges-02" {
  name          = "tf-subnet-private-02"
  ip_cidr_range = "10.0.20.0/26"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

# Creating public static IP
resource "google_compute_address" "static-ip-address" {
  name = "static-ip-address"
}

#Creating Instance
resource "google_compute_instance" "default" { 
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  labels = {
    purpose = "poc"
    creator = "ekatz"
    terraform = "yes"
  }
  boot_disk {
    initialize_params {
    size =  "10"
    image = "debian-11-bullseye-v20230711"
    }
  }
  network_interface {
    network = "terraform-first-vpc"
    subnetwork = google_compute_subnetwork.network-with-private-ip-ranges-01.self_link
    access_config {
      nat_ip = "${google_compute_address.static-ip-address.address}"
    }
 }
  metadata_startup_script = "${file("./instance_setup.sh")}"
}

# Creating network firewall rules
resource "google_compute_firewall" "default" {
  name    = "terraform-firewall"
  network = google_compute_network.vpc_network.name
  source_ranges = ["52.174.16.241", "35.235.240.0/20", "212.143.134.86", "212.143.134.87"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]
  }
}

# Creating data disk
resource "google_compute_disk" "data-disk" {
    name  = "data-disk"
    type  = "pd-standard"
    zone  = "us-central1-a" 
    size = "10"
}

# Associate disk and instance
resource "google_compute_attached_disk" "data-disk" {
  disk     = google_compute_disk.data-disk.id
  instance = google_compute_instance.default.id
}

# Creating Cloud Storage Bucket 
resource "google_storage_bucket" "static" {
 name          = var.cloud_storage_name
 location      = "US"
 storage_class = "STANDARD"
 uniform_bucket_level_access = true
}

# Uploading test file
resource "google_storage_bucket_object" "test" {
 name         = "testFile.txt"
 source       = "./testFile.txt"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}

resource "google_sql_database_instance" "ps-db-instance" {
  count = 1
  name             = "terraform-fist-pg-db"
  database_version = "POSTGRES_15"
  region           = "us-central1"
  settings {
    tier = "db-f1-micro"  # Choose an appropriate machine type
    disk_size = "20"
    backup_configuration {
      enabled = true
    }
    ip_configuration {
    ipv4_enabled = "false"
    private_network = google_compute_network.vpc_network.id
    enable_private_path_for_google_cloud_services = true
    }
  }
    deletion_protection  = "true"
}
