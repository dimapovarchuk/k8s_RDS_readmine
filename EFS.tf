

/*
resource "aws_efs_file_system" "common_file_storage" {
  tags = {
    Name = "Redmine file"
  }
}

resource "aws_efs_mount_target" "redmine_target" {
  file_system_id  = aws_efs_file_system.common_file_storage.id
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.main_firewall.id]
}

resource "aws_efs_mount_target" "redmine_target1" {
  file_system_id  = aws_efs_file_system.common_file_storage.id
  subnet_id       = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.main_firewall.id]
}
*/
/*

resource "aws_efs_access_point" "efs_efs_access" {
  file_system_id = aws_efs_file_system.common_file_storage.id
}




resource "aws_security_group" "file_store_firewall" {
  vpc_id = module.vpc.vpc_id
  name        = "file_store_firewall"
  description = "Allow inbound traffic in file store"
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Redmine file store firewall",
    Project= "Redmine"
  }
}
*/


/*


resource "kubernetes_persistent_volume" "redmine-pv" {
  metadata {
    name = "redmine-pv"
  }
  spec {
    storage_class_name = "efs"
    volume_mode   = "Filesystem"
    access_modes = [
      "ReadWriteMany"
    ]
    capacity = {
      storage = "1Gi"
    }
    mount_options = [
      "hard","nfsvers=4.1","rsize=1048576","wsize=1048576","timeo=600","retrans=2","noresvport"
    ]

    persistent_volume_source {
      nfs {
        path   = "/"
        server = aws_efs_file_system.common_file_storage.dns_name
      }
    }
  }
}
*/

/*resource "kubernetes_storage_class" "redmine_storage_class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
}*/

/*resource "kubernetes_persistent_volume_claim" "redmine_pvc" {

  metadata {
    name = "redmine-pvc"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "efs"
    resources {
      requests = {
        storage="1Gi"
      }
    }
    volume_name = "redmine-pv"
  }
}*/











//================================================================


/*
module "eks-efs-csi-driver" {
  depends_on = [helm_release.nginx_ingress]
  source  = "DNXLabs/eks-efs-csi-driver/aws"
  version = "0.1.2"

  # insert the 1 required variable here
}*/

/*
resource "kubernetes_persistent_volume" "redmine-pv" {
  metadata {
    name = "redmine-pv"
  }
  spec {
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "aws-efs"
    access_modes = [
      "ReadWriteMany"
    ]
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.common_file_storage.id
      }
    }
  }
}*/

/*resource "kubernetes_storage_class" "redmine_storage_class" {
  metadata {
    name = "aws-efs"
  }
  storage_provisioner = "efs.csi.aws.com"
}

resource "kubernetes_persistent_volume_claim" "redmine_pvc" {
depends_on = [kubernetes_persistent_volume.redmine-pv]
  metadata {
    name = "redmine-pvc"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "aws-efs"
    resources {
      requests = {
        storage="1Gi"
      }
    }
  }
}*/

/*resource "kubernetes_csi_driver" "example" {
  metadata {
    name = "efs.csi.aws.com"
  }

  spec {
    attach_required        = false
  }
}*/
