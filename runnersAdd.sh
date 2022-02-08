#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

set -e

create_docker() {
	VOL=$1

	if [[ ! -f "$GITLAB_HOSTNAME.crt" ]]; then
		echo "Cert $GITLAB_HOSTNAME.crt is missing! Run certDownload.sh first!"
		exit 1
	fi

	docker run -d --name "gl-runner-$(hostname)" --restart unless-stopped \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $VOL:/etc/gitlab-runner \
		gitlab/gitlab-runner:latest
	docker cp "$GITLAB_HOSTNAME.crt" "gl-runner-$(hostname)":"/etc/gitlab-runner/certs/"
}

register() {
	NAME=$1
	VOL=$2
	TOKEN=$3

	# https://docs.gitlab.com/ee/ci/yaml/gitlab_ci_yaml.html

	# `url` must be 1st
	# `registration-token` must be 2nd
	# Executor configs must be before `executor`
	# `run-untagged` must be before `tag-list`

	# boolean fields must have the format (="true")
	# group runners cannot be shared
	# runners can be multi-registered (https://gitlab.com/gitlab-org/gitlab/-/issues/23722)

	echo "Registering for $NAME"
	docker run --rm -it \
		-v $VOL:/etc/gitlab-runner \
		gitlab/gitlab-runner:latest register \
		--non-interactive \
		--url $GITLAB_URL \
		--registration-token $TOKEN \
		--name "$NAME-$(hostname)" \
		--tag-list "linux, docker, cuda, gpu, sonarqube" \
		--docker-image "alpine:latest" \
		--docker-gpus "all" \
		--docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
		--docker-pull-policy="always" \
  		--docker-pull-policy="if-not-present" \
		--executor "docker" \
		--run-untagged="true" \
		--locked="false"
	echo "=================="
}

create_docker $VOL

for list in "${TOKENS_CICD[@]}";
do
	IFS=' ' read -r -a item <<< "$list"
	register "${item[0]}" $VOL "${item[2]}"
done


read -n 1 -s -r -p "Press any key to continue"
echo ""
