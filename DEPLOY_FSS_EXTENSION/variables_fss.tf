# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

variable "block_volumes_replication_region" {
  description = "The replication region for block volumes. Leave unset if replication occurs to an availability domain within the block volume region."
  default     = null
}

variable "ebs_workload_prefix" {
  type        = string
  description = "Resource label to append to resource names to maintain segregation between different EBS Workload Stacks."
  default     = "EBSWRK"
  validation {
    condition     = can(regex("^([[:alpha:]]){1,6}$", var.ebs_workload_prefix))
    error_message = "Allowed maximum 6 alphabetical characters, and is unique within its parent compartment."
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

variable "core_lz_network_cmp_ocid" {
  type        = string
  description = "Please provide the Core LZ Network Compartment OCID."
  default     = null
}

variable "ebs_category_fss_subnet_ocid" {
  type        = string
  description = "EBS Category FSS Subnet OCID."
  default     = null
}

variable "ebs_category_fss_subnet_nsg_ocid" {
  type        = string
  description = "EBS Category FSS Subnet NSG OCID."
  default     = null
}


variable "ebs_category_mount_target_name" {
  type        = string
  default     = null
  description = "EBS Category Mount Target Name."
}

variable "ebs_category_mount_target_path" {
  type        = string
  default     = "/category-foo"
  description = "EBS Category Mount Target Absolute Export Path For example: /foo."
}

variable "ebs_category_mount_hostname" {
  type        = string
  default     = null
  description = "EBS Category: Hostname for the mount target's IP address, used for DNS resolution. The value is the hostname portion of the private IP address's fully qualified domain name (FQDN)."
}

variable "ebs_categort_fss_snapshot_policy_name" {
  type        = string
  default     = null
  description = "EBS Category File System Storage Snapshot Policy Name."
}

variable "ebs_category_fss_snapshot_policy_frequency" {
  type        = string
  default     = "daily"
  description = "EBS Category Snapshot Policy Frequency : Daily, Weekly, Monthly and Yearly"
}
