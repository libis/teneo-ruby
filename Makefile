.SILENT:

.PHONY: all publish build publish-rails build-rails

REGISTRY:=registry.docker.libis.be
TAG:=$(REGISTRY)/teneo/ruby-base
TAG_RAILS:=$(REGISTRY)/teneo/ruby-rails

all: publish publish-rails

publish: build
	docker push $(TAG)

build:
	docker build --tag $(TAG) .

publish-rails: build-rails
	docker push $(TAG_RAILS)

build-rails:
	docker build --tag $(TAG_RAILS) -f Dockerfile.rails .
