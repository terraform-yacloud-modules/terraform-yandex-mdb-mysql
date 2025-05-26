data "yandex_client_config" "client" {}

resource "yandex_vpc_network" "main" {
  folder_id = "b1gts6lhpg0oskqf7v32"
  name      = "vpc-nat-gateway"
}

resource "yandex_vpc_gateway" "nat" {
  folder_id = "b1gts6lhpg0oskqf7v32"
  name      = "vpc-nat-gateway-nat"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  folder_id   = "b1gts6lhpg0oskqf7v32"
  name        = "vpc-nat-gateway-prv-0"
  network_id  = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "private" {
  folder_id      = "b1gts6lhpg0oskqf7v32"
  name           = "vpc-nat-gateway-prv-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  route_table_id = yandex_vpc_route_table.private.id
  v4_cidr_blocks = ["10.4.0.0/24"]

}

resource "yandex_mdb_mysql_cluster" "mysql" {
  name                        = "my-mysql-cluster"
  environment                 = "PRODUCTION"
  version                     = "8.0"
  folder_id                   = "b1gts6lhpg0oskqf7v32"
  network_id                  = yandex_vpc_network.main.id
  backup_retain_period_days   = 14
  deletion_protection         = false
  allow_regeneration_host     = false

  mysql_config = {
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = "true"
    max_connections               = "100"
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }

  backup_window_start {
    hours   = 3
    minutes = 0
  }

  maintenance_window {
    type = "ANYTIME"
  }

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
