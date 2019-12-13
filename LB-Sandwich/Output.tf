output "firewall-name" {
  value = "${google_compute_instance.firewall.*.name}"
}

output "elb_public_ip" {
  value = "${google_compute_global_forwarding_rule.default.ip_address}"
}

output "firewall-untrust-ips-for-nat-healthcheck" {
  value = "${google_compute_instance.firewall.*.network_interface.0.address}"
}

output "internal-lb-ip-for-nat-healthcheck" {
  value = "${google_compute_forwarding_rule.my-int-lb-forwarding-rule.ip_address}"
}
