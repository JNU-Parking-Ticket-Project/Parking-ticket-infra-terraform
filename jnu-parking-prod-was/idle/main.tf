terraform {
    cloud { 
        organization = "sckwon770" 

        workspaces { 
            name = "jnu-parking" 
        } 
    } 
    
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
  region = "ap-northeast-2"
}

///////////////////////////////////////////////////
//////////🚨 IDLE instance types var 🚨////////////
locals {
    ec2_instance_type = "t3.micro"
    rds_instance_class = "db.t4g.micro"
    redis_instance_type = "cache.t4g.micro"
}
//////////🚨 IDLE instance types var 🚨////////////
//////////////////////////////////////////////////

resource "aws_eip" "was-eip1" {
    instance = aws_instance.jnu-parking-ec2-prod.id
}

resource "aws_instance" "jnu-parking-ec2-prod" {
    availability_zone                    = "ap-northeast-2a"
    ami                                  = "ami-008d41dbe16db6778"

    instance_type                        = local.ec2_instance_type
    key_name                             = "jnu-parking-prod"

    associate_public_ip_address          = true
    subnet_id                            = "subnet-0501252b2d997228c"
    vpc_security_group_ids               = [
        "sg-097820e8f89289808",
    ]
    
    user_data_replace_on_change          = false // true = apply change, destroying and recreating
    disable_api_termination              = false
    ebs_optimized                        = true
    get_password_data                    = false
    hibernation                          = false
    instance_initiated_shutdown_behavior = "stop"
    monitoring                           = false

    placement_partition_number           = 0
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true

    tags                                 = {
        "Name" = "jnu-parking-prod"
    }
    tags_all                             = {
        "Name" = "jnu-parking-prod"
    }
    tenancy                              = "default"
}


resource "aws_db_instance" "jnu-parking-rds-prod" {
    engine                                = "mysql"
    engine_version                        = "8.0.35"
    availability_zone                     = "ap-northeast-2a"
    ca_cert_identifier                    = "rds-ca-rsa2048-g1"

    identifier                            = "jnu-parking-rds-prod"
    username                              = "admin"
    instance_class                        = local.rds_instance_class
    iops                                  = 0
    allocated_storage                     = 32
    max_allocated_storage                 = 1000
    storage_encrypted                     = true
    storage_type                          = "gp2"
    db_subnet_group_name                  = "default-vpc-0e6d600f6ad4ec867"
    vpc_security_group_ids                = [
        "sg-0c79e4a111f6ff607", // JnuParkingProdRDSSG
    ]
    port                                  = 3306
    publicly_accessible                   = true

    backup_retention_period               = 7
    backup_window                         = "17:33-18:03"
    copy_tags_to_snapshot                 = true
    delete_automated_backups              = true
    deletion_protection                   = true
    skip_final_snapshot                   = true
    multi_az                              = false

    enabled_cloudwatch_logs_exports       = [
        "audit",
        "error",
        "general",
        "slowquery",
    ]
    monitoring_interval                   = 60
    monitoring_role_arn                   = "arn:aws:iam::992382691088:role/rds-monitoring-role"
    performance_insights_enabled          = false
    performance_insights_retention_period = 0

    apply_immediately                     = true
    auto_minor_version_upgrade            = true
    customer_owned_ip_enabled             = false
    iam_database_authentication_enabled   = false
    kms_key_id                            = "arn:aws:kms:ap-northeast-2:992382691088:key/639766af-579d-4efd-84e9-dc03fc5e266e"
    license_model                         = "general-public-license"
    option_group_name                     = "default:mysql-8-0"
    parameter_group_name                  = "default.mysql8.0"
    maintenance_window                    = "fri:14:46-fri:15:16"
    tags                                  = {}
    tags_all                              = {}
}

resource "aws_elasticache_replication_group" "jnu-parking-redis-prod" {
    engine                     = "redis"
    engine_version             = "7.1"
    description                = "a shard(single node) with disabled cluster mode"
    
    replication_group_id       = "jnu-parking-redis-prod"
    node_type                  = local.redis_instance_type
    num_cache_clusters         = 1

    parameter_group_name       = "default.redis7"
    port                       = 6379
    subnet_group_name          = "quokka-subnet-redis"
    security_group_ids         = [
        "sg-014ba12148b7c380d",
    ]
    
    apply_immediately          = true
    multi_az_enabled           = false
    at_rest_encryption_enabled = false
    auto_minor_version_upgrade = "true"
    automatic_failover_enabled = false
    data_tiering_enabled       = false
    snapshot_retention_limit   = 0
    snapshot_window            = "02:00-03:00"
    transit_encryption_mode = null
    transit_encryption_enabled = false
    tags                       = {}
    tags_all                   = {}
    user_group_ids             = []
}