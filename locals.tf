locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id

  # Well-known MySQL parameters get module defaults, any other parameter
  # supported by the provider can be passed through `mysql_config`.
  default_mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = "100"
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = "true"
  }

  mysql_config = var.mysql_config == null ? {} : merge(local.default_mysql_config, var.mysql_config)

  databases            = var.databases == null ? [var.database_name] : var.databases
  primary_database     = local.databases[0]
  additional_databases = slice(local.databases, 1, length(local.databases))

  # Legacy single user is kept as the first element so that existing
  # configurations keep the same resource addresses in the state.
  legacy_users = var.users == null ? [{
    name                  = var.user_name
    password              = var.user_password
    generate_password     = false
    roles                 = var.user_roles
    permissions           = null
    authentication_plugin = null
    global_permissions    = null
    connection_limits     = null
  }] : []

  users            = var.users == null ? local.legacy_users : var.users
  primary_user     = local.users[0]
  additional_users = slice(local.users, 1, length(local.users))
}
