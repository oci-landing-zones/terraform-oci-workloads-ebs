# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

data "oci_core_vcn" "additional_vcns" {
  vcn_id = var.hub_vcn_ocid
}

data "oci_core_drgs" "drgs" {
  compartment_id = var.core_lz_network_compartment_ocid
}

locals {


  ebs_mgmt_lb_subnet_cidr_block  = var.deploy_management ? coalesce(var.ebs_mgmt_lb_subnet_cidr, cidrsubnet(var.ebs_workload_mgmt_vcn_cidr[0], 2, 0)) : null
  ebs_mgmt_app_subnet_cidr_block = var.deploy_management ? coalesce(var.ebs_mgmt_app_subnet_cidr, cidrsubnet(var.ebs_workload_mgmt_vcn_cidr[0], 2, 1)) : null


  ebs_workload_category_vcn_name = coalesce(var.ebs_workload_category_vcn_name, "ebs-${var.ebs_category}")

  ebs_category_int_lb_subnet_name       = coalesce(var.ebs_category_int_lb_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-int-lb-subnet")
  ebs_category_int_lb_subnet_cidr_block = coalesce(var.ebs_category_int_lb_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 0))

  ebs_category_int_app_subnet_name       = coalesce(var.ebs_category_int_app_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-int-app-subnet")
  ebs_category_int_app_subnet_cidr_block = coalesce(var.ebs_category_int_app_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 1))

  ebs_category_ext_lb_subnet_name       = coalesce(var.ebs_category_ext_lb_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-ext-lb-subnet")
  ebs_category_ext_lb_subnet_cidr_block = coalesce(var.ebs_category_ext_lb_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 2))

  ebs_category_ext_app_subnet_name       = coalesce(var.ebs_category_ext_app_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-ext-app-subnet")
  ebs_category_ext_app_subnet_cidr_block = coalesce(var.ebs_category_ext_app_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 3))

  ebs_category_fss_subnet_name       = coalesce(var.ebs_category_fss_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-fss-subnet")
  ebs_category_fss_subnet_cidr_block = var.enable_file_system_storage == true ? coalesce(var.ebs_category_fss_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 4)) : null

  ebs_category_db_subnet_name       = coalesce(var.ebs_category_db_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-db-subnet")
  ebs_category_db_subnet_cidr_block = coalesce(var.ebs_category_db_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 5))

  ebs_category_db_backup_subnet_name       = coalesce(var.ebs_category_db_backup_subnet_name, "${var.ebs_workload_prefix}-ebs-${var.ebs_category}-db-backup-subnet")
  ebs_category_db_backup_subnet_cidr_block = var.enable_oracle_database_exadb ? coalesce(var.ebs_category_db_backup_subnet_cidr, cidrsubnet(var.ebs_workload_category_vcn_cidr[0], 3, 6)) : null

  hub_vcn_cidr = data.oci_core_vcn.additional_vcns.cidr_block
  hub_drg_ocid = data.oci_core_drgs.drgs.drgs[0].id
}


module "generic_network_extension_mgmt_vcn" {

  count  = var.deploy_management ? 1 : 0
  source = "./module/generic-network-extension"

  // general
  region             = var.region
  tenancy_ocid       = var.tenancy_ocid
  isolated_resources = false # Set to true if the person deploying this network extension is in the Workload Admin group. Set to false if the person deploying this network extension is in the Network Admin group.
  workload_name      = lower("${var.ebs_workload_prefix}-${var.ebs_workload_mgmt_vcn_name}")
  #network_compartment_ocid    = var.mgmt_compartment_ocid
  network_compartment_ocid    = var.core_lz_network_compartment_ocid
  deploy_network_architecture = var.chosen_network_design_options
  deploy_security_lists       = false

  // network
  workload_vcn_cidr_block = var.ebs_workload_mgmt_vcn_cidr[0] # in generic network, workload_vcn_cidr_block is a string, but ebs_workload_mgmt_cidr is a list
  #hub_vcn_cidrs           = var.chosen_network_design_options == "Hub and Spoke" ? [var.ebs_workload_category_vcn_cidr[0]] : null # in generic network, hub_vcn_cidrs is a list, but in ebs hub_vcn_cidr_block is a list

  hub_vcn_cidrs = null

  hub_drg_ocid = local.hub_drg_ocid

  add_lb_subnet       = true
  add_app_subnet      = true
  customize_subnets   = true
  
  lb_subnet_name      = lower("${var.ebs_workload_prefix}-${var.ebs_mgmt_lb_subnet_name}")
  lb_subnet_cidr      = local.ebs_mgmt_lb_subnet_cidr_block
  lb_subnet_name_dns  = "mgmtlbaassubnet"
  
  app_subnet_name     = lower("${var.ebs_workload_prefix}-${var.ebs_mgmt_app_subnet_name}")
  app_subnet_cidr     = local.ebs_mgmt_app_subnet_cidr_block
  app_subnet_name_dns = "mgmtappsubnet"

  # deploy nsgs
  app_nsg_name                     = "${var.ebs_workload_prefix}-ebs-mgmt-app-nsg"
  app_nsg_additional_ingress_rules = local.mgmt_app_nsg_ingress
  app_nsg_additional_egress_rules  = local.mgmt_app_nsg_egress

