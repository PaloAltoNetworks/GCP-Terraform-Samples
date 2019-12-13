output "firewall-name" {
  value = "${google_compute_instance.firewall.*.name}"
}

output "elb_public_ip" {
  value = "${google_compute_global_forwarding_rule.default.ip_address}"
}

output "firewall-untrust-ips-for-nat-healthcheck" {
  value = "${google_compute_instance.firewall.*.network_interface.0.address}"
}

output "cluster_name" {
  value = "${google_container_cluster.primary.name}"
}

output "primary_zone" {
  value = "${google_container_cluster.primary.zone}"
}

output "additional_zones" {
  value = "${google_container_cluster.primary.additional_zones}"
}

output "node_version" {
  value = "${google_container_cluster.primary.node_version}"
}
