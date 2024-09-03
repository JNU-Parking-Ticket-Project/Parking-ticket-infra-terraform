resource "aws_elasticache_replication_group" "tfer--jnu-parking-redis-prod" {
  at_rest_encryption_enabled = "false"
  auto_minor_version_upgrade = "true"
  automatic_failover_enabled = "false"
  cluster_mode               = "disabled"
  data_tiering_enabled       = "false"
  description                = " "
  engine                     = "redis"
  engine_version             = "7.1"
  ip_discovery               = "ipv4"
  maintenance_window         = "wed:03:30-wed:04:30"
  multi_az_enabled           = "false"
  network_type               = "ipv4"
  node_type                  = "cache.t4g.micro"
  num_cache_clusters         = "1"
  num_node_groups            = "1"
  parameter_group_name       = "default.redis7"
  port                       = "6379"
  replicas_per_node_group    = "0"
  replication_group_id       = "jnu-parking-redis-prod"
  security_group_ids         = ["sg-014ba12148b7c380d"]
  snapshot_retention_limit   = "0"
  snapshot_window            = "02:00-03:00"
  subnet_group_name          = "quokka-subnet-redis"
  transit_encryption_enabled = "false"
}
