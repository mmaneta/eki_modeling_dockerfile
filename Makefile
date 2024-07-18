
SHELL = /bin/bash
IMAGE = eki
TAG ?=dev
REGION = $(shell aws configure get region)
AWS_ACCOUNT_ID = 054507568115
REPO =eki
 
build:
	DOCKER_BUILDKIT=1 && export DOCKER_BUILDKIT && \
	docker build -f Dockerfile -t $(IMAGE):$(TAG) --ssh=default . 

run:	build
	@docker run --rm -it --platform linux/amd64 $(IMAGE):$(TAG)

push_aws: check-tag
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
	docker tag $(IMAGE):$(TAG) $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(TAG)
	docker push  $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(TAG)

pull_aws: check-tag
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
	docker pull $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(TAG)

run_aws: pull_aws
	@docker run --rm -it $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO):$(TAG) bash

jupyter-lab: build
	docker run --rm -it -v .:/home/eki -p 8888:8888 -p 8889:8889 -u 0 mf6:dev jupyter-lab --no-browser --ip=0.0.0.0 --allow-root

	
.PHONY:	build run push_aws pull_aws jupyter-lab check-tag

check-tag:
ifndef TAG
	$(error TAG needs to be set)
endif
