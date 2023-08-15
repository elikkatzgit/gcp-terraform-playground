variable "project_id" {
  type        = string
  description = "The project ID"
  default = "hi-ota-prj-renaultsolution"
}

variable "region" {
  type        = string
  description = "GCP region in which to launch resources"
  default     = "us-central1"
}

variable "vpc_name" {
  type        = string
  description = "GCP vpn in which to launch resources"
  default     = "terraform-first-vpc"
}

variable "service_account_file" {
  type        = string
  description = "GCP Service account file and path"
  default     = "/home/hadmin/.config/gcloud/.hi-ota-prj-renaultsolution-cd83c50ad98d.json"
}

variable "instance_name" {
  type        = string
  default     = "terraform-first-instance"
}

variable "cloud_storage_name" {
  type        = string
  default     = "terraform-first-bucket"
}
