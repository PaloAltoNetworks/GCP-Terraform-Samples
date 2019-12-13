// PROJECT Variables
variable "my_gcp_project" {
  default = "Your_Project_ID"
}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-a"
}

variable "public_key" {
  default = "Your_Public_Key_in_RSA_Format"
}

// FIREWALL Variables
variable "firewall_name" {
  default = "vm-series"
}

variable "image_fw" {
 # default = "Your_VM_Series_Image"
  
  # /Cloud Launcher API Calls to images/
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-810"
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle2-810"
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle1-810"

}

variable "machine_type_fw" {
  default = "n1-standard-4"
}

variable "machine_cpu_fw" {
  default = "Intel Skylake"
}

variable "bootstrap_bucket_fw" {
  default = "Your_Bootstrap_Bucket"
}

variable "interface_0_name" {
  default = "management"
}

variable "interface_1_name" {
  default = "untrust"
}

variable "scopes_fw" {
  default = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

// DB-SERVER Variables
variable "db_server_name" {
  default = "db-vm"
}

variable "machine_type_db" {
  default = "f1-micro"
}

variable "interface_3_name" {
  default = "db"
}

variable "image_db" {
  default = "debian-8"
}

variable "db_startup_script_bucket" {
  default = "Your_Startup_Bucket "

  // Example of string for startup bucket "gs://startup-2-tier/dbserver-startup.sh"
}

variable "scopes_db" {
  default = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/compute.readonly",
  ]
}

variable "ip_db" {
  default = "10.5.3.5"
}

// WEB-SERVER Vaiables
variable "web_server_name" {
  default = "webserver"
}

variable "machine_type_web" {
  default = "f1-micro"
}

variable "interface_2_name" {
  default = "web"
}

variable "image_web" {
  default = "debian-8"
}

variable "web_startup_script_bucket" {
  default = "Your_Startup_Bucket"

  //  Example of string for startup bucket  "gs://startup-2-tier/webserver-startup.sh"
}

variable "scopes_web" {
  default = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/compute.readonly",
  ]
}

variable "ip_web" {
  default = "10.5.2.5"
}
