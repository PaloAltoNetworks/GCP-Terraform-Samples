// PROJECT Variables

variable "region" {
  default = "us-west1"
}

variable "region_zone" {
  default = "us-west1-a"
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
  default     = "Your_Project_ID"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "~/YourCredential.json"
}

variable "zone" {
  default = "us-west1-a"
}

variable "zone_2" {
  default = "us-west1-b"
}

variable "public_key" {
  default = "sssmith:ssh-rsa AAAAB3bba3DigcNKEpL7GAEln9/BcvRMqJHyQMxt82Wq40DvjL47pSXx81bAYJIrasGBWkgyhP7hJhbQXKki0q2G+E+ykJkZgdqADKUKBmrRivkf/FgChZpEuMIOLIDwtpHYba2IfAgnEGsijCavQVc9+VO1rhvnevYXZlNL480f1JZec4x37V5KO25k49kZaK5F2hVhyh8uo9cJixE0HI0pfbZQkICAzBfX9Jk1/+7y3HapFHpKpjYCDSie8PAysFQRR0zUiIfRR7MMMpFglJQ3OGFtmb6X5ptC9qwGIdxw983kiIFncbyKCgv ssumner@SJCMACW11TG8WL"
}

// FIREWALL Variables
variable "firewall_name" {
  default = "firewall"
}

variable "zone_fw" {
  type    = "list"
  default = ["us-west1-a"]
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
  default = "Your_bootstrap_bucket"
}

variable "interface_0_name" {
  default = "management"
}

variable "interface_1_name" {
  default = "untrust"
}

variable "interface_2_name" {
  default = "trust"
}

variable "interface_3_name" {
  default = "gke"
}

variable "scopes_fw" {
  default = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

// GKE CLUSTER Vaiables

variable "cluster_name" {
  description = "Google Container Cluster name to use for the cluster"
  default     = "gkecluster"
}
