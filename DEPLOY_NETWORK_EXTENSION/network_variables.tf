# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "ebs_workload_prefix" {
  type        = string
  description = "Resource label to append to resource names to maintain segregation between different EBS Workload Stacks."
  default     = "EBSWRK"
  validation {
    condition     = can(regex("^([[:alpha:]]){1,6}$", var.ebs_workload_prefix))
    error_message = "Allowed maximum 6 alphabetical characters, and is unique within its parent compartment."
  }
}

variable "enable_file_system_storage" {
  default     = false
  description = "Whether to enable File System Storage Service."
  type        = bool
}

variable "chosen_network_design_options" {
  description = "Select the Network Design Type : HUB_AND_SPOKE (Default) or STANDALONE"
  type        = string
  default     = "HUB_AND_SPOKE"
}

variable "enable_oracle_database_exadb" {
  description = "Select this options to Enable DB Backup Subnet."
  type        = bool
  default     = false
}

variable "hub_drg_ocid" {
  type        = string
  default     = null
  description = "Please Provide the Existing DRG OCID (Mandatory in case of HUB_AND_SPOKE Network Design)"
}

variable "hub_vcn_ocid" {
  type        = string
  default     = null
  description = "Please Provide the Hub VCN IP OCID (Mandatory in case of HUB_AND_SPOKE Network Design)."
}



##############################################################################################
#####################              MGMT VCN                           ########################
##############################################################################################
variable "deploy_management" {
  type        = bool
  description = "Whether to deploy a management VCN."
  default     = false
}

variable "mgmt_compartment_ocid" {
  type        = string
  description = "Mgmt compartment ocid"
  default     = null
}

variable "ebs_workload_mgmt_vcn_name" {
  type        = string
  description = "Name of the EBS Workload MGMT VCN Name."
  default     = "ebs-management"
  validation {
    condition     = can(regex("^([\\w\\.-]){1,100}$", var.ebs_workload_mgmt_vcn_name))
    error_message = "Allowed maximum 100 characters, including letters, numbers, periods, hyphens, underscores, and is unique within its parent compartment."
  }
}

variable "ebs_workload_mgmt_vcn_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/22"]
  description = "List of CIDR blocks for the EBS Workload Management VCN."
}



##############################################################################################
#####################              Category VCN                       ########################
##############################################################################################

variable "deploy_ebs_category" {
  type        = bool
  description = "Set to true to deploy Management IAM Resources."
  default     = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.deploy_ebs_category))
    error_message = "The enable_compartment_delete boolean_variable must be either true or false."
  }
}

variable "ebs_category" {
  type        = string
  description = "Name of EBS Workload Category."
  default     = "PROD"
  validation {
    condition     = can(regex("^([\\w\\.-]){1,100}$", var.ebs_category))
    error_message = "Allowed maximum 100 characters, including letters, numbers, periods, hyphens, underscores, and is unique within its parent compartment."
  }
}

variable "category_compartment_ocid" {
  type        = string
  description = "Category compartment OCID"
  default     = ""
}

variable "ebs_workload_category_vcn_name" {
  type        = string
  description = "Name of the EBS Workload Category VCN Name."
  default     = null
}

variable "ebs_workload_category_vcn_cidr" {
  type        = list(string)
  default     = ["10.0.4.0/22"]
  description = "List of CIDR blocks for the EBS Workload Category VCN."
}

variable "enable_external_app_lb" {
  default     = false
  description = "Whether to enable External LBAAS and Application."
  type        = bool
}

variable "allow_management_env_internet_access" {
  default     = true
  description = "Allow Internet Access to MGMT VCN."
  type        = bool
}

###############################################################################################
######################            MGMT SUBNET DEFINITION               ########################
###############################################################################################

## Management Load Balancer Subnet 

variable "ebs_mgmt_lb_subnet_name" {
  type        = string
  default     = "ebs-mgmt-lb-subnet"
  description = "EBS Management Cloud Manager Load Balancers Subnet Name."
}
variable "ebs_mgmt_lb_subnet_cidr" {
  type        = string
  default     = null
  description = "Service EBS Cloud Manager Load Balancers Subnet CIDR Block."
}

## Management Application Subnet 

variable "ebs_mgmt_app_subnet_name" {
  type        = string
  default     = "MGMT-APP-SUBNET"
  description = "EBS Management Cloud Manager Application Subnet Name."
}
variable "ebs_mgmt_app_subnet_cidr" {
  type        = string
  default     = null
  description = "Service EBS Cloud Manager Application Subnet CIDR Block."
}

###############################################################################################
######################            Category SUBNET DEFINITION           ########################
###############################################################################################

## Category Internal Load Balancer Subnet 

variable "ebs_category_int_lb_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category Internal Load Balancers Subnet Name."
}
variable "ebs_category_int_lb_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category Internal Load Balancers Subnet CIDR Block."
}

