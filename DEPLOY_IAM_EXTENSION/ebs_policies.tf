# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

locals {
  mgmt_admin_group_name     = "${var.ebs_workload_prefix}-${var.mgmt_admin_group_name}"
  category_admin_group_name = coalesce(var.category_admin_group_name, "${var.ebs_workload_prefix}-${var.ebs_category}-admin-group")

  mgmt_parent_compartment_ocid     = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_mgmt_parent_compartment_ocid
  category_parent_compartment_ocid = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_category_parent_compartment_ocid

  mgmt_root_policies = concat(
    var.ebs_compartment_structure == "Single Compartment Deployment" ? [
      "allow group ${local.mgmt_admin_group_name} to read app-catalog-listing in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read instance-images in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read repos in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage file-family in compartment id ${local.mgmt_parent_compartment_ocid}",
      ] : [
      "allow group ${local.mgmt_admin_group_name} to read app-catalog-listing in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read instance-images in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read repos in compartment id ${local.mgmt_parent_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage file-family in compartment id ${local.mgmt_parent_compartment_ocid}",
      ], [
      "allow group ${local.mgmt_admin_group_name} to manage app-catalog-listing in tenancy",
      "allow group ${local.mgmt_admin_group_name} to inspect buckets in tenancy",
      "allow group ${local.mgmt_admin_group_name} to use domains in tenancy",
    ],
    # mgmt network admin policies
    [
      "allow group ${local.mgmt_admin_group_name} to read virtual-network-family in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use vnics in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage private-ips in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use subnets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use network-security-groups in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage export-sets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use mount-targets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use file-systems in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use virtual-network-family in compartment id ${var.core_lz_network_compartment_ocid}"
    ],
    # mgmt security admin policies
    [
      "allow group ${local.mgmt_admin_group_name} to read vss-family in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use vaults in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read logging-family in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to use bastion in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage bastion-session in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to inspect keys in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage cloudevents-rules in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage alarms in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to manage metrics in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.mgmt_admin_group_name} to read instance-agent-plugins in compartment id ${var.core_lz_security_compartment_ocid}"
    ]

  )

  mgmt_workload_policies = concat(
    [
      "allow group ${local.mgmt_admin_group_name} to manage load-balancers in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to manage tag-namespaces in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to manage logs in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to manage mount-targets in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to use file-systems in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to use mount-targets in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to use export-sets in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to manage file-systems in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}",
      "allow group ${local.mgmt_admin_group_name} to manage export-sets in compartment ${var.ebs_workload_prefix}-${local.mgmt_compartment_name}"
    ]
  )



  category_root_policies = concat(
    var.ebs_compartment_structure == "Single Compartment Deployment" ? [
      "allow group ${local.category_admin_group_name} to read app-catalog-listing in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read instance-images in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read repos in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage file-family in compartment id ${local.category_parent_compartment_ocid}",
      ] : [
      "allow group ${local.category_admin_group_name} to read app-catalog-listing in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read instance-images in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read repos in compartment id ${local.category_parent_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage file-family in compartment id ${local.category_parent_compartment_ocid}",
      ], [
      "allow group ${local.category_admin_group_name} to manage app-catalog-listing in tenancy",
      "allow group ${local.category_admin_group_name} to inspect buckets in tenancy",
      "allow group ${local.category_admin_group_name} to use domains in tenancy",
      "allow service objectstorage-${var.region} to manage object-family in tenancy",
    ],
    # category network admin policies 
    [
      "allow group ${local.category_admin_group_name} to read virtual-network-family in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use vnics in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage private-ips in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use subnets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use network-security-groups in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage export-sets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use mount-targets in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use file-systems in compartment id ${var.core_lz_network_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use virtual-network-family in compartment id ${var.core_lz_network_compartment_ocid}"
    ],
    # category security admin policies
    [
      "allow group ${local.category_admin_group_name} to read vss-family in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use vaults in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read logging-family in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to use bastion in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage bastion-session in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to inspect keys in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage cloudevents-rules in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage alarms in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to manage metrics in compartment id ${var.core_lz_security_compartment_ocid}",
      "allow group ${local.category_admin_group_name} to read instance-agent-plugins in compartment id ${var.core_lz_security_compartment_ocid}"
    ]
  )

  category_workload_policies = concat(
    [
      "allow group ${local.category_admin_group_name} to manage database-family in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage tag-namespaces in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage logs in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage mount-targets in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to use file-systems in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to use mount-targets in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to use export-sets in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage objects in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage buckets in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to use tag-namespaces in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage tag-namespaces in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage file-systems in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage export-sets in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow group ${local.category_admin_group_name} to manage load-balancers in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
      "allow service objectstorage-${var.region} to manage object-family in compartment ${var.ebs_workload_prefix}-${local.category_compartment_name}",
    ]
  )

}


module "iam_ebs_policies_mgmt" {
  depends_on   = [module.iam_compartment_mgmt]
  count        = var.deploy_ebs_mgmt ? 1 : 0
  source       = "./module/iam_generic_workload"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region


  parent_compartment_ocid    = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_mgmt_parent_compartment_ocid
  use_custom_identity_domain = false

  deploy_workload_compartment = false
  deploy_default_groups       = true
  deploy_root_policies        = true
  deploy_wkld_policies        = true

  service_label          = var.ebs_workload_prefix
  wkld_admin_policy_name = "${var.ebs_workload_prefix}-mgmt-admin-policy"
  root_policy_name       = "${var.ebs_workload_prefix}-mgmt-root-policy"

  workload_compartment_name = local.mgmt_compartment_name
  workload_admin_group_name = var.mgmt_admin_group_name

  additional_root_policy_statements       = local.mgmt_root_policies
  additional_wkld_admin_policy_statements = local.mgmt_workload_policies
}



module "iam_ebs_policies_category" {
  depends_on   = [module.iam_compartment_category]
  count        = var.deploy_ebs_category ? 1 : 0
  source       = "./module/iam_generic_workload"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  parent_compartment_ocid    = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_category_parent_compartment_ocid
  use_custom_identity_domain = false

  deploy_workload_compartment = false
  deploy_default_groups       = true
  deploy_root_policies        = true
  deploy_wkld_policies        = true

  service_label          = var.ebs_workload_prefix
  wkld_admin_policy_name = "${var.ebs_workload_prefix}-${var.ebs_category}-admin-policy"
  root_policy_name       = "${var.ebs_workload_prefix}-${var.ebs_category}-root-policy"

  workload_compartment_name = local.category_compartment_name
  workload_admin_group_name = coalesce(var.category_admin_group_name, "${var.ebs_category}-admin-group")

  additional_root_policy_statements       = local.category_root_policies
  additional_wkld_admin_policy_statements = local.category_workload_policies
}
