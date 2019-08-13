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
	docker pull ${CONTAINER_RELEASE_IMAGE}
	docker build --cache-from ${CONTAINER_RELEASE_IMAGE} -t ${CONTAINER_TEST_IMAGE} .
	docker push ${CONTAINER_TEST_IMAGE}

ci-lint-test:
	docker pull ${CONTAINER_TEST_IMAGE}
	docker run ${CONTAINER_TEST_IMAGE} make ci-lint
	docker run ${CONTAINER_TEST_IMAGE} make ci-test

ci-clean-image:
	docker rmi $(docker images ${CONTAINER_TEST_IMAGE} -q)

ci-release-image:
	docker pull ${CONTAINER_TEST_IMAGE}
	docker tag ${CONTAINER_TEST_IMAGE} ${CONTAINER_RELEASE_IMAGE}
	docker push ${CONTAINER_RELEASE_IMAGE}

ci-deploy:
	@echo ${K8S_CONFIG} | base64 -d > gitlab-config
	DOCKER_RELEASE_SHA=$(shell aws ecr describe-images --repository-name ${POS_APP_NAME} --image-ids imageTag=production | jq .imageDetails[].imageDigest | xargs) \
	envsubst < deployment.yml | kubectl --kubeconfig=gitlab-config apply -f -

ci-rollback:
	@echo ${K8S_CONFIG} | base64 -d > gitlab-config
	kubectl --kubeconfig=gitlab-config rollout undo deployment/${POS_APP_NAME}

.PHONY: lint test ci-lint ci-test ci-before-script ci-container-build-image ci-lint-test ci-clean-image ci-release-image ci-deploy ci-rollback