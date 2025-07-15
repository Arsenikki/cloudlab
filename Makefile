.PHONY: encrypt-state
encrypt-state:
	sops --encrypt --output cloud-infra/terraform.tfstate.enc cloud-infra/terraform.tfstate 

.PHONY: decrypt-state
decrypt-state:
	sops --decrypt --output cloud-infra/terraform.tfstate cloud-infra/terraform.tfstate.enc
