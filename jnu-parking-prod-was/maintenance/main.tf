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
}
//////////🚨 IDLE instance types var 🚨////////////
//////////////////////////////////////////////////
// Maintenance 파이플하인에 필요없는 리소스 값들이지만, 휴먼에러가 발생시 인프라가 전부 삭제되는 실수를 방지하기 위해 추가함

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





resource "aws_cloudfront_distribution" "jnu-parking-apply-distribution" {
    origin {
        domain_name = "jnuparking-tmp-page.s3.ap-northeast-2.amazonaws.com"

        origin_id   = "jnuparking-apply-ws-bucket.s3.ap-northeast-2.amazonaws.com"
        origin_access_control_id = "E2HTAXXWC39GOU"
        connection_attempts = 3
        connection_timeout = 10
    }

    aliases = [ "apply.jnu-parking.com" ]
    is_ipv6_enabled = true
    price_class = "PriceClass_200"

    enabled = true

    default_cache_behavior {
        target_origin_id = "jnuparking-apply-ws-bucket.s3.ap-northeast-2.amazonaws.com"

        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
        compress = true
        origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
        response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
        viewer_protocol_policy = "redirect-to-https"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:992382691088:certificate/3015b1b4-fe33-40cb-aa6c-c6e639b09d5b"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }

    custom_error_response {
        error_caching_min_ttl = 10
        error_code           = 403
        response_code        = 200
        response_page_path   = "/index.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code           = 404
        response_code        = 200
        response_page_path   = "/index.html"
    }
}

resource "aws_cloudfront_distribution" "jnu-parking-manager-distribution" {
    origin {
        domain_name = "jnuparking-tmp-page.s3.ap-northeast-2.amazonaws.com"

        origin_access_control_id = "E3LBOQKK107382"
        origin_id                = "jnuparking-manager1-ws-bucket.s3.ap-northeast-2.amazonaws.com"
        connection_attempts      = 3
        connection_timeout       = 10
    }

    aliases = [ "manager.jnu-parking.com" ]
    is_ipv6_enabled = true
    price_class = "PriceClass_200"

    enabled = true

    default_cache_behavior {
        target_origin_id = "jnuparking-manager1-ws-bucket.s3.ap-northeast-2.amazonaws.com"

        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
        compress = true
        origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
        response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
        viewer_protocol_policy = "redirect-to-https"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:992382691088:certificate/3015b1b4-fe33-40cb-aa6c-c6e639b09d5b"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }

    custom_error_response {
        error_caching_min_ttl = 10
        error_code           = 403
        response_code        = 200
        response_page_path   = "/index.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code           = 404
        response_code        = 200
        response_page_path   = "/index.html"
    }
}