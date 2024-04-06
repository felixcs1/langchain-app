# langchain_demo_app

Architecture: https://miro.com/app/board/uXjVKaHvfVM=/

Install pre-commit hook
```
pre-commit install
```

# Run locally

```
docker-compose up
```

## Docker

Set account id
```
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
```

```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve

docker build -t $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest .

docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest

```

For front end
```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve

docker build -t $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve-frontend:latest -f ./frontend/Dockerfile.prod  ./frontend

docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/langserve-frontend:latest
```

## ECS

Access terminal in a task container

```
 aws ecs execute-command \
--region eu-west-2 \
--cluster langserve-app-cluster \
--task <TASK ID> \
--container langserve-app-container \ # or ollama-container
--command "/bin/bash" \
--interactive
```
