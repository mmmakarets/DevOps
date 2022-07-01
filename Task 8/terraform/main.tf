terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "mysql" {
  name         = "mmmakarets/mmmakarets-mysql:1.0.4"
  keep_locally = true
}

resource "docker_image" "wordpress" {
  name         = "mmmakarets/mmmakarets-wordpress:1.0.5"
  keep_locally = true
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.latest
  name  = "mysql"
}

resource "docker_container" "wordpress" {
  image = docker_image.wordpress.latest
  name  = "wordpress"
  ports {
    internal = 80
    external = 80
  }
}