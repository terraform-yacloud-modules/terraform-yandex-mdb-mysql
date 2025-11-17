variable "ha" {
  type        = bool
  description = "(Optional) High availability cluster?"
  default     = false
}

variable "deletion_protection" {
  type        = bool
  description = "(Optional) Protection against cluster deletion"
  default     = false
}

variable "assign_public_ip" {
  type        = bool
  description = "(Optional) Sets whether the host should get a public IP address. It can be changed on the fly only when name is set."
  default     = false
}

variable "count_ha" {
  type        = number
  description = "(Optional) Number of hosts in a high availability cluster"
  default     = 3
  validation {
    condition     = var.count_ha >= 1 && var.count_ha <= 7
    error_message = "Invalid number of hosts in a high availability cluster. Maximum 7 hosts"
  }
}

variable "name" {
  type        = string
  description = "(Required) Name of the MySQL cluster. Provided by the client when the cluster is created."
  default     = "cluster-mysql"
}

variable "description" {
  description = "(Optional) Description of the MySQL cluster."
  type        = string
  default     = "terraform-created"
}

variable "environment" {
  type        = string
  description = "(Optional) Deployment environment of the MySQL cluster"
  default     = "PRODUCTION"
  validation {
    condition     = contains(["PRESTABLE", "PRODUCTION", ], var.environment)
    error_message = "Invalid environment of the MySQL cluster."
  }
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default     = null
}

variable "network_id" {
  type        = string
  description = "(Required) ID of the network, to which the MySQL cluster belongs."
}

variable "subnet_zones" {
  type        = list(string)
  description = "(Optional) Zones name of the network, to which the MySQL cluster belongs."
  default     = ["ru-central1-a"]
}

variable "subnet_id" {
  type        = list(string)
  description = "(Optional) The ID of the subnets, to which the host belongs. The subnet must be a part of the network to which the cluster belongs."
  default     = null

}

variable "labels" {
  description = "(Optional) Set of key/value label pairs to assign."
  type        = map(string)
  default = {
    created_by = "terraform_mysql_module"
  }
}

variable "version_sql" {
  type        = string
  description = "(Optional) Version of the MySQL cluster. Default '8.0'"
  default     = "8.0"
  validation {
    condition     = contains(["5.7", "8.0"], var.version_sql)
    error_message = "Invalid version of the MySQL cluster."
  }
}

variable "resource_preset_id" {
  type        = string
  description = "(Optional) The ID of the preset for computational resources available to a MySQL host. Default 's1.micro' "
  default     = "s1.micro"
  # validation {
  #   condition     = contains(["s1.micro", "s2.micro", "s1.small", "s2.small", "s1.medium", "s2.medium", "s1.large", "s2.large", "s1.xlarge", "s2.xlarge", "b1.medium"], var.resource_preset_id)
  #   error_message = "Invalid the ID of the preset for computational resources available to a MySQL host. Allow \"Intel Broadwell\" and \"Intel Cascade Lake\" (not all)"
  # }
}

variable "disk_type_id" {
  type        = string
  description = "(Optional) Type of the storage of MySQL hosts. Default 'network-ssd'"
  default     = "network-ssd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "local-ssd", "network-ssd-nonreplicated"], var.disk_type_id)
    error_message = "Invalid type of the storage of MySQL hosts."
  }
}

variable "disk_size" {
  type        = number
  description = "(Optional) Volume of the storage available to a MySQL host, in gigabytes. Default '10'. https://yandex.cloud/ru/docs/managed-mysql/concepts/limits"
  default     = 10
  validation {
    condition     = var.disk_size >= 10 && var.disk_size <= 6144
    error_message = "Invalid size of the storage of MySQL hosts."
  }
}

variable "mysql_config" {
  type = object({
    sql_mode                      = optional(string)
    max_connections               = optional(number)
    default_authentication_plugin = optional(string)
    innodb_print_all_deadlocks    = optional(bool)
  })
  description = "(Optional) MySQL cluster config. Detail info in https://terraform-provider.yandexcloud.net/Resources/mdb_mysql_cluster.html#mysql-config"
  default     = null
}

variable "maintenance_window" {
  type = object({
    type = optional(string)
    day  = optional(string)
    hour = optional(number)
  })
  default = {
    type = "ANYTIME"
    day  = null
    hour = null
  }
  validation {
    condition = (
      (contains(["ANYTIME", "WEEKLY"], var.maintenance_window.type)) &&
      ((var.maintenance_window.day == null && var.maintenance_window.type == "ANYTIME") ? true : (contains(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], var.maintenance_window.day)) && var.maintenance_window.type == "WEEKLY") &&
      ((var.maintenance_window.hour == null && var.maintenance_window.type == "ANYTIME") ? true : ((var.maintenance_window.hour >= 1 && var.maintenance_window.hour <= 24)) && var.maintenance_window.type == "WEEKLY")
    )
    error_message = <<EOF
    Invalid values.
    Type of maintenance window. Can be either "ANYTIME" or "WEEKLY".
    "Day" and "Hour" are allowed if the "type" is equal to "WEEKLY".
    Day of the week (in DDD format). Allowed values: "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN".
    Hour of the day in UTC (in HH format). Allowed value is between 1 and 24.
    Default type - ANYTIME.
    EOF
  }
  description = "(Optional) Time to start the daily backup, in the UTC."
}

variable "backup_window_start" {
  type = object({
    hours   = optional(number)
    minutes = optional(number)
  })
  default     = null
  description = "(Optional) Time to start the daily backup, in the UTC."
  validation {
    condition = (
      var.backup_window_start == null ? true : (
        (var.backup_window_start.hours == null ? true : (var.backup_window_start.hours >= 0 && var.backup_window_start.hours <= 23)) &&
        (var.backup_window_start.minutes == null ? true : (var.backup_window_start.minutes >= 0 && var.backup_window_start.minutes <= 59))
      )
    )
    error_message = "Invalid backup window start time. Hours must be between 0-23, minutes between 0-59."
  }
}

