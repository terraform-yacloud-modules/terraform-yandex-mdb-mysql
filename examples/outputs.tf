output "id" {
  description = "The ID of the MySQL cluster"
  value       = module.mysql.id
}

output "name" {
  description = "The name of the MySQL cluster"
  value       = module.mysql.name
}

output "fqdn" {
  description = "The fully qualified domain name of the MySQL cluster"
  value       = module.mysql.fqdn
}

output "hosts" {
  description = "List of host FQDNs in the MySQL cluster"
  value       = module.mysql.hosts
}

output "network_id" {
  description = "The ID of the network to which the MySQL cluster belongs"
  value       = module.mysql.network_id
}

output "security_group_id" {
  description = "The ID of the security group assigned to the MySQL cluster"
  value       = module.mysql.security_group_id
}

output "environment" {
  description = "The deployment environment of the MySQL cluster"
  value       = module.mysql.environment
}

output "version" {
  description = "The version of the MySQL cluster"
  value       = module.mysql.version
}

output "resources" {
  description = "The resources allocated to the MySQL cluster"
  value       = module.mysql.resources
}

output "maintenance_window" {
  description = "The maintenance window settings of the MySQL cluster"
  value       = module.mysql.maintenance_window
}

output "backup_window_start" {
  description = "The backup window start time of the MySQL cluster"
  value       = module.mysql.backup_window_start
}

output "backup_retain_period_days" {
  description = "The number of days to retain backups for the MySQL cluster"
  value       = module.mysql.backup_retain_period_days
}

output "access" {
  description = "The access settings of the MySQL cluster"
  value       = module.mysql.access
}

output "performance_diagnostics" {
  description = "The performance diagnostics settings of the MySQL cluster"
  value       = module.mysql.performance_diagnostics
}
