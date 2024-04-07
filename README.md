# Deploying a chat bot

This project was used to learn how to deploy a web app on aws, using IaC (Terraform) and Docker

Architecture: https://miro.com/app/board/uXjVKaHvfVM=/

## Some useful dev commands

Install pre-commit hook
```
pre-commit install
```

### Run locally

```
docker-compose up
```


### Build and push images to ECR

```
sh scripts/build-push.sh
```

### Deploy all services
```
sh scripts/deploy-all.sh
```

### Debugging

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


## Infra

Infra not managed by terraform
- The Route 53 hosted zone

Outstanding Questions
- How do albs access private subnets
- Do you need nginx and alb, whats the difference
- Route 53 points to albs, which have https listeners, but the alb dns is still callable in browser over http, how?