variable "backup_retain_period_days" {
  type        = number
  default     = null
  description = "(Optional) The period in days during which backups are stored."
  validation {
    condition     = var.backup_retain_period_days == null ? true : (var.backup_retain_period_days >= 7 && var.backup_retain_period_days <= 60)
    error_message = "Invalid type of the storage of MySQL hosts. Allowed value is between 7 and 60."
  }
}

variable "restore" {
  type = object({
    backup_id = string
    time      = optional(string)
  })
  default     = null
  description = <<EOF
  (Optional) Time to start the daily backup, in the UTC. The structure is documented below.
  backup_id - (Required, ForceNew) Backup ID. The cluster will be created from the specified backup.
  time      - (Optional, ForceNew) Timestamp of the moment to which the MySQL cluster should be restored. (Format: "2006-01-02T15:04:05" - UTC). When not set, current time is used.
  restore = {
    backup_id = "c9qj2tns23432471d9qha:stream_20210122T141717Z"
    time      = "2021-01-23T15:04:05"
  }
  EOF
}

variable "access" {
  type = object({
    data_lens     = optional(bool)
    web_sql       = optional(bool)
    data_transfer = optional(bool)
  })
  default     = null
  description = <<EOF
  (Optional) The access block support. If not specified then does not make any changes.
  data_lens     - (Optional) Allow access for Yandex DataLens.
  web_sql       - (Optional) Allows access for SQL queries in the management console.
  data_transfer - (Optional) Allow access for DataTransfer
  access = {
    web_sql = true
  }
  EOF
}

variable "performance_diagnostics" {
  type = object({
    enabled                      = optional(bool)
    sessions_sampling_interval   = optional(number)
    statements_sampling_interval = optional(number)
  })
  default     = null
  description = <<EOF
  (Optional) The performance_diagnostics block supports.
  enabled                      - Enable performance diagnostics
  sessions_sampling_interval   - Interval (in seconds) for my_stat_activity sampling Acceptable values are 1 to 86400, inclusive.
  statements_sampling_interval - Interval (in seconds) for my_stat_statements sampling Acceptable values are 1 to 86400, inclusive.

  performance_diagnostics = {
    enabled                      = true
    sessions_sampling_interval   = 30
    statements_sampling_interval = 90
  }
  EOF
  validation {
    condition = (
      var.performance_diagnostics == null ? true : (
        (var.performance_diagnostics.sessions_sampling_interval == null ? true : (var.performance_diagnostics.sessions_sampling_interval >= 1 && var.performance_diagnostics.sessions_sampling_interval <= 86400)) &&
        (var.performance_diagnostics.statements_sampling_interval == null ? true : (var.performance_diagnostics.statements_sampling_interval >= 1 && var.performance_diagnostics.statements_sampling_interval <= 86400))
      )
    )
    error_message = "Invalid performance diagnostics intervals. Both sessions_sampling_interval and statements_sampling_interval must be between 1 and 86400 seconds."
  }
}

variable "allow_ingress_v4_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "(Optional) The allowed list of addresses for accessing the database on port 3306. Default `[ \"0.0.0.0\"/0 ]`"

}

variable "attach_security_group_ids" {
  type        = list(string)
  default     = null
  description = "(Optional) Attach an additional security group."
}


variable "timeouts" {
  description = "Timeout settings for cluster operations"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "disk_encryption_key_id" {
  type        = string
  default     = null
  description = "(Optional) ID of the symmetric encryption key used to encrypt the disk of the cluster."
}

variable "host_group_ids" {
  type        = list(string)
  default     = null
  description = "(Optional) A list of host group IDs to place VMs of the cluster on."
}

variable "disk_size_autoscaling" {
  type = object({
    disk_size_limit           = number
    emergency_usage_threshold = optional(number)
    planned_usage_threshold   = optional(number)
  })
  default     = null
  description = <<EOF
  (Optional) Cluster disk size autoscaling settings.
  disk_size_limit           - (Required) Limit of disk size after autoscaling (GiB).
  emergency_usage_threshold - (Optional) Immediate autoscaling disk usage threshold (percent).
  planned_usage_threshold   - (Optional) Maintenance window autoscaling disk usage threshold (percent).
  EOF
  validation {
    condition = (
      var.disk_size_autoscaling == null ? true : (
        var.disk_size_autoscaling.disk_size_limit >= 10 && var.disk_size_autoscaling.disk_size_limit <= 6144 &&
        (var.disk_size_autoscaling.emergency_usage_threshold == null ? true : (var.disk_size_autoscaling.emergency_usage_threshold >= 0 && var.disk_size_autoscaling.emergency_usage_threshold <= 100)) &&
        (var.disk_size_autoscaling.planned_usage_threshold == null ? true : (var.disk_size_autoscaling.planned_usage_threshold >= 0 && var.disk_size_autoscaling.planned_usage_threshold <= 100))
      )
    )
    error_message = "Invalid disk size autoscaling settings. disk_size_limit must be between 10-6144 GiB, thresholds must be between 0-100%."
  }
}

variable "database_name" {
  type        = string
  description = "(Required) Name of the MySQL database"
  default     = "default_db"
}

variable "user_name" {
  type        = string
  description = "(Required) Name of the MySQL user"
  default     = "default_user"
}

variable "user_password" {
  type        = string
  description = "(Required) Password for the MySQL user"
  sensitive   = true
}

variable "user_roles" {
  type        = list(string)
  description = "(Optional) Roles for the MySQL user"
  default     = ["ALL"]
}
