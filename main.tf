terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.50.0"
    }
  }
}
provider "google" {
  credentials = file("./jornada-376212-5fd9b84d8f47.json")
  project     = "jornada-376212"
  region      = "us-central1"
}
resource "google_compute_instance" "default" {
  name         = "jenkins-vm"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"
  tags         = ["jenkins-vm"]
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

resource "google_compute_firewall" "jenkins-port" {
  name    = "jenkins-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-vm"]
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
  node_count = 1

  node_config {
    preemptible  = true
    disk_size_gb = 100
    machine_type = "e2-medium"
  }
}
output "jenkins-vm-ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
