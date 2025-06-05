# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "ebs_workload_prefix" {
  type        = string
  description = "Resource label to append to resource names to maintain segregation between different EBS Workload Stacks."
  validation {
    condition     = can(regex("^([a-z]){1,6}$", var.ebs_workload_prefix))
    error_message = "Allowed maximum 6 lowercase alphabetical characters, and is unique within its parent compartment."
  }
}

variable "ebs_parent_compartment_ocid" {
  type        = string
  description = "Mandatory user provided OCID of the EBS Workload Enclosing Compartment."
  default     = null
}

variable "ebs_category_parent_compartment_ocid" {
  type        = string
  description = "Name of EBS Workload Category Compartment OCID."
  default     = null
}


variable "ebs_mgmt_compartment_name" {
  type        = string
  description = "Name of EBS Workload Management Compartment."
  default     = "ebs-management"
  validation {
    condition     = can(regex("^([a-z0-9.-]){1,100}$", var.ebs_mgmt_compartment_name))
    error_message = "Allowed maximum 100 characters, including lowercase letters, numbers, periods, hyphens, underscores, and is unique within its parent compartment."
  }
}

variable "ebs_category_compartment_name" {
  type        = string
  description = "Name of EBS Workload Category Compartment."
  default     = null
}

variable "ebs_workload_compartment_name" {
  type        = string
  description = "Name of EBS Workload Category Compartment."
  default     = "ebs-workload"
  validation {
    condition     = can(regex("^([a-z0-9.-]){1,100}$", var.ebs_workload_compartment_name))
    error_message = "Allowed maximum 100 characters, including lowercase letters, numbers, periods, hyphens, underscores, and is unique within its parent compartment."
  }
}
variable "deploy_ebs_mgmt" {
  type        = bool
  description = "Set to true to deploy Management IAM Resources."
  default     = true
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.deploy_ebs_mgmt))
    error_message = "The deploy_ebs_mgmt boolean_variable must be either true or false."
  }
}
variable "deploy_ebs_category" {
  type        = bool
  description = "Set to true to deploy Management IAM Resources."
  default     = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.deploy_ebs_category))
    error_message = "The deploy_ebs_category boolean_variable must be either true or false."
  }
}

variable "ebs_category" {
  type        = string
  description = "Name of EBS Category Compartment."
  validation {
    condition     = can(regex("^([a-z0-9.-]{1,100})?$", var.ebs_category))
    error_message = "Allowed maximum 100 characters, including lowercase letters, numbers, periods, hyphens, underscores, and is unique within its parent compartment."
  }
}

variable "ebs_compartment_structure" {
  type        = string
  description = "Deploy Single Compartment option or Flexible Compartment Struture."
  default     = "Single Compartment Deployment"
}

variable "ebs_mgmt_parent_compartment_ocid" {
  type        = string
  description = "Parent Compartment OCID for EBS Workload Management Compartment."
  default     = null
}
variable "mgmt_admin_group_name" {
  type        = string
  description = "Workload admin group name"
  default     = "mgmt-admin-group"
}
variable "category_admin_group_name" {
  type        = string
  description = "Category workload admin group name"
  default     = null
}
variable "core_lz_network_compartment_ocid" {
  type = string
  description = "Core Landing Zone Network Compartment OCID"
  default = null
}
variable "core_lz_security_compartment_ocid" {
  type = string
  description = "Core Landing Zone Security Compartment OCID"
  default = null
}