  lb_nsg_name                     = "${var.ebs_workload_prefix}-ebs-mgmt-lbr-nsg"
  lb_nsg_additional_ingress_rules = local.ebs_wrk_hub_mgmt_lbr_nsg_ingress
  lb_nsg_additional_egress_rules  = local.ebs_wrk_hub_mgmt_lbr_nsg_egress


  additional_nsgs = merge(local.ebs_wrk_hub_lbr_nsg, local.mgmt_lbaas_nsg)


  # VCN Gateways
  internet_gateway_display_name = lower("${var.ebs_workload_prefix}-ebs-mgmt-internet-gateway")

  #enable_nat_gateway = var.enable_mgmt_nat_gateway
  enable_nat_gateway        = true
  nat_gateway_display_name  = lower("${var.ebs_workload_prefix}-ebs-mgmt-nat-gateway")
  nat_gateway_block_traffic = var.mgmt_nat_gateway_block_traffic

  #enable_service_gateway = var.enable_mgmt_service_gateway
  enable_service_gateway       = true
  service_gateway_display_name = lower("${var.ebs_workload_prefix}-ebs-mgmt-service-gateway")
  service_gateway_services     = var.mgmt_service_gateway_services

  # Route Table

  # MGMT LB Route Table
  lb_subnet_allow_public_access = var.chosen_network_design_options == "Standalone" ? true : false
  lb_subnet_additional_route_rules = merge(
    (var.chosen_network_design_options == "Hub and Spoke") ? {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    } : {},
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_ebs_category) ? {
      "ROUTE-TO-EBS-MGMT-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Management VCN."
        destination       = var.ebs_workload_category_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )



  # MGMT APP Route Table
  app_subnet_allow_public_access = var.chosen_network_design_options == "Standalone" ? true : false

  app_subnet_additional_route_rules = merge(
    (var.chosen_network_design_options == "Hub and Spoke") ? {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    } : {},
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    var.add_hub_vcn_route_drg ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR goes to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},

    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_ebs_category) ? {
      "ROUTE-TO-EBS-WRK-MGMT" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to MGMT VCN."
        destination       = var.ebs_workload_category_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )
}

module "generic_network_extension_category_vcn" {
  source = "./module/generic-network-extension"

  count = var.deploy_ebs_category ? 1 : 0

  // general
  region             = var.region
  tenancy_ocid       = var.tenancy_ocid
  isolated_resources = false # Set to true if the person deploying this network extension is in the Workload Admin group. Set to false if the person deploying this network extension is in the Network Admin group.
  workload_name      = lower("${var.ebs_workload_prefix}-${local.ebs_workload_category_vcn_name}")
  #network_compartment_ocid    = var.category_compartment_ocid
  network_compartment_ocid    = var.core_lz_network_compartment_ocid
  deploy_network_architecture = var.chosen_network_design_options

  // network
  workload_vcn_cidr_block = var.ebs_workload_category_vcn_cidr[0]                                                        # in generic network, workload_vcn_cidr_block is a string, but ebs_workload_mgmt_cidr is a list
  hub_vcn_cidrs           = var.chosen_network_design_options == "Hub and Spoke" ? [var.ebs_mgmt_app_subnet_cidr] : null # in generic network, hub_vcn_cidrs is a list, but in ebs hub_vcn_cidr_block is a list


  customize_subnets = true

  // DB Subnet
  add_db_subnet       = true
  db_subnet_name      = lower(local.ebs_category_db_subnet_name)
  db_subnet_cidr      = local.ebs_category_db_subnet_cidr_block
  db_subnet_name_dns  = "${var.ebs_workload_prefix}dbsubnet"

  // DB backup subnet
  add_db_backup_subnet      = var.enable_oracle_database_exadb ? true : false
  db_backup_subnet_name     = var.enable_oracle_database_exadb ? lower(local.ebs_category_db_backup_subnet_name) : null
  db_backup_subnet_cidr     = var.enable_oracle_database_exadb ? local.ebs_category_db_backup_subnet_cidr_block : null
  db_backup_subnet_name_dns = "${var.ebs_workload_prefix}dbbackupsubnet"

  // internal LB
  add_lb_subnet         = true
  lb_subnet_name        = local.ebs_category_int_lb_subnet_name
  lb_subnet_cidr        = local.ebs_category_int_lb_subnet_cidr_block
  lb_subnet_name_dns    = "${var.ebs_workload_prefix}intlbaassubnet"

  // external LB
  add_mgmt_subnet       = var.enable_external_app_lb ? true : false
  mgmt_subnet_name      = var.enable_external_app_lb ? lower(local.ebs_category_ext_lb_subnet_name) : null
  mgmt_subnet_cidr      = var.enable_external_app_lb ? local.ebs_category_ext_lb_subnet_cidr_block : null
  mgmt_subnet_name_dns  = var.enable_external_app_lb ? "${var.ebs_workload_prefix}extlbaassubnet" : null

