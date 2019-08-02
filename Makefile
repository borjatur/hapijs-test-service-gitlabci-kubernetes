lint:
	npm run lint

test:
	npm test

ci-lint:
	npm ci
	make lint

ci-test:
	npm ci
	make test

ci-before-script:
	$$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})

ci-container-build-image:
	docker build --cache-from ${CONTAINER_RELEASE_IMAGE} -t ${CONTAINER_TEST_IMAGE} .
	docker push ${CONTAINER_TEST_IMAGE}

ci-lint-test:
	docker pull ${CONTAINER_TEST_IMAGE}
	docker run ${CONTAINER_TEST_IMAGE} make ci-lint
	docker run ${CONTAINER_TEST_IMAGE} make ci-test

ci-release-image:
	docker pull ${CONTAINER_TEST_IMAGE}
	docker tag ${CONTAINER_TEST_IMAGE} ${CONTAINER_RELEASE_IMAGE}
	docker push ${CONTAINER_RELEASE_IMAGE}

ci-deploy:
	curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.7/bin/linux/amd64/kubectl
	chmod +x ./kubectl
	mv ./kubectl /usr/local/bin/kubectl
	echo ${K8S_CONFIG} | base64 -d > gitlab-config
	kubectl --kubeconfig=gitlab-config version
	sed -i "s/<DOCKER_REGISTRY>/${DOCKER_REGISTRY}/g" deployment.yml
	sed -i "s/<VERSION>/${CI_BUILD_REF}/g" deployment.yml
	kubectl --kubeconfig=gitlab-config apply -f deployment.yml

.PHONY: lint test ci-lint ci-test ci-before-script ci-container-build-image ci-lint-test ci-release-image ci-deploy