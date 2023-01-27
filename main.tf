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
  region      = "us-central1"
}
resource "google_compute_instance" "default" {
  name         = "jenkins-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    network = "default"

    access_config {}
  }
}

resource "google_container_cluster" "k8s" {
  name                     = "k8s"
  location                 = "us-central1"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "k8s_preemptible_nodes" {
  name       = "k8s-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.k8s.name
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
  }
}

output "jenkins-vm-ip" {
  value = google_compute_instance.default.network_interface.0.network_ip
}


