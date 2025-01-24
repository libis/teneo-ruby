include .env
-include .env.local
export

.SILENT:

.PHONY: all publish build publish-rails build-rails

REGISTRY:=registry.docker.libis.be
TAG:=$(REGISTRY)/teneo/ruby-base:$(IMAGE_VERSION)
TAG_RAILS:=$(REGISTRY)/teneo/ruby-rails:$(IMAGE_VERSION)

all: publish publish-rails

publish: build
	docker push $(TAG)

build:
	docker buildx build --tag $(TAG)\
	 --build-arg RUBY_VERSION=$(RUBY_VERSION)\
	 --build-arg BUNDLER_VERSION=$(BUNDLER_VERSION)\
	 --build-arg GEMS_PATH=$(GEMS_PATH)\
	 .

publish-rails: build-rails
	docker push $(TAG_RAILS)

build-rails:
	docker buildx build --tag $(TAG_RAILS)\
	 -f Dockerfile.rails\
	 --build-arg IMAGE_VERSION=$(IMAGE_VERSION)\
	 .
