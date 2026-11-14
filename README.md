# Yandex Cloud MySQL Terraform module

Terraform module which creates Yandex Cloud **Managed Service for MySQL** resources.

## Example

```
# Full example
module "mysql" {
  source           = "../../modules/mysql"
  network_id       = module.vpc.vpc_id
  subnet_zones     = module.vpc.private_zones
  subnet_id        = module.vpc.private_subnets_id
  name             = "cluster-mysql"
  environment      = "PRESTABLE"
  version_sql      = "8.0"

  # Explicit host layout: two HA hosts and a cascading read replica
  hosts = [
    {
      zone      = module.vpc.private_zones[0]
      subnet_id = module.vpc.private_subnets_id[0]
      name      = "mysql-primary"
    },
    {
      zone      = module.vpc.private_zones[0]
      subnet_id = module.vpc.private_subnets_id[0]
      name      = "mysql-secondary"
    },
    {
      zone                    = module.vpc.private_zones[0]
      subnet_id               = module.vpc.private_subnets_id[0]
      name                    = "mysql-replica"
      replication_source_name = "mysql-primary"
    },
  ]

  resource_preset_id = "b1.medium"
  disk_type_id       = "network-ssd"
  disk_size          = 10

  labels = {
    created_by = "terraform_mysql_module"
  }

  attach_security_group_ids = [module.sg_private.id]

  deletion_protection = false

  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
    # Any other MySQL parameter supported by the provider can be passed through
    innodb_buffer_pool_size = "134217728"
  }

  maintenance_window = {
    type = "ANYTIME"
  }

  backup_window_start = {
    hours   = 23
    minutes = 59
  }

  access = {
    web_sql      = true
    yandex_query = true
  }

  performance_diagnostics = {
    enabled                      = true
    sessions_sampling_interval   = 30
    statements_sampling_interval = 90
  }

  databases = ["app_db", "analytics_db"]

  users = [
    {
      name               = "app_user"
      password           = "app-user-password-123"
      roles              = ["ALL"]
      global_permissions = ["PROCESS"]
      connection_limits = {
        max_user_connections = 50
      }
    },
    {
      name              = "analytics_reader"
      generate_password = true
      permissions = [
        {
          database_name = "analytics_db"
          roles         = ["SELECT"]
        }
      ]
    },
  ]

}

# Minimal example
module "mysql" {
  source           = "../../modules/mysql"
  network_id       = module.vpc.vpc_id
  subnet_zones     = module.vpc.private_zones
  name             = "cluster-mysql"
}
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.110, < 1.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.110, < 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [yandex_mdb_mysql_cluster.mysql](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster) | resource |
| [yandex_mdb_mysql_database.additional](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_database) | resource |
| [yandex_mdb_mysql_database.mysql_db](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_database) | resource |
| [yandex_mdb_mysql_user.additional](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_user) | resource |
| [yandex_mdb_mysql_user.mysql_user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_user) | resource |
| [yandex_vpc_security_group.mysql](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_security_group) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access"></a> [access](#input\_access) | (Optional) The access block support. If not specified then does not make any changes.<br/>  data\_lens     - (Optional) Allow access for Yandex DataLens.<br/>  web\_sql       - (Optional) Allows access for SQL queries in the management console.<br/>  data\_transfer - (Optional) Allow access for DataTransfer<br/>  yandex\_query  - (Optional) Allow access for Yandex Query.<br/>  access = {<br/>    web\_sql = true<br/>  } | <pre>object({<br/>    data_lens     = optional(bool)<br/>    web_sql       = optional(bool)<br/>    data_transfer = optional(bool)<br/>    yandex_query  = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_allow_ingress_v4_cidr_blocks"></a> [allow\_ingress\_v4\_cidr\_blocks](#input\_allow\_ingress\_v4\_cidr\_blocks) | (Optional) The allowed list of addresses for accessing the database on port 3306. Default `[ "0.0.0.0"/0 ]` | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | (Optional) Sets whether the host should get a public IP address. It can be changed on the fly only when name is set. | `bool` | `false` | no |
| <a name="input_attach_security_group_ids"></a> [attach\_security\_group\_ids](#input\_attach\_security\_group\_ids) | (Optional) Attach an additional security group. | `list(string)` | `null` | no |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) The period in days during which backups are stored. | `number` | `null` | no |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, in the UTC. | <pre>object({<br/>    hours   = optional(number)<br/>    minutes = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_count_ha"></a> [count\_ha](#input\_count\_ha) | (Optional) Number of hosts in a high availability cluster | `number` | `3` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Optional) Name of the single MySQL database. Ignored when `databases` is set. | `string` | `"default_db"` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | (Optional) List of MySQL databases to create. Takes precedence over `database_name`. The first database is used as the default one for user permissions. | `list(string)` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) Protection against cluster deletion | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description of the MySQL cluster. | `string` | `"terraform-created"` | no |
| <a name="input_disk_encryption_key_id"></a> [disk\_encryption\_key\_id](#input\_disk\_encryption\_key\_id) | (Optional) ID of the symmetric encryption key used to encrypt the disk of the cluster. | `string` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | (Optional) Volume of the storage available to a MySQL host, in gigabytes. Default '10'. https://yandex.cloud/ru/docs/managed-mysql/concepts/limits | `number` | `10` | no |
| <a name="input_disk_size_autoscaling"></a> [disk\_size\_autoscaling](#input\_disk\_size\_autoscaling) | (Optional) Cluster disk size autoscaling settings.<br/>  disk\_size\_limit           - (Required) Limit of disk size after autoscaling (GiB).<br/>  emergency\_usage\_threshold - (Optional) Immediate autoscaling disk usage threshold (percent).<br/>  planned\_usage\_threshold   - (Optional) Maintenance window autoscaling disk usage threshold (percent). | <pre>object({<br/>    disk_size_limit           = number<br/>    emergency_usage_threshold = optional(number)<br/>    planned_usage_threshold   = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_disk_type_id"></a> [disk\_type\_id](#input\_disk\_type\_id) | (Optional) Type of the storage of MySQL hosts. Default 'network-ssd' | `string` | `"network-ssd"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Deployment environment of the MySQL cluster | `string` | `"PRODUCTION"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id | `string` | `null` | no |
| <a name="input_ha"></a> [ha](#input\_ha) | (Optional) High availability cluster? | `bool` | `false` | no |
| <a name="input_host_group_ids"></a> [host\_group\_ids](#input\_host\_group\_ids) | (Optional) A list of host group IDs to place VMs of the cluster on. | `list(string)` | `null` | no |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | (Optional) Explicit list of MySQL cluster hosts. When set, it replaces the automatic layout built from `ha`, `count_ha`, `subnet_zones`, `subnet_id` and `assign_public_ip`.<br/>  Each host supports:<br/>  zone                    - (Required) Availability zone of the host.<br/>  subnet\_id               - (Required) ID of the subnet, to which the host belongs.<br/>  name                    - (Optional) Host name. Must be set for all hosts or left unset for all hosts.<br/>  priority                - (Optional) Host master promotion priority, 0-100. Default 0.<br/>  backup\_priority         - (Optional) Host backup priority, 0-100. Default 0.<br/>  assign\_public\_ip        - (Optional) Assign a public IP address to the host. Default false.<br/>  replication\_source\_name - (Optional) Name of the host to replicate from. Makes the host a read replica and requires `name`. | <pre>list(object({<br/>    zone                    = string<br/>    subnet_id               = string<br/>    name                    = optional(string)<br/>    priority                = optional(number, 0)<br/>    backup_priority         = optional(number, 0)<br/>    assign_public_ip        = optional(bool, false)<br/>    replication_source_name = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) Set of key/value label pairs to assign. | `map(string)` | <pre>{<br/>  "created_by": "terraform_mysql_module"<br/>}</pre> | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Time to start the daily backup, in the UTC. | <pre>object({<br/>    type = optional(string)<br/>    day  = optional(string)<br/>    hour = optional(number)<br/>  })</pre> | <pre>{<br/>  "day": null,<br/>  "hour": null,<br/>  "type": "ANYTIME"<br/>}</pre> | no |
| <a name="input_mysql_config"></a> [mysql\_config](#input\_mysql\_config) | (Optional) MySQL cluster config. Any MySQL configuration parameter supported by the provider can be passed as a key/value pair, e.g. `innodb_buffer_pool_size = "134217728"`.<br/>  Well-known parameters (`sql_mode`, `max_connections`, `default_authentication_plugin`, `innodb_print_all_deadlocks`) are filled with module defaults when omitted.<br/>  Detail info in https://terraform-provider.yandexcloud.net/Resources/mdb_mysql_cluster.html#mysql-config | `map(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the MySQL cluster. Provided by the client when the cluster is created. | `string` | `"cluster-mysql"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | (Required) ID of the network, to which the MySQL cluster belongs. | `string` | n/a | yes |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) The performance\_diagnostics block supports.<br/>  enabled                      - Enable performance diagnostics<br/>  sessions\_sampling\_interval   - Interval (in seconds) for my\_stat\_activity sampling Acceptable values are 1 to 86400, inclusive.<br/>  statements\_sampling\_interval - Interval (in seconds) for my\_stat\_statements sampling Acceptable values are 1 to 86400, inclusive.<br/><br/>  performance\_diagnostics = {<br/>    enabled                      = true<br/>    sessions\_sampling\_interval   = 30<br/>    statements\_sampling\_interval = 90<br/>  } | <pre>object({<br/>    enabled                      = optional(bool)<br/>    sessions_sampling_interval   = optional(number)<br/>    statements_sampling_interval = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_resource_preset_id"></a> [resource\_preset\_id](#input\_resource\_preset\_id) | (Optional) The ID of the preset for computational resources available to a MySQL host. Default 's1.micro' | `string` | `"s1.micro"` | no |
| <a name="input_restore"></a> [restore](#input\_restore) | (Optional) The cluster will be created from the specified backup or source cluster. The structure is documented below.<br/>  backup\_id         - (Optional, ForceNew) Backup ID. The cluster will be created from the specified backup.<br/>  source\_cluster\_id - (Optional, ForceNew) ID of the source cluster to restore from.<br/>  time              - (Optional, ForceNew) Timestamp of the moment to which the MySQL cluster should be restored. (Format: "2006-01-02T15:04:05" - UTC). When not set, current time is used.<br/>  restore = {<br/>    backup\_id = "c9qj2tns23432471d9qha:stream\_20210122T141717Z"<br/>    time      = "2021-01-23T15:04:05"<br/>  }<br/>  At least one of `backup_id` or `source_cluster_id` must be set. | <pre>object({<br/>    backup_id         = optional(string)<br/>    source_cluster_id = optional(string)<br/>    time              = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Optional) The ID of the subnets, to which the host belongs. The subnet must be a part of the network to which the cluster belongs. | `list(string)` | `null` | no |
| <a name="input_subnet_zones"></a> [subnet\_zones](#input\_subnet\_zones) | (Optional) Zones name of the network, to which the MySQL cluster belongs. | `list(string)` | <pre>[<br/>  "ru-central1-a"<br/>]</pre> | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout settings for cluster operations | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | (Optional) Name of the single MySQL user. Ignored when `users` is set. | `string` | `"default_user"` | no |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | (Optional) Password for the single MySQL user. Ignored when `users` is set. | `string` | `null` | no |
| <a name="input_user_roles"></a> [user\_roles](#input\_user\_roles) | (Optional) Roles for the single MySQL user. Ignored when `users` is set. | `list(string)` | <pre>[<br/>  "ALL"<br/>]</pre> | no |
| <a name="input_users"></a> [users](#input\_users) | (Optional) List of MySQL users to create. Takes precedence over the legacy `user_name`, `user_password` and `user_roles` variables.<br/>  Each user supports:<br/>  name                  - (Required) Name of the user.<br/>  password              - (Optional) Password of the user. Required unless `generate_password = true`.<br/>  generate\_password     - (Optional) Generate a random password for the user.<br/>  roles                 - (Optional) Roles granted on the first database when `permissions` is not set. Default `["ALL"]`.<br/>  permissions           - (Optional) List of `{ database_name, roles }` objects to grant permissions on several databases.<br/>  authentication\_plugin - (Optional) Authentication plugin, e.g. `MYSQL_NATIVE_PASSWORD`.<br/>  global\_permissions    - (Optional) List of global permissions, e.g. `["PROCESS"]`.<br/>  connection\_limits     - (Optional) Per-user connection limits: `max_connections_per_hour`, `max_questions_per_hour`, `max_updates_per_hour`, `max_user_connections`. | <pre>list(object({<br/>    name              = string<br/>    password          = optional(string)<br/>    generate_password = optional(bool, false)<br/>    roles             = optional(list(string), ["ALL"])<br/>    permissions = optional(list(object({<br/>      database_name = string<br/>      roles         = optional(list(string), ["ALL"])<br/>    })))<br/>    authentication_plugin = optional(string)<br/>    global_permissions    = optional(list(string))<br/>    connection_limits = optional(object({<br/>      max_connections_per_hour = optional(number)<br/>      max_questions_per_hour   = optional(number)<br/>      max_updates_per_hour     = optional(number)<br/>      max_user_connections     = optional(number)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_version_sql"></a> [version\_sql](#input\_version\_sql) | (Optional) Version of the MySQL cluster. Default '8.0' | `string` | `"8.0"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_access"></a> [access](#output\_access) | The access settings of the MySQL cluster |
| <a name="output_backup_retain_period_days"></a> [backup\_retain\_period\_days](#output\_backup\_retain\_period\_days) | The number of days to retain backups for the MySQL cluster |
| <a name="output_backup_window_start"></a> [backup\_window\_start](#output\_backup\_window\_start) | The backup window start time of the MySQL cluster |
| <a name="output_database_names"></a> [database\_names](#output\_database\_names) | List of database names created in the MySQL cluster |
| <a name="output_disk_encryption_key_id"></a> [disk\_encryption\_key\_id](#output\_disk\_encryption\_key\_id) | The ID of the disk encryption key used for the MySQL cluster |
| <a name="output_disk_size_autoscaling"></a> [disk\_size\_autoscaling](#output\_disk\_size\_autoscaling) | The disk size autoscaling settings of the MySQL cluster |
| <a name="output_environment"></a> [environment](#output\_environment) | The deployment environment of the MySQL cluster |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The fully qualified domain name of the MySQL cluster |
| <a name="output_host_details"></a> [host\_details](#output\_host\_details) | List of MySQL cluster hosts with names, zones and replication sources |
| <a name="output_host_group_ids"></a> [host\_group\_ids](#output\_host\_group\_ids) | The list of host group IDs used for the MySQL cluster |
| <a name="output_hosts"></a> [hosts](#output\_hosts) | List of host FQDNs in the MySQL cluster |
| <a name="output_id"></a> [id](#output\_id) | The ID of the MySQL cluster |
| <a name="output_maintenance_window"></a> [maintenance\_window](#output\_maintenance\_window) | The maintenance window settings of the MySQL cluster |
| <a name="output_name"></a> [name](#output\_name) | The name of the MySQL cluster |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | The ID of the network to which the MySQL cluster belongs |
| <a name="output_performance_diagnostics"></a> [performance\_diagnostics](#output\_performance\_diagnostics) | The performance diagnostics settings of the MySQL cluster |
| <a name="output_resources"></a> [resources](#output\_resources) | The resources allocated to the MySQL cluster |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group assigned to the MySQL cluster |
| <a name="output_user_names"></a> [user\_names](#output\_user\_names) | List of user names created in the MySQL cluster |
| <a name="output_version"></a> [version](#output\_version) | The version of the MySQL cluster |
