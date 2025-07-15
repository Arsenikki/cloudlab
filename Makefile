.PHONY: encrypt-state
encrypt-state:
	sops --encrypt --output terraform.tfstate.enc terraform.tfstate 

.PHONY: decrypt-state
decrypt-state:
	sops --decrypt --output terraform.tfstate terraform.tfstate.enc 
