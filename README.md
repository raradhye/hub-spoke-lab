# Azure Hub-Spoke Network Infrastructure

## Overview
Hub-spoke network topology on Azure built with Terraform using a modular 
architecture. This project demonstrates enterprise-grade Azure networking 
with secure VM connectivity, Key Vault secret management, remote state 
and multi-environment support.

### Components
- **Hub VNet** (10.1.0.0/16) — central network with shared services
  - AzureBastionSubnet (10.1.1.0/26) — secure VM access
  - snet-shared (10.1.4.0/24) — shared services subnet
- **Spoke VNet** (environment specific) — isolated workload network
  - snet-app — application subnet
- **VNet Peering** — private connectivity between hub and spoke
- **NSG** — restricts spoke inbound traffic to hub range only
- **Azure Bastion** — secure browser-based SSH/RDP without public IPs
- **Azure Key Vault** — VM admin password stored and retrieved securely
- **Remote State** — Terraform state stored in Azure Blob Storage per environment

## Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform v1.11+
- Git

## Project Structure
```
hub-spoke-lab/
├── main.tf                      # Root — calls all modules
├── providers.tf                 # Azure provider and remote backend
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── environments/
│   ├── dev.tfvars               # Dev environment values
│   └── prod.tfvars              # Prod environment values
├── .gitignore                   # Excludes secrets and state files
└── modules/
    ├── networking/              # VNets, subnets, peering, NSG
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── keyvault/                # Key Vault and access policy
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── vm/                      # NICs and VMs
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## How Modules Work
Values flow between modules through outputs and variables:
```
dev.tfvars
    ↓ spoke_vnet_address, spoke_vnet_subnet
networking module → creates VNets and subnets
    ↓ hub_shared_subnet_id, spoke_app_subnet_id
vm module → places NICs in correct subnets

keyvault module → creates Key Vault
    ↓ key_vault_id
vm module → reads password directly from Key Vault
```

No secrets are passed between modules — the VM module reads the 
password directly from Key Vault using the vault ID only.

## Security Design
- No public IPs on any VM — all access via Azure Bastion only
- VM admin password stored in Azure Key Vault — never in any file
- VM module reads password directly from Key Vault — not passed between modules
- NSG restricts spoke inbound to hub range (10.1.0.0/16) only
- Terraform state stored securely in Azure Blob Storage with state locking
- azurerm_client_config data source used for tenant and object IDs
- No hardcoded credentials anywhere in code
- Sensitive outputs marked sensitive = true — never shown in logs

## How to Deploy

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/hub-spoke-lab.git
cd hub-spoke-lab
```

### 2. Create environment tfvars file
Create `environments/dev.tfvars` — this file is gitignored:
```hcl
location            = "westus"
resource_group_name = "rg-hub-spoke-lab"
admin_username      = "azureuser"
environment_name    = "dev"
spoke_vnet_address  = "10.2.0.0/16"
spoke_vnet_subnet   = "10.2.1.0/24"
```

### 3. Initialise Terraform with environment state
```bash
terraform init -backend-config="key=hub-spoke-dev.tfstate"
```

### 4. Plan and deploy
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

### 5. Seed Key Vault secret
After first apply — manually seed the VM password into Key Vault:
```bash
az keyvault secret set \
  --vault-name "kv-hub-spoke-lab" \
  --name "vm-admin-password" \
  --value "YOUR_PASSWORD"
```

### 6. Apply again to use Key Vault secret
```bash
terraform apply -var-file="environments/dev.tfvars"
```

### 7. Verify connectivity
```bash
# Note the output IPs
terraform output

# Connect to hub VM via Bastion in Azure portal
# Then ping spoke VM private IP
ping 10.2.x.x
```

## Multi-Environment Support
Same codebase deploys to multiple environments using different tfvars files
and separate state files:
```bash
# Dev environment
terraform init -backend-config="key=hub-spoke-dev.tfstate"
terraform apply -var-file="environments/dev.tfvars"

# Prod environment
terraform init -backend-config="key=hub-spoke-prod.tfstate"
terraform apply -var-file="environments/prod.tfvars"
```

Each environment has its own isolated state file in Azure Blob Storage —
a failed dev deployment can never impact production.

## Outputs
| Output | Description |
|--------|-------------|
| `hub_vnet_id` | Hub VNet resource ID |
| `spoke_vnet_id` | Spoke VNet resource ID |
| `hub_vm_private_ip` | Hub VM private IP address |
| `spoke_vm_private_ip` | Spoke VM private IP address |
| `key_vault_id` | Key Vault resource ID |

## What's Next
- [ ] PowerShell runner script for environment switching
- [ ] Azure Monitor + Log Analytics alerts
- [ ] Azure Firewall for centralised traffic inspection
- [ ] Route tables forcing spoke traffic through hub firewall
- [ ] VPN Gateway for on-premises connectivity simulation
- [ ] AKS / Kubernetes workloads
- [ ] User Assigned Managed Identity for VMs
- [ ] CI/CD pipeline with GitHub Actions

## Author
Rajesh Aradhye
[LinkedIn](https://www.linkedin.com/in/raradhye) |
[GitHub](https://github.com/raradhye/)