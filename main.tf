provider "ibm" {
  ibmcloud_timeout = 300
}

## Create Access Groups for Admins and Users 
#Ref: https://github.com/cloud-native-toolkit/terraform-ibm-account-access-group
#Ref: https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-account-access-management

locals {  
  cloud-organization-admins = "CLOUD_ORGANIZATION_ADMINS"
  cloud-organization-admins-desc = "Responsible for organizing the structure of the resources used by the organization"
  cloud-network-admins = "CLOUD_NETWORK_ADMINS"
  cloud-network-admins-desc = "Responsible for creating networks, VPCs, load balancers, subnets, firewall rules and network devices"
  cloud-security-admins = "CLOUD_SECURITY_ADMINS"
  cloud-security-admins-desc = "Responsible for establishing and managing security policies for the organization, including access management"
  cloud-billing-admins = "CLOUD_BILLING_ADMINS"
  cloud-billing-admins-desc = "Responsible for setting up billing accounts and monitoring their usage"
  cloud-devops = "CLOUD_DEVOPS"
  cloud-devops-admins-desc = "DevOps practitioners create or managed end-to-end piplines that support CI/CD, monitoring and provisioning"
  cloud-developers = "CLOUD_DEVELOPERS"
  cloud-developers-desc = "Developers are responsible for designing, coding and testing applications"
  cloud-project-lead = "PROJECT LEAD"
  cloud-project-lead-desc = "The project lead can create a new resource group and manage access to that group."
}

resource ibm_iam_access_group org_admins {
  name = local.cloud-organization-admins
  description = local.cloud-organization-admins-desc
}
resource ibm_iam_access_group billing_admins {
  name = local.cloud-billing-admins
  description = local.cloud-billing-admins-desc
}
resource ibm_iam_access_group network_admins {
  name = local.cloud-network-admins
  description = local.cloud-network-admins-desc
}
resource ibm_iam_access_group security_admins {
  name = local.cloud-security-admins
  description = local.cloud-security-admins-desc
}
resource ibm_iam_access_group devops {
  name = local.cloud-devops
  description = local.cloud-devops-admins-desc
}
resource ibm_iam_access_group developers {
  name = local.cloud-developers
  description = local.cloud-developers-desc

}
resource ibm_iam_access_group project_lead {
  name = local.cloud-project-lead
  description = local.cloud-project-lead-desc

}

# Custom role for creating and managing access to resource groups
resource ibm_iam_custom_role project_lead {
  name         = "ResourceGroupCreator"
  display_name = "ResourceGroupCreator"
  description  = "A user with this role can create a new resource group and an access group.  They would be responsible for setting up resource groups and access to the group.  They are not able to delete resource or access groups."
  service      = "iam-groups"
  actions      = ["iam-groups.groups.create",
                  "iam-groups.groups.list",
                  "iam-groups.groups.read",
                  "iam-groups.members.add",
                  "iam-groups.members.list",
                  "iam-groups.members.read",
                  "resource-controller.group.create",
                  "resource-controller.group.retrieve"
                  ]
}

# cloud-organization-admins

# All IAM-Managed resources in account
resource ibm_iam_access_group_policy admin_policy_1 {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Administrator"]
  /*resources {
    resource_group_id = data.ibm_resource_group.group.id    
  }*/
}

# All Account Management services
resource ibm_iam_access_group_policy admin_policy_2 {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Administrator"]
  account_management = true  
}

# Support cases
resource ibm_iam_access_group_policy admin_policy_3 {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"    
  }  
}

# Cloud Object Storage, bucket management. It is not covered by the 
# general "All IAM enabled services"
resource ibm_iam_access_group_policy admin_policy_4 {
  access_group_id = ibm_iam_access_group.org_admins.id
  roles           = ["Manager"]
  resources {
    service = "cloud-object-storage"    
  }  
}

# cloud-billing-admins

resource ibm_iam_access_group_policy billing_policy_1 {
  access_group_id = ibm_iam_access_group.billing_admins.id
  roles           = ["Administrator"]
  resources {
    service = "billing"
  }
}

resource ibm_iam_access_group_policy billing_policy_2 {
  access_group_id = ibm_iam_access_group.billing_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"
  }
}

# cloud-network-admins

resource ibm_iam_access_group_policy network_policy_1 {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Administrator","IP Spoofing Operator"]
  resources {
    service = "is"
  }
}

resource ibm_iam_access_group_policy network_policy_2 {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Viewer"]
}

resource ibm_iam_access_group_policy network_policy_3 {
  access_group_id = ibm_iam_access_group.network_admins.id
  roles           = ["Editor"]
  resources {
    service = "support"    
  }  
}

# cloud-security-admins

resource ibm_iam_access_group_policy security_policy_1 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Viewer"]
  account_management = true  
}


# Access to Security and Compliance Center Scans
resource ibm_iam_access_group_policy security_policy_2 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator"]
  resources {
    service = "compliance"  
  }
}


# Allow creation of Service IDs and API Keys.  This may not be needed
# if CLOUD_ORGANIZATION_ADMIN can provide credentials for scans
resource ibm_iam_access_group_policy security_policy_4 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator", "User API key creator", "Service ID creator"]
  resources {
    service = "iam-identity"
  }
}

resource ibm_iam_access_group_policy security_policy_5 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Administrator"]
  resources {
    service = "iam-groups"  
  }
}

resource ibm_iam_access_group_policy security_policy_6 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Viewer"]
}

# Visibility into clusters
resource ibm_iam_access_group_policy security_policy_7 {
  access_group_id = ibm_iam_access_group.security_admins.id
  roles           = ["Viewer", "Reader"]

  resources {
    service           = "containers-kubernetes"
  }
}


resource ibm_iam_access_group_policy devops_policy_1 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Viewer"]
}

resource ibm_iam_access_group_policy devops_policy_2 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Administrator","Manager"]
  resources {
    service = "logdnaat"  
  }
}

resource ibm_iam_access_group_policy devops_policy_3 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Administrator","Manager"]

  resources {
    service           = "containers-kubernetes"
  }
}

resource ibm_iam_access_group_policy devops_policy_4 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Viewer", "Operator", "IP Spoofing Operator"]
  resources {
    service = "is"
  }
}

resource ibm_iam_access_group_policy devops_policy_5 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Editor"]
  resources {
    service = "support"    
  }  
}

# Cloud Object Storage, bucket management. 
resource ibm_iam_access_group_policy devops_policy_6 {
  access_group_id = ibm_iam_access_group.devops.id
  roles           = ["Manager"]
  resources {
    service = "cloud-object-storage"    
  }  
}


resource ibm_iam_access_group_policy developer_policy_1 {
  access_group_id = ibm_iam_access_group.developers.id
  roles           = ["Administrator", "Manager"]

  resources {
    service           = "containers-kubernetes"
  }
}

resource ibm_iam_access_group_policy developer_policy_2 {
  access_group_id = ibm_iam_access_group.developers.id
  roles           = ["Editor"]
  resources {
    service = "support"    
  }  
}

resource ibm_iam_access_group_policy project_lead_policy_1 {
  depends_on = [
    ibm_iam_custom_role.project_lead
  ]
  access_group_id = ibm_iam_access_group.project_lead.id
  roles           = ["ResourceGroupCreator"]
  resources {
    service = "iam-groups"    
  }  
}