## Category Internal Application Subnet 

variable "ebs_category_int_app_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category Internal Application Subnet Name."
}
variable "ebs_category_int_app_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category Internal Application Subnet CIDR Block."
}


# Category External Load Balancer Subnet 

variable "ebs_category_ext_lb_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category External Load Balancers Subnet Name."
}
variable "ebs_category_ext_lb_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category External Load Balancers Subnet CIDR Block."
}

## Category External Application Subnet 

variable "ebs_category_ext_app_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category External Application Subnet Name."
}
variable "ebs_category_ext_app_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category External Application Subnet CIDR Block."
}

## Category FSS Subnet 

variable "ebs_category_fss_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category FSS Subnet Name."
}
variable "ebs_category_fss_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category FSS Subnet CIDR Block."
}


## Category DB Subnet 

variable "ebs_category_db_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category Database Subnet Name."
}
variable "ebs_category_db_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category Database Subnet CIDR Block."
}


## Category DB Backup Subnet 

variable "ebs_category_db_backup_subnet_name" {
  type        = string
  default     = null
  description = "EBS Category Database Backup Subnet Name."
}
variable "ebs_category_db_backup_subnet_cidr" {
  type        = string
  default     = null
  description = "EBS Category Database Backup Subnet CIDR Block."
}

#### NSG VARIABLES ####

variable "ebs_env_access_dst_port_min" {
  type        = number
  default     = 443
  description = "The destination port minimum"
}
variable "ebs_env_access_dst_port_max" {
  type        = number
  default     = 443
  description = "The destination port maximum"
}
variable "ebs_env_access_ip_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "User input that describes the IP range used to access Oracle E-Business Suite environments."
}

#### VCN Gateway ####
variable "enable_mgmt_nat_gateway" {
  description = "Whether to enable a Management NAT gateway. Set to true to enable a NAT gateway."
  type        = bool
  default     = false
}

variable "enable_category_nat_gateway" {
  description = "Whether to enable a Category NAT gateway. Set to true to enable a NAT gateway."
  type        = bool
  default     = false
}

variable "enable_mgmt_service_gateway" {
  description = "Whether to enable a Management Service gateway. Set to true to enable a Service gateway."
  type        = bool
  default     = false
}

variable "enable_category_service_gateway" {
  description = "Whether to enable a Category Service gateway. Set to true to enable a Service gateway."
  type        = bool
  default     = false
}

variable "mgmt_nat_gateway_display_name" {
  description = "Display name of the Management NAT gateway. Default is nat-gateway."
  type        = string
  default     = "mgmt-nat-gateway"
}

variable "category_nat_gateway_display_name" {
  description = "Display name of the Management NAT gateway. Default is nat-gateway."
  type        = string
  default     = "cat-nat-gateway"
}

variable "mgmt_nat_gateway_block_traffic" {
  description = "Whether to block traffic with the Management NAT gateway. Default is false."
  type        = bool
  default     = false
}
variable "category_nat_gateway_block_traffic" {
  description = "Whether to block traffic with the Management NAT gateway. Default is false."
  type        = bool
  default     = false
}
variable "mgmt_service_gateway_display_name" {
  description = "Display name of the Service Gateway. Default is service-gateway."
  type        = string
  default     = "mgmt-service-gateway"
}
variable "category_service_gateway_display_name" {
  description = "Display name of the Service Gateway. Default is service-gateway."
  type        = string
  default     = "cat-service-gateway"
}

variable "mgmt_service_gateway_services" {
  description = "Services supported by Service Gateway. Values are 'objectstorage' and 'all-services'."
  type        = string
  default     = "all-services"
}
variable "category_service_gateway_services" {
  description = "Services supported by Service Gateway. Values are 'objectstorage' and 'all-services'."
  type        = string
  default     = "all-services"
}
variable "mgmt_internet_gateway_display_name" {
  description = "Display name of the Management Internet Gateway. Default is internet-gateway."
  type        = string
  default     = "mgmt-internet-gateway"
}

variable "category_internet_gateway_display_name" {
  description = "Display name of the Category Internet Gateway. Default is internet-gateway."
  type        = string
  default     = "cat-internet-gateway"
}

variable "category_provided_src_subnet" {
  description = "The user provided source subnet for category NSG rules when MGMT subnet is not deployed"
  type        = string
  default     = ""
}

variable "add_hub_vcn_route_drg" {
  type        = bool
  description = "A list of subnets cidr blocks in additional EBS stack"
  default     = false
}

variable "core_lz_network_compartment_ocid" {
  type        = string
  description = "Core LZ Network Compartment OCID"
  default     = "Add the Hub VCN Route on EBS WRK VCN via DRG. This Step need to be done after adding the Additional EBS WRK Route on Core LZ."
}