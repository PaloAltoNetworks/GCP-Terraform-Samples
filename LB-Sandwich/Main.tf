######       This Terraform Template Builds a
###       Load Balancer Sandwich with VM-Series in GCP

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
  zone        = "${var.region_zone}"
}

// Adding SSH Public Key Project Wide
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "${var.public_key}"
}

// Adding VPC Networks to Project  MANAGEMENT
resource "google_compute_subnetwork" "management-sub" {
  name          = "management-sub"
  ip_cidr_range = "10.0.0.0/24"
  network       = "${google_compute_network.management.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "management" {
  name                    = "${var.interface_0_name}"
  auto_create_subnetworks = "false"
}

// Adding VPC Networks to Project  UNTRUST
resource "google_compute_subnetwork" "untrust-sub" {
  name          = "untrust-sub"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.untrust.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "untrust" {
  name                    = "${var.interface_1_name}"
  auto_create_subnetworks = "false"
}

// Adding VPC Networks to Project  TRUST
resource "google_compute_subnetwork" "trust-sub" {
  name          = "trust-sub"
  ip_cidr_range = "10.0.2.0/24"
  network       = "${google_compute_network.trust.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "trust" {
  name                    = "${var.interface_2_name}"
  auto_create_subnetworks = "false"
}

// Adding GCP Firewall Rules for MANGEMENT
resource "google_compute_firewall" "allow-mgmt" {
  name    = "allow-mgmt"
  network = "${google_compute_network.management.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP Firewall Rules for INBOUND
resource "google_compute_firewall" "allow-inbound" {
  name    = "allow-inbound"
  network = "${google_compute_network.untrust.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP Firewall Rules for OUTBOUND
resource "google_compute_firewall" "allow-outbound" {
  name    = "allow-outbound"
  network = "${google_compute_network.trust.self_link}"

  allow {
    protocol = "all"

    # ports    = ["all"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP ROUTE to TRUST Interface
resource "google_compute_route" "trust" {
  name                   = "trust-route"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.trust.self_link}"
  next_hop_instance      = "${element(google_compute_instance.firewall.*.name,count.index)}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 100

  depends_on = ["google_compute_instance.firewall",
    "google_compute_network.trust",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}

// Create a new PAN-VM instance
resource "google_compute_instance" "firewall" {
  name                      = "${var.firewall_name}-${count.index + 1}"
  machine_type              = "${var.machine_type_fw}"
  zone                      = "${var.zone}"
  min_cpu_platform          = "${var.machine_cpu_fw}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 3

  // Adding METADATA Key Value pairs to GCE VM 
  metadata {
    // initconfig.txt will perform interface swap of VM-series on bootstrap

    vmseries-bootstrap-gce-storagebucket = "${var.bootstrap_bucket_fw}"
    serial-port-enable                   = true

    # sshKeys                              = "${var.public_key}"
  }

  service_account {
    scopes = "${var.scopes_fw}"
  }

  // Swapped Interface for Load Balancer
  network_interface {
    subnetwork    = "${google_compute_subnetwork.untrust-sub.self_link}"
    access_config = {}
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.management-sub.self_link}"
    access_config = {}
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.trust-sub.self_link}"
  }

  boot_disk {
    initialize_params {
      image = "${var.image_fw}"
    }
  }
}

###########################################
###################  ELB & ILB  LOAD BALANCER and WEB SERVER SETUP BELOW      #############
######################################

resource "google_compute_global_address" "external-address" {
  name = "tf-external-address"
}

resource "google_compute_instance_group" "fw-ig" {
  name = "fw-ig"

  instances = ["${google_compute_instance.firewall.*.self_link}"]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_health_check" "health-check" {
  name = "elb-health-check"

  http_health_check {}
}

resource "google_compute_backend_service" "fw-backend" {
  name     = "fw-backend"
  protocol = "HTTP"

  backend {
    group = "${google_compute_instance_group.fw-ig.self_link}"
  }

  health_checks = ["${google_compute_health_check.health-check.self_link}"]
}

resource "google_compute_url_map" "http-elb" {
  name            = "http-elb"
  default_service = "${google_compute_backend_service.fw-backend.self_link}"
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "tf-http-lb-proxy"
  url_map = "${google_compute_url_map.http-elb.self_link}"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "http-content-gfr"
  target     = "${google_compute_target_http_proxy.http-lb-proxy.self_link}"
  ip_address = "${google_compute_global_address.external-address.address}"
  port_range = "80"
}

resource "google_compute_instance" "webserver-1" {
  name                      = "webserver-1"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.region_zone}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.trust-sub.name}"
  }

  service_account {
    scopes = ["compute-rw"]
  }

  metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance" "webserver-2" {
  name                      = "webserver-2"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.zone_2}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.trust-sub.name}"
  }

  service_account {
    scopes = ["compute-rw"]
  }

  metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance" "webserver-3" {
  name                      = "webserver-3"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.region_zone}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.trust-sub.name}"
  }

  service_account {
    scopes = ["compute-rw"]
  }

  metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance" "webserver-4" {
  name                      = "webserver-4"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.zone_2}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.trust-sub.name}"
  }

  service_account {
    scopes = ["compute-rw"]
  }

  metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance_group" "us-ig1" {
  name = "us-ig1"

  instances = [
    "${google_compute_instance.webserver-1.self_link}",
    "${google_compute_instance.webserver-3.self_link}",
  ]

  zone = "${var.region_zone}"
}

resource "google_compute_instance_group" "us-ig2" {
  name = "us-ig2"

  instances = [
    "${google_compute_instance.webserver-2.self_link}",
    "${google_compute_instance.webserver-4.self_link}",
  ]

  zone = "${var.zone_2}"
}

resource "google_compute_health_check" "my-tcp-health-check" {
  name = "my-tcp-health-check"

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_backend_service" "my-int-lb" {
  name          = "my-int-lb"
  health_checks = ["${google_compute_health_check.my-tcp-health-check.self_link}"]
  region        = "${var.region}"

  backend {
    group = "${google_compute_instance_group.us-ig1.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.us-ig2.self_link}"
  }
}

resource "google_compute_forwarding_rule" "my-int-lb-forwarding-rule" {
  name                  = "my-int-lb-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ports                 = ["80"]
  network               = "${google_compute_network.trust.self_link}"
  subnetwork            = "${google_compute_subnetwork.trust-sub.self_link}"
  backend_service       = "${google_compute_region_backend_service.my-int-lb.self_link}"
}
