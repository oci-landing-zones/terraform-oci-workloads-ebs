# ###################################################################################################### #
# Copyright (c) 2025 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

data "oci_identity_regions" "these" {}

data "oci_identity_region_subscriptions" "these" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

