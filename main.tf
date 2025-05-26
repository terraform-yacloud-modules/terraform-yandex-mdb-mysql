data "yandex_client_config" "client" {}

resource "yandex_vpc_network" "main" {
  folder_id = "b1gts6lhpg0oskqf7v32"
  name      = "vpc-nat-gateway"
}

resource "yandex_vpc_subnet" "private" {
  folder_id      = "b1gts6lhpg0oskqf7v32"
  name           = "vpc-nat-gateway-prv-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.4.0.0/24"]

}

resource "yandex_mdb_mysql_cluster" "mysql" {
  name                        = "my-mysql-cluster"
  environment                 = "PRODUCTION"
  version                     = "8.0"
  folder_id                   = "b1gts6lhpg0oskqf7v32"
  network_id                  = yandex_vpc_network.main.id
  allow_regeneration_host     = false

  resources {
    resource_preset_id = "s1.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 10
  }

  host {
    zone               = "ru-central1-a"
    name               = "my-mysql-cluster-db-host-1"
    subnet_id          = yandex_vpc_subnet.private.id
  }
}
