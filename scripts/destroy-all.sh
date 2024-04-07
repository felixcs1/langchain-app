# Run from project root, the order here matters
terraform -chdir=infra/frontend apply -auto-approve -destroy
terraform -chdir=infra/app apply -auto-approve -destroy
terraform -chdir=infra/common apply -auto-approve -destroy
