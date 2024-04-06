AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Auth to ECR
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 972518559371.dkr.ecr.eu-west-2.amazonaws.com/langserve

# Backend app
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest -f ./backend/Dockerfile  ./backend
docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest

# Frontend app
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve-frontend:latest -f ./frontend/Dockerfile.prod  ./frontend
docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve-frontend:latest
