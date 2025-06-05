# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

locals {
  single_cmp = var.ebs_compartment_structure == "Single Compartment Deployment" ? true : false

  mgmt_compartment_name     = var.ebs_mgmt_compartment_name
  category_compartment_name = var.ebs_category_compartment_name != null ? var.ebs_category_compartment_name : "ebs-${var.ebs_category}"
}

module "iam_compartment_workload" {
  count        = local.single_cmp ? 1 : 0
  source       = "./module/iam_generic_workload"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  parent_compartment_ocid = var.ebs_parent_compartment_ocid
  service_label           = var.ebs_workload_prefix

  deploy_workload_compartment = true
  deploy_default_groups       = false
  deploy_root_policies        = false
  deploy_wkld_policies        = false

  workload_compartment_name        = var.ebs_workload_compartment_name
  workload_compartment_description = "EBS Workload Compartment"

  isolate_workload                        = false
  create_workload_network_subcompartment  = false
  create_workload_app_subcompartment      = false
  create_workload_database_subcompartment = false
}

module "iam_compartment_mgmt" {
  depends_on   = [module.iam_compartment_workload]
  count        = var.deploy_ebs_mgmt ? 1 : 0
  source       = "./module/iam_generic_workload"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  parent_compartment_ocid = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_mgmt_parent_compartment_ocid

  service_label = var.ebs_workload_prefix

  deploy_workload_compartment = true
  deploy_default_groups       = false
  deploy_root_policies        = false
  deploy_wkld_policies        = false

  workload_compartment_name        = var.ebs_mgmt_compartment_name
  workload_compartment_description = "EBS Workload Management Compartment"

  isolate_workload                        = false
  create_workload_network_subcompartment  = false
  create_workload_app_subcompartment      = false
  create_workload_database_subcompartment = false
}

module "iam_compartment_category" {
  depends_on   = [module.iam_compartment_workload]
  count        = var.deploy_ebs_category ? 1 : 0
  source       = "./module/iam_generic_workload"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  parent_compartment_ocid = local.single_cmp ? module.iam_compartment_workload[0].compartments["WKL-CMP"].id : var.ebs_category_parent_compartment_ocid

  service_label = var.ebs_workload_prefix

  deploy_workload_compartment = true
  deploy_default_groups       = false
  deploy_root_policies        = false
  deploy_wkld_policies        = false

  workload_compartment_name               = local.category_compartment_name
  workload_compartment_description        = "EBS Workload Category Compartment"
  isolate_workload                        = false
  create_workload_network_subcompartment  = false
  create_workload_app_subcompartment      = false
  create_workload_database_subcompartment = false
}
