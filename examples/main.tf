data "yandex_client_config" "client" {}

module "network" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-vpc.git?ref=v1.0.0"

  folder_id = data.yandex_client_config.client.folder_id

  blank_name = "vpc-nat-gateway"
  labels = {
    repo = "terraform-yacloud-modules/terraform-yandex-vpc"
  }

  azs = ["ru-central1-a"]

  private_subnets = [["10.4.0.0/24"]]

  create_vpc         = true
  create_nat_gateway = true
}

module "mysql" {
  source = "../"

  # Общие настройки
  name         = "my-mysql-cluster"
  description  = "MySQL cluster created by Terraform"
  environment  = "PRODUCTION"
  folder_id    = data.yandex_client_config.client.folder_id
  network_id   = module.network.vpc_id
  subnet_zones = ["ru-central1-a"]
  subnet_id    = [module.network.private_subnets_ids[0]]
  labels = {
    created_by = "terraform_mysql_module"
  }
  version_sql        = "8.0"
  resource_preset_id = "s1.micro"
  disk_type_id       = "network-ssd"
  disk_size          = 10

  # Настройки безопасности
  allow_ingress_v4_cidr_blocks = ["0.0.0.0/0"]

  # Настройки MySQL
  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
  }

  # Настройки обслуживания
  maintenance_window = {
    type = "WEEKLY"
    day  = "MON"
    hour = 3
  }

  # Настройки резервного копирования
  backup_window_start = {
    hours   = 3
    minutes = 0
  }
  backup_retain_period_days = 14

  # Настройки доступа
  access = {
    data_lens     = false
    web_sql       = true
    data_transfer = false
  }

  # Настройки диагностики производительности
  performance_diagnostics = {
    enabled                      = true
    sessions_sampling_interval   = 3600
    statements_sampling_interval = 7200
  }

  # Настройки автоскейлинга диска
  disk_size_autoscaling = {
    disk_size_limit           = 100
    emergency_usage_threshold = 90
    planned_usage_threshold   = 80
  }

  # Другие настройки
  ha                  = false
  deletion_protection = false
  assign_public_ip    = false
  count_ha            = 3

  depends_on = [module.network]

  timeouts = {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

}
