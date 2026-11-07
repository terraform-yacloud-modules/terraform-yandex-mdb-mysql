resource "yandex_mdb_mysql_cluster" "mysql" {
  name                   = var.name
  description            = var.description
  folder_id              = local.folder_id
  environment            = var.environment
  network_id             = var.network_id
  labels                 = var.labels
  version                = var.version_sql
  security_group_ids     = var.attach_security_group_ids == null ? [yandex_vpc_security_group.mysql.id] : concat([yandex_vpc_security_group.mysql.id], var.attach_security_group_ids)
  deletion_protection    = var.deletion_protection
  disk_encryption_key_id = var.disk_encryption_key_id
  host_group_ids         = var.host_group_ids

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

  mysql_config = local.mysql_config

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
      backup_id         = restore.value["backup_id"]
      source_cluster_id = restore.value["source_cluster_id"]
      time              = lookup(restore.value, "time", null)
    }
  }

  dynamic "access" {
    for_each = var.access == null ? [] : [var.access]
    content {
      data_lens     = lookup(access.value, "data_lens", false)
      web_sql       = lookup(access.value, "web_sql", false)
      data_transfer = lookup(access.value, "data_transfer", false)
      yandex_query  = lookup(access.value, "yandex_query", false)
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

  dynamic "disk_size_autoscaling" {
    for_each = var.disk_size_autoscaling == null ? [] : [var.disk_size_autoscaling]
    content {
      disk_size_limit           = disk_size_autoscaling.value.disk_size_limit
      emergency_usage_threshold = try(disk_size_autoscaling.value.emergency_usage_threshold, null)
      planned_usage_threshold   = try(disk_size_autoscaling.value.planned_usage_threshold, null)
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

resource "yandex_mdb_mysql_database" "mysql_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = local.primary_database
}

resource "yandex_mdb_mysql_database" "additional" {
  for_each = toset(local.additional_databases)

  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = each.value
}

resource "yandex_mdb_mysql_user" "mysql_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = local.primary_user.name

  depends_on = [
    yandex_mdb_mysql_database.mysql_db,
    yandex_mdb_mysql_database.additional,
  ]

  password              = local.primary_user.password
  generate_password     = local.primary_user.generate_password
  authentication_plugin = local.primary_user.authentication_plugin
  global_permissions    = local.primary_user.global_permissions

  dynamic "connection_limits" {
    for_each = local.primary_user.connection_limits == null ? [] : [local.primary_user.connection_limits]
    content {
      max_connections_per_hour = try(connection_limits.value.max_connections_per_hour, null)
      max_questions_per_hour   = try(connection_limits.value.max_questions_per_hour, null)
      max_updates_per_hour     = try(connection_limits.value.max_updates_per_hour, null)
      max_user_connections     = try(connection_limits.value.max_user_connections, null)
    }
  }

  dynamic "permission" {
    for_each = local.primary_user.permissions == null ? [{ database_name = local.primary_database, roles = local.primary_user.roles }] : local.primary_user.permissions
    content {
      database_name = permission.value.database_name
      roles         = permission.value.roles
    }
  }
}

resource "yandex_mdb_mysql_user" "additional" {
  for_each = { for user in local.additional_users : user.name => user }

  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = each.value.name

  depends_on = [
    yandex_mdb_mysql_database.mysql_db,
    yandex_mdb_mysql_database.additional,
  ]

  password              = each.value.password
  generate_password     = each.value.generate_password
  authentication_plugin = each.value.authentication_plugin
  global_permissions    = each.value.global_permissions

  dynamic "connection_limits" {
    for_each = each.value.connection_limits == null ? [] : [each.value.connection_limits]
    content {
      max_connections_per_hour = try(connection_limits.value.max_connections_per_hour, null)
      max_questions_per_hour   = try(connection_limits.value.max_questions_per_hour, null)
      max_updates_per_hour     = try(connection_limits.value.max_updates_per_hour, null)
      max_user_connections     = try(connection_limits.value.max_user_connections, null)
    }
  }

  dynamic "permission" {
    for_each = each.value.permissions == null ? [{ database_name = local.primary_database, roles = each.value.roles }] : each.value.permissions
    content {
      database_name = permission.value.database_name
      roles         = permission.value.roles
    }
  }
}
