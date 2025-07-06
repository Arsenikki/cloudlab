resource "oci_core_virtual_network" "cloudlab_vcn" {
  compartment_id = oci_identity_compartment.cloudlab.id
  display_name   = "cloudlab-vcn"
  cidr_block     = "10.0.0.0/16"
}

resource "oci_core_internet_gateway" "cloudlab_igw" {
  compartment_id = oci_identity_compartment.cloudlab.id
  vcn_id        = oci_core_virtual_network.cloudlab_vcn.id
  display_name  = "cloudlab-igw"
  enabled       = true
}

resource "oci_core_route_table" "cloudlab_rt" {
  compartment_id = oci_identity_compartment.cloudlab.id
  vcn_id        = oci_core_virtual_network.cloudlab_vcn.id
  display_name  = "cloudlab-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.cloudlab_igw.id
  }
}

resource "oci_core_security_list" "cloudlab_ssh" {
  compartment_id = oci_identity_compartment.cloudlab.id
  vcn_id        = oci_core_virtual_network.cloudlab_vcn.id
  display_name  = "cloudlab-ssh"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "cloudlab_subnet" {
  compartment_id      = oci_identity_compartment.cloudlab.id
  vcn_id              = oci_core_virtual_network.cloudlab_vcn.id
  display_name        = "cloudlab-subnet"
  cidr_block          = "10.0.1.0/24"
  prohibit_public_ip_on_vnic = false
  security_list_ids = [oci_core_security_list.cloudlab_ssh.id]
  route_table_id = oci_core_route_table.cloudlab_rt.id
}

resource "oci_core_instance" "cloudlab_arm_vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.cloudlab.id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus = 4 # Free tier: up to 4 OCPUs total
    memory_in_gbs = 24 # Free tier: up to 24 GB total
  }

  source_details {
    source_type = "image"
    # Latest Ubuntu 24.04 ARM image as of July 2025
    source_id   = "ocid1.image.oc1.uk-london-1.aaaaaaaawo3yjremf25rephk6og5sfdp67vkrgro3krezmjpft54l5ltcb2a"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.cloudlab_subnet.id
  }

  display_name = "cloudlab-vm-01"

  metadata = {
    ssh_authorized_keys = <<-EOF
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/5+LRMLksIYtgj2GJnbKSi8qzZSaPJkp43KxHOYe6MwCtwB4GRenxNSfSFi/50WJ874225N7DgAtD8SIwXeWWe0Rq4Bn8JdSxjQtCw+qgLSKHoVwb3w2hwbd3VR9E/FWpFYfaZKd72cWDQdAwLInR/q/8llh/MTPeZmcVtINaDASrA4NiqQwr8/lDZGbxqMcLSk1XWtQaia7/7a6sSAvp9dJH3sQqxjCzqHQUH9iuoHkQpbO5X23vPudXSrr+Q5lDdvsLWHTkyWSttXwmcebVg7f44eJ7YLvpcEoemyME/EkqExmvM5mAFB9SY2NlcDDE0d/pGCEVWPrP4B5HAjggz4iCfmDWObRE3PRFKmugamxtRd2YBuyuwkmbp23LnYcMe/8UbGVwmKssGEvuIX60PxpQWoWZelF/qHDaPw2uYoVGEFQ5ciSp6B1b0A2DTuxFUsSU6U7Qs6+BAJXGzWhNYOJfhPG0K2llVBebfBUtgMv8n+8xZFCBrEKbKS39EIs= arsenikki
    EOF
    user_data = base64encode(<<-CLOUDINIT
      #cloud-config
      package_update: true
      package_upgrade: true
      runcmd:
        - git clone https://github.com/arsenikki/cloudlab.git
        - chmod -x ~/cloudlab/ansible/init.sh
        - ~/cloudlab/ansible/init.sh
    CLOUDINIT
    )
  }
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.cloudlab.id
}