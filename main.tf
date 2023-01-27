terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.50.0"
    }
  }
}

provider "google" {
  credentials = file("./poised-octane-375919-c7f0e79b6315.json")
  project     = "poised-octane-375919"
  region      = "southamerica-east1"
}

data "google_compute_poised-octane-375919_metadata" "jenkins-vm" {
  key = "ssh-keys"
}

resource "google_compute_instance" "default" {
  name         = "jenkins-vm"
  machine_type = "f1-micro"
  zone         = "southamerica-east1-a"
  metadata = {
    ssh-keys = "${data.google_compute_poised-octane-375919_metadata.jenkins-vm.ssh_keys}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    access_config {}
  }
}
