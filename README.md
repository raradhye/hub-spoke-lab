# Azure Hub-Spoke Network Infrastructure

## Overview
Hub-spoke network topology on Azure built with Terraform. This project demonstrates 
enterprise-grade Azure networking architecture with secure VM connectivity and 
remote state management.

### Components
- **Hub VNet** (10.1.0.0/16) — central network with shared services
  - AzureBastionSubnet (10.1.1.0/26) — secure VM access
  - snet-shared (10.1.4.0/24) — shared services subnet
- **Spoke VNet** (10.2.0.0/16) — isolated workload network
  - snet-app (10.2.1.0/24) — application subnet
- **VNet Peering** — private connectivity between hub and spoke
- **NSG** — restricts spoke inbound traffic to hub range only
- **Azure Bastion** — secure browser-based SSH/RDP without public IPs
- **Remote State** — Terraform state stored in Azure Blob Storage

## Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform v1.11+
- Git

## Project Structure
```
hub-spoke-lab/
├── main.tf           # All resources
├── providers.tf      # Azure provider and remote backend
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── terraform.tfvars  # Variable values (not committed to Git)
```

## How to Deploy

### 1. Clone the repository
```bash
git clone https://github.com/raradhye/hub-spoke-lab.git
cd hub-spoke-lab
```

### 2. Create terraform.tfvars
```bash
cat > terraform.tfvars << EOF
location            = "westus"
resource_group_name = "rg-hub-spoke-lab"
admin_username      = "azureuser"
admin_password      = "YOUR_PASSWORD"
EOF
```

### 3. Initialise and deploy
```bash
terraform init
terraform plan
terraform apply
```

### 4. Verify connectivity
```bash
# Note the output IPs
terraform output

# Connect to hub VM via Bastion in Azure portal
# Then ping spoke VM private IP
ping 10.2.1.4
```

## Outputs
| Output | Description |
|--------|-------------|
| `hub_vnet_id` | Hub VNet resource ID |
| `spoke_vnet_id` | Spoke VNet resource ID |
| `hub_vm_private_ip` | Hub VM private IP address |
| `spoke_vm_private_ip` | Spoke VM private IP address |

## Security Considerations
- No public IPs on any VM
- All VM access via Azure Bastion only
- NSG restricts spoke inbound to hub range (10.1.0.0/16) only
- Terraform state stored securely in Azure Blob Storage
- Sensitive variables never committed to Git

## What's Next
- [ ] Azure Key Vault integration for secret management
- [ ] Azure Firewall for centralised traffic inspection
- [ ] Route tables to force spoke traffic through hub firewall
- [ ] Additional spoke environments (dev/prod)
- [ ] CI/CD pipeline with GitHub Actions

## Author
Rajesh Aradhye