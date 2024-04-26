output "db_info" {
  value = yandex_mdb_mysql_cluster.mysql
  description = "Full information about the cluster"
}

output "hosts_fqdn" {
  value = [for host in yandex_mdb_mysql_cluster.mysql.host : host.fqdn]
  description = "List of server FQDN"
}

output "hosts_name" {
  value = [for host in yandex_mdb_mysql_cluster.mysql.host : host.name]
  description = "List of server names"
}

output "id" {
  value = yandex_mdb_mysql_cluster.mysql.id
  description = "cluster ID"
}

output "name" {
  value = yandex_mdb_mysql_cluster.mysql.name
  description = "cluster name"
}
