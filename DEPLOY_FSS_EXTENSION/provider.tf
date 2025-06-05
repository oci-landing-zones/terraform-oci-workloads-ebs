# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {

  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name }
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key }
  home_region_key     = data.oci_identity_tenancy.this.home_region_key
  region_key          = lower(local.regions_map_reverse[var.region])
}

# -----------------------------------------------------------------------------
# Provider blocks for home region and alternate region(s)
# -----------------------------------------------------------------------------
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.region
}

provider "oci" {
  alias            = "home_region"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = local.regions_map[local.home_region_key]
}

provider "oci" {
  alias            = "block_volumes_replication_region"
  region           = var.block_volumes_replication_region != null ? var.block_volumes_replication_region : local.regions_map[local.home_region_key]
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.current_user_ocid
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
}