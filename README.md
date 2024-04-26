# Yandex Cloud MySQL Terraform module

Terraform module which creates Yandex Cloud **Managed Service for MySQL** resources.

## Example

```
# Full example
module "mysql" {
  source           = "../../modules/mysql"
  network_id       = module.vpc.vpc_id
  ha               = true
  count_ha         = 3
  subnet_zones     = module.vpc.private_zones
  subnet_id        = module.vpc.private_subnets_id
  assign_public_ip = false
  name             = "cluster-mysql"
  environment      = "PRESTABLE"
  version_sql      = "8.0"

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
  }

  maintenance_window = {
    type = "ANYTIME"
  }

  backup_window_start = {
    hours   = 23
    minutes = 59
  }

  access = {
    web_sql = true
  }

  performance_diagnostics = {
    enabled                      = true
    sessions_sampling_interval   = 30
    statements_sampling_interval = 90
  }

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
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.110, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.110, < 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_mdb_mysql_cluster.mysql](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster) | resource |
| [yandex_vpc_security_group.mysql-sg](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_security_group) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access"></a> [access](#input\_access) | (Optional) The access block support. If not specified then does not make any changes.<br>  data\_lens     - (Optional) Allow access for Yandex DataLens.<br>  web\_sql       - (Optional) Allows access for SQL queries in the management console.<br>  data\_transfer - (Optional) Allow access for DataTransfer<br>  access = {<br>    web\_sql = true<br>  } | <pre>object({<br>    data_lens     = optional(bool)<br>    web_sql       = optional(bool)<br>    data_transfer = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_allow_ingress_v4_cidr_blocks"></a> [allow\_ingress\_v4\_cidr\_blocks](#input\_allow\_ingress\_v4\_cidr\_blocks) | (Optional) The allowed list of addresses for accessing the database on port 3306. Default `[ "0.0.0.0"/0 ]` | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | (Optional) Sets whether the host should get a public IP address. It can be changed on the fly only when name is set. | `bool` | `false` | no |
| <a name="input_attach_security_group_ids"></a> [attach\_security\_group\_ids](#input\_attach\_security\_group\_ids) | (Optional) Attach an additional security group. | `list(string)` | `null` | no |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) The period in days during which backups are stored. | `number` | `null` | no |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, in the UTC. | <pre>object({<br>    hours   = optional(number)<br>    minutes = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_count_ha"></a> [count\_ha](#input\_count\_ha) | (Optional) Number of hosts in a high availability cluster | `number` | `3` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) Protection against cluster deletion | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description of the MySQL cluster. | `string` | `"terraform-created"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | (Optional) Volume of the storage available to a MySQL host, in gigabytes. Default '10'. https://yandex.cloud/ru/docs/managed-mysql/concepts/limits | `number` | `10` | no |
| <a name="input_disk_type_id"></a> [disk\_type\_id](#input\_disk\_type\_id) | (Optional) Type of the storage of MySQL hosts. Default 'network-ssd' | `string` | `"network-ssd"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Deployment environment of the MySQL cluster | `string` | `"PRODUCTION"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id | `string` | `null` | no |
| <a name="input_ha"></a> [ha](#input\_ha) | (Optional) High availability cluster? | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) Set of key/value label pairs to assign. | `map(string)` | <pre>{<br>  "created_by": "terraform_mysql_module"<br>}</pre> | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Time to start the daily backup, in the UTC. | <pre>object({<br>    type = optional(string)<br>    day  = optional(string)<br>    hour = optional(number)<br>  })</pre> | <pre>{<br>  "day": null,<br>  "hour": null,<br>  "type": "ANYTIME"<br>}</pre> | no |
| <a name="input_mysql_config"></a> [mysql\_config](#input\_mysql\_config) | (Optional) MySQL cluster config. Detail info in https://terraform-provider.yandexcloud.net/Resources/mdb_mysql_cluster.html#mysql-config | <pre>object({<br>    sql_mode                      = optional(string)<br>    max_connections               = optional(number)<br>    default_authentication_plugin = optional(string)<br>    innodb_print_all_deadlocks    = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the MySQL cluster. Provided by the client when the cluster is created. | `string` | `"cluster-mysql"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | (Required) ID of the network, to which the MySQL cluster belongs. | `string` | n/a | yes |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) The performance\_diagnostics block supports.<br>  enabled                      - Enable performance diagnostics<br>  sessions\_sampling\_interval   - Interval (in seconds) for my\_stat\_activity sampling Acceptable values are 1 to 86400, inclusive.<br>  statements\_sampling\_interval - Interval (in seconds) for my\_stat\_statements sampling Acceptable values are 1 to 86400, inclusive.<br><br>  performance\_diagnostics = {<br>    enabled                      = true<br>    sessions\_sampling\_interval   = 30<br>    statements\_sampling\_interval = 90<br>  } | <pre>object({<br>    enabled                      = optional(bool)<br>    sessions_sampling_interval   = optional(number)<br>    statements_sampling_interval = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_resource_preset_id"></a> [resource\_preset\_id](#input\_resource\_preset\_id) | (Optional) The ID of the preset for computational resources available to a MySQL host. Default 's1.micro' | `string` | `"s1.micro"` | no |
| <a name="input_restore"></a> [restore](#input\_restore) | (Optional) Time to start the daily backup, in the UTC. The structure is documented below.<br>  backup\_id - (Required, ForceNew) Backup ID. The cluster will be created from the specified backup.<br>  time      - (Optional, ForceNew) Timestamp of the moment to which the MySQL cluster should be restored. (Format: "2006-01-02T15:04:05" - UTC). When not set, current time is used.<br>  restore = {<br>    backup\_id = "c9qj2tns23432471d9qha:stream\_20210122T141717Z"<br>    time      = "2021-01-23T15:04:05"<br>  } | <pre>object({<br>    backup_id = string<br>    time      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Optional) The ID of the subnets, to which the host belongs. The subnet must be a part of the network to which the cluster belongs. | `list(string)` | `null` | no |
| <a name="input_subnet_zones"></a> [subnet\_zones](#input\_subnet\_zones) | (Optional) Zones name of the network, to which the MySQL cluster belongs. | `list(string)` | <pre>[<br>  "ru-central1-a"<br>]</pre> | no |
| <a name="input_version_sql"></a> [version\_sql](#input\_version\_sql) | (Optional) Version of the MySQL cluster. Default '8.0' | `string` | `"8.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_info"></a> [db\_info](#output\_db\_info) | Full information about the cluster |
| <a name="output_hosts_fqdn"></a> [hosts\_fqdn](#output\_hosts\_fqdn) | List of server FQDN |
| <a name="output_hosts_name"></a> [hosts\_name](#output\_hosts\_name) | List of server names |
| <a name="output_id"></a> [id](#output\_id) | cluster ID |
| <a name="output_name"></a> [name](#output\_name) | cluster name |
