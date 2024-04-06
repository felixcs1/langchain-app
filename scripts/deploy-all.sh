# Run from project root
terraform -chdir=infra/common apply -auto-approve
terraform -chdir=infra/app apply -auto-approve
terraform -chdir=infra/frontend apply -auto-approve
