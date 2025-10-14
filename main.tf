
resource "yandex_mdb_mysql_cluster" "mysql" {
  name                = var.name
  description         = var.description
  folder_id           = local.folder_id
  environment         = var.environment
  network_id          = var.network_id
  labels              = var.labels
  version             = var.version_sql
  security_group_ids  = var.attach_security_group_ids == null ? [yandex_vpc_security_group.mysql.id] : concat([yandex_vpc_security_group.mysql.id], var.attach_security_group_ids)
  deletion_protection = var.deletion_protection

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type_id
    disk_size          = var.disk_size
  }

  dynamic "maintenance_window" {
    for_each = [var.maintenance_window]
    content {
      type = lookup(maintenance_window.value, "type", "ANYTIME")
      day  = lookup(maintenance_window.value, "day", null)
      hour = lookup(maintenance_window.value, "hour", null)
    }
  }

  dynamic "host" {
    for_each = (var.ha ? range(var.count_ha) : [1])
    content {
      zone             = element(var.subnet_zones, host.key)
      subnet_id        = element(var.subnet_id, host.key)
      name             = "${var.name}-db-host-${host.key + 1}"
      priority         = host.key * 10
      assign_public_ip = var.assign_public_ip
      backup_priority  = host.key
      #TODO
      # replication_source_name
      # (Optional) Host replication source name points to host's name from which this host should replicate. When not set then host in HA group. It works only when name is set.
    }
  }

  mysql_config = var.mysql_config == null ? {} : {
    sql_mode                      = lookup(var.mysql_config, "sql_mode", "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION")
    max_connections               = lookup(var.mysql_config, "max_connections", 100)
    default_authentication_plugin = lookup(var.mysql_config, "default_authentication_plugin", "MYSQL_NATIVE_PASSWORD")
    innodb_print_all_deadlocks    = lookup(var.mysql_config, "innodb_print_all_deadlocks", true)
  }

  dynamic "backup_window_start" {
    for_each = var.backup_window_start == null ? [] : [var.backup_window_start]
    content {
      hours   = lookup(backup_window_start.value, "hours", null)
      minutes = lookup(backup_window_start.value, "minutes", null)
    }
  }

  backup_retain_period_days = var.backup_retain_period_days

  dynamic "restore" {
    for_each = var.restore == null ? [] : [var.restore]
    content {
      backup_id = restore.value["backup_id"]
      time      = lookup(restore.value, "time", null)
    }
  }

  dynamic "access" {
    for_each = var.access == null ? [] : [var.access]
    content {
      data_lens     = lookup(access.value, "data_lens", false)
      web_sql       = lookup(access.value, "web_sql", false)
      data_transfer = lookup(access.value, "data_transfer", false)
    }
  }

  dynamic "performance_diagnostics" {
    for_each = var.performance_diagnostics == null ? [] : [var.performance_diagnostics]
    content {
      enabled                      = var.performance_diagnostics != null ? true : false
      sessions_sampling_interval   = coalesce(performance_diagnostics.value["sessions_sampling_interval"], 3600)
      statements_sampling_interval = coalesce(performance_diagnostics.value["statements_sampling_interval"], 7200)
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

}
