output "publicIP" {
  description = "The public IP the instance will be associated with"
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

output "storage_url" {
  # value = "${data.google_storage_object_signed_url.get_url.signed_url}"
  value = "${google_storage_bucket_object.test.self_link}"
}
