output "id" {
  description = "The ID of the MySQL cluster"
  value       = yandex_mdb_mysql_cluster.mysql.id
}

output "name" {
  description = "The name of the MySQL cluster"
  value       = yandex_mdb_mysql_cluster.mysql.name
}

output "fqdn" {
  description = "The fully qualified domain name of the MySQL cluster"
  value       = "c-${yandex_mdb_mysql_cluster.mysql.id}.rw.mdb.yandexcloud.net"
}

output "hosts" {
  description = "List of host FQDNs in the MySQL cluster"
  value       = [for host in yandex_mdb_mysql_cluster.mysql.host : host.fqdn]
}

output "network_id" {
  description = "The ID of the network to which the MySQL cluster belongs"
  value       = yandex_mdb_mysql_cluster.mysql.network_id
}

output "security_group_id" {
  description = "The ID of the security group assigned to the MySQL cluster"
  value       = yandex_vpc_security_group.mysql.id
}

output "environment" {
  description = "The deployment environment of the MySQL cluster"
  value       = yandex_mdb_mysql_cluster.mysql.environment
}

output "version" {
  description = "The version of the MySQL cluster"
  value       = yandex_mdb_mysql_cluster.mysql.version
}

output "resources" {
  description = "The resources allocated to the MySQL cluster"
  value = {
    resource_preset_id = yandex_mdb_mysql_cluster.mysql.resources[0].resource_preset_id
    disk_type_id       = yandex_mdb_mysql_cluster.mysql.resources[0].disk_type_id
    disk_size          = yandex_mdb_mysql_cluster.mysql.resources[0].disk_size
  }
}

output "maintenance_window" {
  description = "The maintenance window settings of the MySQL cluster"
  value = {
    type = yandex_mdb_mysql_cluster.mysql.maintenance_window[0].type
    day  = yandex_mdb_mysql_cluster.mysql.maintenance_window[0].day
    hour = yandex_mdb_mysql_cluster.mysql.maintenance_window[0].hour
  }
}

output "backup_window_start" {
  description = "The backup window start time of the MySQL cluster"
  value = {
    hours   = yandex_mdb_mysql_cluster.mysql.backup_window_start[0].hours
    minutes = yandex_mdb_mysql_cluster.mysql.backup_window_start[0].minutes
  }
}

output "backup_retain_period_days" {
  description = "The number of days to retain backups for the MySQL cluster"
  value       = yandex_mdb_mysql_cluster.mysql.backup_retain_period_days
}

output "access" {
  description = "The access settings of the MySQL cluster"
  value = {
    data_lens     = yandex_mdb_mysql_cluster.mysql.access[0].data_lens
    web_sql       = yandex_mdb_mysql_cluster.mysql.access[0].web_sql
    data_transfer = yandex_mdb_mysql_cluster.mysql.access[0].data_transfer
  }
}

output "performance_diagnostics" {
  description = "The performance diagnostics settings of the MySQL cluster"
  value = {
    enabled                      = yandex_mdb_mysql_cluster.mysql.performance_diagnostics[0].enabled
    sessions_sampling_interval   = yandex_mdb_mysql_cluster.mysql.performance_diagnostics[0].sessions_sampling_interval
    statements_sampling_interval = yandex_mdb_mysql_cluster.mysql.performance_diagnostics[0].statements_sampling_interval
  }
}
