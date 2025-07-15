resource "oci_identity_compartment" "cloudlab" {
  name          = "cloudlab"
  description   = "Compartment for CloudLab resources"
  enable_delete = true
}