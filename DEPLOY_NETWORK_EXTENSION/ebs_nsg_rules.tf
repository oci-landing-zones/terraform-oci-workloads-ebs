# # ###################################################################################################### #
# # Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# # ###################################################################################################### #

locals {

  category_src_subnet_cidr_block = var.deploy_management ? local.ebs_mgmt_app_subnet_cidr_block : var.category_provided_src_subnet

  ebs_wrk_hub_lbr_nsg = merge(
    {
      "EBS_WRK_HUB_LBR_NSG" = {
        display_name   = lower("${var.ebs_workload_prefix}-hub-ebs-mgmt-lbr-nsg")
        compartment_id = var.core_lz_network_compartment_ocid
        ingress_rules = (var.chosen_network_design_options == "Hub and Spoke" && var.enable_external_app_lb == true) ? merge(
            var.allow_management_env_internet_access == true ? {
            "EBS_WRK_MGMT_ACCESS_TO_HUB_INGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Management LB Subnet."
              stateless    = false
              protocol     = "TCP"
              src          = local.ebs_mgmt_lb_subnet_cidr_block
              src_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443

            }
          } : {},
          {
            "EBS_WRK_CAT_ACCESS_TO_HUB_INGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Category External LB Subnet."
              stateless    = false
              protocol     = "TCP"
              src          = local.ebs_category_ext_lb_subnet_cidr_block
              src_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          }
        ) : {},
        egress_rules = (var.chosen_network_design_options == "Hub and Spoke" && var.enable_external_app_lb == true) ? merge(
            var.allow_management_env_internet_access == true ? {
            "EBS_WRK_MGMT_ACCESS_TO_HUB_EGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Management LB Subnet."
              stateless    = false
              protocol     = "TCP"
              dst          = local.ebs_mgmt_lb_subnet_cidr_block
              dst_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          } : {},
          {
            "EBS_WRK_CAT_ACCESS_TO_HUB_EGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Category LB Subnet."
              stateless    = false
              protocol     = "TCP"
              dst          = local.ebs_category_ext_lb_subnet_cidr_block
              dst_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          }
        ) : {}
      }
    }
  )

  ebs_wrk_hub_mgmt_lbr_nsg_ingress = merge(
      var.allow_management_env_internet_access == true ? {
      "EBS_WRK_MGMT_ACCESS_TO_HUB_INGRESS" = {
        description  = "Baseline Hub to Access to EBS Workload Management LB Subnet."
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_mgmt_lb_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 443
        dst_port_max = 443
      }
    } : {}
  )

  ebs_wrk_hub_mgmt_lbr_nsg_egress = merge(
      var.allow_management_env_internet_access == true ? {
      "EBS_WRK_MGMT_ACCESS_TO_HUB_EGRESS" = {
        description  = "Baseline Hub to Access to EBS Workload Management LB Subnet."
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_mgmt_lb_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 443
        dst_port_max = 443
      }
    } : {}
  )

  ebs_wrk_hub_cat_lbr_nsg = merge(
    {
      "EBS_WRK_HUB_CAT_LBR_NSG" = {
        display_name   = lower("${var.ebs_workload_prefix}-hub-cat-ebs-lbr-nsg")
        compartment_id = var.core_lz_network_compartment_ocid
        ingress_rules = (var.chosen_network_design_options == "Hub and Spoke" && var.enable_external_app_lb == true) ? merge(
          {
            "EBS_WRK_CAT_ACCESS_TO_HUB_INGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Production LB Subnet."
              stateless    = false
              protocol     = "TCP"
              src          = local.ebs_category_ext_lb_subnet_cidr_block
              src_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          }
        ) : {},
        egress_rules = (var.chosen_network_design_options == "Hub and Spoke" && var.enable_external_app_lb == true) ? merge(
          {
            "EBS_WRK_CAT_ACCESS_TO_HUB_EGRESS" = {
              description  = "Baseline Hub to Access to EBS Workload Production LB Subnet."
              stateless    = false
              protocol     = "TCP"
              dst          = local.ebs_category_ext_lb_subnet_cidr_block
              dst_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          }
        ) : {}
      }
    }
  )

  mgmt_app_nsg_ingress = merge(
    {
      "IP-ADDRESS-TO-ACCESS-EBS" = {
        description  = "The CIDR matching the IP address of the machine from which you plan to connect to Oracle E-Business Suite Cloud Manager, such as a bastion server."
        stateless    = false
        protocol     = "TCP"
        src          = var.ebs_env_access_ip_cidr
        src_type     = "CIDR_BLOCK"
        dst_port_min = "22"
        dst_port_max = "22"
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-ICMP" = {
        description = "Ingress from MGMT App subnet"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_mgmt_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-LB-TCP" = {
        description  = "Ingress from mgmt lb subnet cidr."
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_mgmt_lb_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 8081
        dst_port_max = 8081
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-HUB-TCP" = {
        description  = "Ingress from Hub VCN Subnet CIDR."
        stateless    = false
        protocol     = "TCP"
        src          = local.hub_vcn_cidr
        src_type     = "CIDR_BLOCK"
        dst_port_min = 8081
        dst_port_max = 8081
      }
    }
  )

  mgmt_app_nsg_egress = merge (
    {
      "EGRESS-TO-134.70.0.0/16" = {
        description  = "Egress to 134.70.0.0/16. This particular CIDR is required to connect to object storage."
        stateless    = false
        protocol     = "TCP"
        dst          = "134.70.0.0/16"
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-ALL-TCP" = {
        description  = "All <XXX> Services in the Oracle Services Network. XXX is a region-specific code, like IAD."
        stateless    = false
        protocol     = "TCP"
        dst          = "all-services"
        dst_type     = "SERVICE_CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-CLOUD-MANAGER" = {
        description = "Egress to VCN CIDR"
        stateless   = false
        protocol    = "ICMP"
        dst         = local.ebs_mgmt_app_subnet_cidr_block
        dst_type    = "CIDR_BLOCK"
      }
    },
    {
      "EGRESS-TO-CLOUD-MANAGER-22" = {
        description  = "Egress to VCN CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_mgmt_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = "22"
        dst_port_max = "22"
      }
    },
    {
      "EGRESS-TO-CATEGORY-22" = {
        description  = "Egress to VCN CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = var.ebs_workload_category_vcn_cidr[0]
        dst_type     = "CIDR_BLOCK"
        dst_port_min = "22"
        dst_port_max = "22"
      }
    }
  )

  ###############################################################################################
  ######################                 Management Network Security Groups                    ########
  ###############################################################################################

  mgmt_lbaas_nsg = merge (
    {
      "MGMT-LBAAS-NSG" = {
        display_name   = lower("${var.ebs_workload_prefix}-ebs-mgmt-lbaas-nsg")

        compartment_id = var.core_lz_network_compartment_ocid
        ingress_rules = merge(
          {
            "HUB-IP-CIDR-TO-ACCESS-CM" = {
              description  = "The CIDR Block matching the IP address of the machine from which you plan to connect to Oracle E-Business Suite Cloud Manager, such as a bastion server."
              stateless    = false
              protocol     = "TCP"
              src          = var.ebs_env_access_ip_cidr
              src_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          },
            var.chosen_network_design_options == "Hub and Spoke" ? {
            "HUBCIDR-TO-ACCESS-EBS" = {
              description  = "Baseline Core LZ Hub VCN IP CIDR Block."
              stateless    = false
              protocol     = "TCP"
              src          = local.hub_vcn_cidr
              src_type     = "CIDR_BLOCK"
              dst_port_min = 443
              dst_port_max = 443
            }
          } : {}
        ),
        egress_rules = {
          "EGRESS-TO-CLOUD-MANAGER" = {
            description  = "The CIDR matching the private IP of the Oracle E-Business Suite Cloud Manager VM's subnet."
            stateless    = false
            protocol     = "TCP"
            dst          = local.ebs_mgmt_app_subnet_cidr_block
            dst_type     = "CIDR_BLOCK"
            dst_port_min = 8081
            dst_port_max = 8081
          }
        }
      }
    }
  )

  ###############################################################################################
  ######################                 Category Network Security Groups                    ########
  ###############################################################################################

  cat_int_lbaas_nsg_ingress = {
      "IP-CIDR-RANGE-TO-ACCESS-EBS" = {
        description  = "CIDR that describes the IP range users will use to access your Oracle E-Business Suite environments."
        stateless    = false
        protocol     = "TCP"
        src          = var.ebs_env_access_ip_cidr
        src_type     = "CIDR_BLOCK"
        dst_port_min = var.ebs_env_access_dst_port_min
        dst_port_max = var.ebs_env_access_dst_port_max
      },
    }

  cat_int_lbaas_nsg_egress = merge(
      {
        "EGRESS-TO-INT-APP-TCP" = {
          description  = "Internal application tier subnet CIDR"
          stateless    = false
          protocol     = "TCP"
          dst          = local.ebs_category_int_app_subnet_cidr_block
          dst_type     = "CIDR_BLOCK"
          dst_port_min = null
          dst_port_max = null
        }
      },
    {
      "EGRESS-TO-ALL-ICMP" = {
        description = "Egress to 0.0.0.0/0"
        stateless   = false
        protocol    = "ICMP"
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
      }
    }
  )

  cat_int_app_nsg_ingress = merge(
    {
      "INGRESS-FROM-INT-APP-TCP" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-ICMP" = {
        description = "EBS Cloud Manager subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.category_src_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-INT-LB-IMCP" = {
        description = "Internal load balancer subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_int_lb_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-TCP-22" = {
        description  = "EBS Cloud Manager subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.category_src_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-111" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-2049" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "INGRESS-FROM-DB-ICMP" = {
        description = "Database tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_db_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-INT-APP-ICMP" = {
        description = "Internal application tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_int_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-7001" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 7001
        dst_port_max = 7003
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-6801" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 6801
        dst_port_max = 6802
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-16801" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 16801
        dst_port_max = 16802
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-12345" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 12345
        dst_port_max = 12345
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-36501" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 36501
        dst_port_max = 36550
      }
    },
    {
      "INGRESS-FROM-INT-LB-TCP-8000" = {
        description  = "Internal load balancer subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_lb_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 8000
        dst_port_max = 8000
      }
    },
      var.enable_file_system_storage == true ? {
      "INGRESS-FROM-MOUNT-TARGET-TCP-111" = {
        description  = "Mount target FSS Subnet CIDR For TCP Protocol Port 111."
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "INGRESS-FROM-MOUNT-TARGET-TCP-2048" = {
        description  = "Mount target FSS Subnet CIDR For TCP Protocol Port 2048."
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2050
      },
      "INGRESS-FROM-MOUNT-TARGET-UDP-111" = {
        description  = "Mount target FSS Subnet CIDR For UDP Protocol Port 111."
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "INGRESS-FROM-MOUNT-TARGET-UDP-2048" = {
        description  = "Mount target FSS Subnet CIDR For UDP Protocol Port 2048."
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    } : {}
  )
  cat_int_app_nsg_egress = merge(
    {
      "EGRESS-TO-134.70.0.0/17" = {
        description  = "Egress to 134.70.0.0/17"
        stateless    = false
        protocol     = "TCP"
        dst          = "134.70.0.0/17"
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-OSN-ALL" = {
        description  = "All <XXX> Services in the Oracle Services Network. XXX is a region-specific code, like IAD."
        stateless    = false
        protocol     = "TCP"
        dst          = "all-services"
        dst_type     = "SERVICE_CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-OSN" = {
        description = "All <XXX> Services in the Oracle Services Network. XXX is a region-specific code, like IAD."
        stateless   = false
        protocol    = "ICMP"
        dst         = "all-services"
        dst_type    = "SERVICE_CIDR_BLOCK"
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-DB-TCP" = {
        description  = "DB tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_db_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-CLOUD-MANAGER-TCP" = {
        description  = "EBS Cloud Manager Subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.category_src_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-ALL-ICMP" = {
        description = "Egress to 0.0.0.0/0"
        stateless   = false
        protocol    = "ICMP"
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
      }
    },
      var.enable_file_system_storage == true ? {
      "EGRESS-TO-MOUNT-TARGET-UDP-111" = {
        description  = "Mount target FSS Subnet CIDR For TCP Protocol Port 111."
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "EGRESS-TO-MOUNT-TARGET-UDP-2048" = {
        description  = "Mount target FSS Subnet CIDR For UDP Protocol Port 2048."
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      },
      "EGRESS-TO-MOUNT-TARGET-TCP-111" = {
        description  = "Mount target FSS Subnet CIDR For TCP Protocol Port 111."
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "EGRESS-TO-MOUNT-TARGET-TCP-2048" = {
        description  = "Mount target FSS Subnet CIDR For TCP Protocol Port 2048-2050."
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2050
      }
    } : {}
  )

  cat_ext_lbaas_nsg_ingress = var.enable_external_app_lb == true ? merge(
  {
    "IP-CIDR-RANGE-TO-ACCESS-EBS-EXT" = {
      description  = "CIDR that describes the IP range users will use to access your Oracle E-Business Suite environments."
      stateless    = false
      protocol     = "TCP"
      src          = var.ebs_env_access_ip_cidr
      src_type     = "CIDR_BLOCK"
      dst_port_min = var.ebs_env_access_dst_port_min
      dst_port_max = var.ebs_env_access_dst_port_max
    }
  },
      var.chosen_network_design_options == "Hub and Spoke" ? {
      "HUB-CIDR-TO-ACCESS-EBS" = {
        description  = "Baseline Hub VCN IP CIDR Block."
        stateless    = false
        protocol     = "TCP"
        src          = local.hub_vcn_cidr
        src_type     = "CIDR_BLOCK"
        dst_port_min = 443
        dst_port_max = 443
      }
    } : {}
  ) : {}
  cat_ext_lbaas_nsg_egress = var.enable_external_app_lb == true ? merge(
    {
      "EGRESS-TO-EXT-APP-TCP" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-ALL-ICMP" = {
        description = "Egress from 0.0.0.0/0"
        stateless   = false
        protocol    = "ICMP"
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
      }
    }
  ) : {}

  cat_ext_app_nsg_ingress = merge(
    {
      "INGRESS-FROM-EXT-APP-TCP" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-ICMP" = {
        description = "EBS Cloud Manager Subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.category_src_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-EXT-LB-ICMP" = {
        description = "External load balancer subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_ext_lb_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-TCP-22" = {
        description  = "EBS Cloud Manager subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.category_src_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-111" = {
        description  = "Internal application tier subnet"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-2049" = {
        description  = "Internal application tier subnet"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "INGRESS-FROM-INT-APP-ICMP" = {
        description = "Internal application tier subnet"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_int_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-DB-ICMP" = {
        description = "Database tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_db_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-EXT-APP-ICMP" = {
        description = "External application tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_ext_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-22" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-5556" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 5556
        dst_port_max = 5557
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-7201" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 7201
        dst_port_max = 7202
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-17201" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 17201
        dst_port_max = 17202
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-7401" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 7401
        dst_port_max = 7402
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-17401" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 17401
        dst_port_max = 17402
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-7601" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 7601
        dst_port_max = 7602
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-17601" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 17601
        dst_port_max = 17602
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-7801" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 7801
        dst_port_max = 7802
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-17801" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 17801
        dst_port_max = 17802
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-6801" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 6801
        dst_port_max = 6802
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-16801" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 16801
        dst_port_max = 16802
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-9999" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 9999
        dst_port_max = 10000
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-1626" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 1626
        dst_port_max = 1626
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-12345" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 12345
        dst_port_max = 12345
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-36501" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 36501
        dst_port_max = 36550
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-6100" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 6100
        dst_port_max = 6101
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-6200" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 6200
        dst_port_max = 6201
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-6500" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 6500
        dst_port_max = 6501
      }
    },
    {
      "INGRESS-FROM-EXT-LB-TCP-8000" = {
        description  = "External load balancer subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_lb_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 8000
        dst_port_max = 8000
      }
    },
      var.enable_file_system_storage == true ? {
      "INGRESS-FROM-MOUNT-TARGET-TCP-111" = {
        description  = "Mount target subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "INGRESS-FROM-MOUNT-TARGET-TCP-2048" = {
        description  = "Mount target subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2050
      },
      "INGRESS-FROM-MOUNT-TARGET-UDP-111" = {
        description  = "Mount target subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "INGRESS-FROM-MOUNT-TARGET-UDP-2048" = {
        description  = "Mount target subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    } : {}
  )

  cat_ext_app_nsg_egress = merge(
    {
      "EGRESS-TO-134.70.0.0/17" = {
        description  = "Egress to 134.70.0.0/17"
        stateless    = false
        protocol     = "TCP"
        dst          = "134.70.0.0/17"
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-DB-TCP-1521" = {
        description  = "Database tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_db_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 1521
        dst_port_max = 1524
      }
    },
    {
      "EGRESS-TO-CLOUD-MANAGER-TCP-443" = {
        description  = "EBS Cloud Manager subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.category_src_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 443
        dst_port_max = 443
      }
    },
    {
      "EGRESS-TO-ALL-ICMP" = {
        description = "Egress to 0.0.0.0/0"
        stateless   = false
        protocol    = "ICMP"
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-OSN-ALL" = {
        description  = "All <XXX> Services in the Oracle Services Network. (XXX is a region-specific code, such as IAD or LHR)"
        stateless    = false
        protocol     = "TCP"
        dst          = "all-services"
        dst_type     = "SERVICE_CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-OSN" = {
        description = "All <XXX> Services in the Oracle Services Network. (XXX is a region-specific code, such as IAD or LHR)"
        stateless   = false
        protocol    = "ICMP"
        dst         = "all-services"
        dst_type    = "SERVICE_CIDR_BLOCK"
      }
    },
      var.enable_file_system_storage == true ? {
      "EGRESS-FROM-MOUNT-TARGET-UDP-111" = {
        description  = "Mount target FSS Subnet Protocol UDP Port 111."
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "EGRESS-FROM-MOUNT-TARGET-UDP-2048" = {
        description  = "Mount target FSS Subnet Protocol UDP Port 2048."
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      },
      "EGRESS-FROM-MOUNT-TARGET-TCP-111" = {
        description  = "Mount target FSS Subnet Protocol TCP Port 111."
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
      "EGRESS-FROM-MOUNT-TARGET-TCP-2048" = {
        description  = "Mount target FSS Subnet Protocol TCP Port 2048-2050."
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2050
      }
    } : {}
  )

  cat_fss_subnet_nsg_ingress = var.enable_file_system_storage == true ? merge(
    {
      "INGRESS-FROM-FSS-APP-TCP-111" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
    },
    {
      "INGRESS-FROM-FSS-APP-TCP-2048" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "INGRESS-FROM-FSS-APP-TCP-2049" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "INGRESS-FROM-FSS-APP-TCP-2050" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "INGRESS-FROM-FSS-APP-UDP-111" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "INGRESS-FROM-FSS-APP-UDP-2048" = {
        description  = "FSS Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_fss_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-111" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
    },
    {
      "INGRESS-FROM-INT-APP-TCP-2048" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-2049" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-2050" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "INGRESS-FROM-INT-APP-UDP-111" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "INGRESS-FROM-INT-APP-UDP-2048" = {
        description  = "Internal Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },

    {
      "INGRESS-FROM-EXT-APP-TCP-111" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      },
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-2048" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-2049" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "INGRESS-FROM-EXT-APP-TCP-2050" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "INGRESS-FROM-EXT-APP-UDP-111" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "INGRESS-FROM-EXT-APP-UDP-2048" = {
        description  = "External Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    }
  ) : {}

  cat_fss_subnet_nsg_egress = var.enable_file_system_storage == true ? merge(
    {
      "EGRESS-TO-FSS-APP-TCP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-FSS-APP-TCP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "EGRESS-TO-FSS-APP-TCP-2049" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "EGRESS-TO-FSS-APP-TCP-2050" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "EGRESS-TO-FSS-APP-UDP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-FSS-APP-UDP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_fss_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP-2049" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "EGRESS-TO-INT-APP-TCP-2050" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "EGRESS-TO-INT-APP-UDP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-INT-APP-UDP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_int_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP-2049" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2049
        dst_port_max = 2049
      }
    },
    {
      "EGRESS-TO-EXT-APP-TCP-2050" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2050
        dst_port_max = 2050
      }
    },
    {
      "EGRESS-TO-EXT-APP-UDP-111" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 111
        dst_port_max = 111
      }
    },
    {
      "EGRESS-TO-EXT-APP-UDP-2048" = {
        description  = "Application tier subnet CIDR"
        stateless    = false
        protocol     = "UDP"
        dst          = local.ebs_category_ext_app_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 2048
        dst_port_max = 2048
      }
    }
  ) : {}

  cat_db_subnet_nsg_ingress = merge (
    {
      "INGRESS-FROM-CLOUD-MANAGER-ICMP" = {
        description = "EBS Cloud Manager subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.category_src_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-DB-ICMP" = {
        description = "Database tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_db_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-CLOUD-MANAGER-TCP-22" = {
        description  = "EBS Cloud Manager subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.category_src_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "INGRESS-FROM-INT-APP-TCP-1521" = {
        description  = "Internal application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_int_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 1521
        dst_port_max = 1524
      }
    },
    {
      "INGRESS-FROM-INT-APP-ICMP" = {
        description = "Internal application tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_int_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-EXT-APP-SUBNET-TCP-1521" = {
        description  = "External application tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_ext_app_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 1521
        dst_port_max = 1524
      }
    },
    {
      "INGRESS-FROM-EXT-APP-SUBNET-ICMP" = {
        description = "External application tier subnet CIDR"
        stateless   = false
        protocol    = "ICMP"
        src         = local.ebs_category_ext_app_subnet_cidr_block
        src_type    = "CIDR_BLOCK"
      }
    },
    {
      "INGRESS-FROM-DB-SUBNET-TCP-22" = {
        description  = "Database tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_db_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "INGRESS-FROM-DB-SUBNET-TCP-1521" = {
        description  = "Database tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        src          = local.ebs_category_db_subnet_cidr_block
        src_type     = "CIDR_BLOCK"
        dst_port_min = 1521
        dst_port_max = 1524
      }
    }
  )

  cat_db_subnet_nsg_egress = merge (
    {
      "EGRESS-TO-CLOUD-MANAGER-TCP-443" = {
        description  = "EBS Cloud manager subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.category_src_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 443
        dst_port_max = 443
      }
    },
    {
      "EGRESS-TO-DB-TCP-1521" = {
        description  = "Database tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_db_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 1521
        dst_port_max = 1524
      }
    },
    {
      "EGRESS-TO-DB-TCP-22" = {
        description  = "Database tier subnet CIDR"
        stateless    = false
        protocol     = "TCP"
        dst          = local.ebs_category_db_subnet_cidr_block
        dst_type     = "CIDR_BLOCK"
        dst_port_min = 22
        dst_port_max = 22
      }
    },
    {
      "EGRESS-TO-ALL" = {
        description = "Egress to 0.0.0.0/0"
        stateless   = false
        protocol    = "ICMP"
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
      }
    },
    {
      "EGRESS-TO-OSN-TCP" = {
        description  = "All <XXX> Services in the Oracle Services Network(XXX is a region-specific code, such as IAD or LHR) "
        stateless    = false
        protocol     = "TCP"
        dst          = "all-services"
        dst_type     = "SERVICE_CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    },
    {
      "EGRESS-TO-OSN-ICMP" = {
        description  = "All <XXX> Services in the Oracle Services Network(XXX is a region-specific code, such as IAD or LHR) "
        stateless    = false
        protocol     = "ICMP"
        dst          = "all-services"
        dst_type     = "SERVICE_CIDR_BLOCK"
        dst_port_min = null
        dst_port_max = null
      }
    }
  )
}
