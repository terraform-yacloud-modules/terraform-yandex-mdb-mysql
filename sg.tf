resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "${var.name}-sg"
  network_id = var.network_id

  egress {
    protocol       = "ANY"
    description    = "Allow ANY output traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535

  }
  ingress {
    description    = "MySQL (TCP:3306)"
    port           = 3306
    protocol       = "TCP"
    v4_cidr_blocks = var.allow_ingress_v4_cidr_blocks
  }
}
