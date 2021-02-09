REGISTRY:=registry.docker.libis.be
TAG:=$(REGISTRY)/teneo/ruby-base

publish: build
	docker push $(TAG)

build:
	docker build --tag $(TAG) .
