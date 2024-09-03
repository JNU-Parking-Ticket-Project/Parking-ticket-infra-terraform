resource "aws_elasticache_cluster" "tfer--jnu-parking-redis-prod-001" {
  auto_minor_version_upgrade = "true"
  availability_zone          = "ap-northeast-2a"
  cluster_id                 = "jnu-parking-redis-prod-001"
  ip_discovery               = "ipv4"
  network_type               = "ipv4"
  replication_group_id       = "${aws_elasticache_replication_group.tfer--jnu-parking-redis-prod.replication_group_id}"
  transit_encryption_enabled = "false"
}
