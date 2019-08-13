# Overview
Node.js minimal hapijs service being deployed to an AWS kubernetes cluster using gitlab ci.

* Using a docker registry hosted in AWS ECR (see ci-before-script to be replaced for docker login when using a different registry)

## Env variables

 * DOCKER_REGISTRY - docker registry url
 * K8S_CONFIG - kube config encoded in base64
 * SERVICE_HOST - (domain where you want to expose the service e.g. node.example.com)
 * AWS_DEFAULT_REGION
 * AWS_ACCESS_KEY_ID
 * AWS_SECRET_ACCESS_KEY

 ## Optimized to be fast

 * [gitlab-ci using custom docker image](https://github.com/borjatur/custom-gitlab-ci-docker-image) (image: borjatur/images:custom-gitlab-ci-latest) built to speed up gitlab-ci stages as it's bundling packages used during all ci stages
 * lint and test are being run in the same stage to take advantage of just one docker pull

 ## Why I'm using sha256 docker image instead of a tag?

 See https://github.com/kubernetes/kubernetes/issues/33664