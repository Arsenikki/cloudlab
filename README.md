
# CloudLab

This repository contains simple OpenTofu code to provision Oracle Cloud Infrastructure (OCI) resources securely.

## Prerequisites
- [OpenTofu](https://opentofu.org/docs/latest/getting-started/install/)
- Oracle Cloud account and API keys configured
- [SOPS](https://github.com/getsops/sops) for state encryption

## Usage
1. Configure your OCI credentials in ~/.oci/config
2. Initialize OpenTofu:
   ```sh
   tofu init
   ```
3. Review the plan:
   ```sh
   tofu plan
   ```
4. Apply the configuration:
   ```sh
   tofu apply
   ```
5. (Recommended) Encrypt your state file before committing:
   ```sh
   make encrypt-state
   # or manually:
   # sops --encrypt --output terraform.tfstate.sops.yaml terraform.tfstate
   ```
6. To decrypt your state for use:
   ```sh
   make decrypt-state
   # or manually:
   # sops --decrypt --output terraform.tfstate terraform.tfstate.sops.yaml
   ```

## Notes
- Edit `main.tf` to add more resources as needed.
- Never commit your secrets, `.tfvars` files, or unencrypted state files.
- Only commit the encrypted `terraform.tfstate.sops.yaml` if you need to store state in version control.
- See `.gitignore` for recommended exclusions.