  // FSS
  add_web_subnet        = var.enable_file_system_storage ? true : false
  web_subnet_name       = var.enable_file_system_storage ? lower(local.ebs_category_fss_subnet_name) : null
  web_subnet_cidr       = var.enable_file_system_storage ? local.ebs_category_fss_subnet_cidr_block : null
  web_subnet_name_dns   = var.enable_file_system_storage ? "${var.ebs_workload_prefix}fsssubnet" : null

  // internal APP
  add_app_subnet        = true
  app_subnet_name       = lower(local.ebs_category_int_app_subnet_name)
  app_subnet_cidr       = local.ebs_category_int_app_subnet_cidr_block
  app_subnet_name_dns   = "${var.ebs_workload_prefix}intappsubnet"

  // external APP
  add_spare_subnet      = var.enable_external_app_lb ? true : false
  spare_subnet_name     = var.enable_external_app_lb ? lower(local.ebs_category_ext_app_subnet_name) : null
  spare_subnet_cidr     = var.enable_external_app_lb ? local.ebs_category_ext_app_subnet_cidr_block : null
  spare_subnet_name_dns = var.enable_external_app_lb ? "${var.ebs_workload_prefix}extappsubnet" : null

  # NSGs
  db_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-db-subnet-nsg")
  db_nsg_additional_ingress_rules = local.cat_db_subnet_nsg_ingress
  db_nsg_additional_egress_rules  = local.cat_db_subnet_nsg_egress

  lb_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-int-lbaas-nsg")
  lb_nsg_additional_ingress_rules = local.cat_int_lbaas_nsg_ingress
  lb_nsg_additional_egress_rules  = local.cat_int_lbaas_nsg_egress

  web_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-fss-subnet-nsg")
  web_nsg_additional_ingress_rules = local.cat_fss_subnet_nsg_ingress
  web_nsg_additional_egress_rules  = local.cat_fss_subnet_nsg_egress

  app_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-int-app-nsg")
  app_nsg_additional_ingress_rules = local.cat_int_app_nsg_ingress
  app_nsg_additional_egress_rules  = local.cat_int_app_nsg_egress

  spare_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-ext-app-nsg")
  spare_nsg_additional_ingress_rules = local.cat_ext_app_nsg_ingress
  spare_nsg_additional_egress_rules  = local.cat_ext_app_nsg_egress

  mgmt_nsg_name                     = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-ext-lbaas-nsg")
  mgmt_nsg_additional_ingress_rules = local.cat_ext_lbaas_nsg_ingress
  mgmt_nsg_additional_egress_rules  = local.cat_ext_lbaas_nsg_egress

  additional_nsgs = local.ebs_wrk_hub_cat_lbr_nsg


  # VCN Gateways
  internet_gateway_display_name = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-internet-gateway")

  enable_nat_gateway        = true
  nat_gateway_display_name  = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-nat-gateway")
  nat_gateway_block_traffic = var.category_nat_gateway_block_traffic

  enable_service_gateway       = true
  service_gateway_display_name = lower("${var.ebs_workload_prefix}-ebs-${var.ebs_category}-service-gateway")
  service_gateway_services     = var.category_service_gateway_services

  ###DB Subnet Route Table

  db_subnet_allow_public_access = false
  db_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )
  ###DB Backup Subnet Route Table

  db_backup_subnet_allow_public_access = false
  db_backup_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )

  ###Internal LB Route Table

  lb_subnet_allow_public_access = false
  lb_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )

  ###External LB Route Table

  mgmt_subnet_allow_public_access = var.chosen_network_design_options == "Standalone" ? true : false
  mgmt_subnet_additional_route_rules = merge(
    (var.chosen_network_design_options == "Hub and Spoke") ? {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    } : {},
    (var.chosen_network_design_options == "Hub and Spoke") ? {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )  
  #FSS Route Table

  web_subnet_allow_public_access = false
  web_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )

  ####Internal APP Route Table

  app_subnet_allow_public_access = false
  app_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )

  ####External APP Route Table

  spare_subnet_allow_public_access = false
  spare_subnet_additional_route_rules = merge(
    {
      "SGW-EBS-RULE" = {
        network_entity_key = "SGW"
        destination        = "all-services"
        destination_type   = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      ROUTE-EBS-NGW = {
        network_entity_key = "NATGW"
        description        = "To Internet."
        destination        = "134.70.0.0/16"
        destination_type   = "CIDR_BLOCK"
      }
    },
    (var.add_hub_vcn_route_drg && var.chosen_network_design_options == "Hub and Spoke") ? {
      "ROUTE-TO-HUB" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Hub CIDR to DRG."
        destination       = local.hub_vcn_cidr
        destination_type  = "CIDR_BLOCK"
      }
    } : {},
    (var.add_hub_vcn_route_drg && (var.chosen_network_design_options == "Hub and Spoke") && var.deploy_management) ? {
      "ROUTE-TO-EBS-APP" = {
        network_entity_id = local.hub_drg_ocid
        description       = "Traffic destined to Category VCN."
        destination       = var.ebs_workload_mgmt_vcn_cidr[0]
        destination_type  = "CIDR_BLOCK"
      }
    } : {}
  )
}

