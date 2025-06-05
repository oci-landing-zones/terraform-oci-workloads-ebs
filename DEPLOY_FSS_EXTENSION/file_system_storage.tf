# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

locals { 

 ebs_category_mount_hostname = coalesce(var.ebs_category_mount_hostname, "${var.ebs_category}-MT")
 ebs_category_mount_target_name = coalesce(var.ebs_category_mount_target_name, "${var.ebs_category}-MNT-TARGET-NAME")
 ebs_category_fss_snapshot_policy_name = coalesce(var.ebs_categort_fss_snapshot_policy_name, "${var.ebs_category}-SNAPSHOT-POLICY")

 storage_configuration = {
   file_storage = {
     file_systems = {
     }
     mount_targets = {
       PROD-MOUNT-TARGET = {
         compartment_id          = var.core_lz_network_cmp_ocid
         subnet_id               = var.ebs_category_fss_subnet_ocid
         mount_target_name       = "${var.ebs_workload_prefix}-${local.ebs_category_mount_target_name}"
         network_security_groups = [var.ebs_category_fss_subnet_nsg_ocid]
         hostname_label          = local.ebs_category_mount_hostname
       },
     }
     snapshot_policies = {
       PROD-SNAPSHOT-POLICY = {
         compartment_id = var.core_lz_network_cmp_ocid
         name           = "${var.ebs_workload_prefix}-${local.ebs_category_fss_snapshot_policy_name}"
         schedules = [
           {
             period = upper(var.ebs_category_fss_snapshot_policy_frequency),
             prefix = lower(var.ebs_category_fss_snapshot_policy_frequency)
           }
         ]
       },
     }
   }
 }
}

module "ebs_file_system_storage" {
  source     = "github.com/oci-landing-zones/terraform-oci-modules-workloads//cis-compute-storage?ref=v0.1.9"
  # depends_on = [module.ebs_workload_compartments]
  providers = {
    oci                                  = oci.home_region
    oci.block_volumes_replication_region = oci.block_volumes_replication_region
  }
  storage_configuration = local.storage_configuration
}
