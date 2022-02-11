#!/usr/bin/env bash
# https://docs.gitlab.com/runner/configuration/tls-self-signed.html#supported-options-for-self-signed-certificates-targeting-the-gitlab-server
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

get_self_signed_cert() {
	GITLAB_HOSTNAME=$1
	openssl s_client -showcerts -connect $GITLAB_HOSTNAME:443 < /dev/null 2>/dev/null \
		| openssl x509 -outform PEM > $GITLAB_HOSTNAME.crt
}
get_self_signed_cert $GITLAB_HOSTNAME

echo | openssl s_client -CAfile $GITLAB_HOSTNAME.crt -connect $GITLAB_HOSTNAME:443

echo "If you get 'Verify return code: 21 (unable to verify the first certificate)', \
make sure you are using the latest OpenSSL version"