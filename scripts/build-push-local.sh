aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 972518559371.dkr.ecr.eu-west-2.amazonaws.com/langserve

docker build -t 972518559371.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest .

docker push 972518559371.dkr.ecr.eu-west-2.amazonaws.com/langserve:latest
