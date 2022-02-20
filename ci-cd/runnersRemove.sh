#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

docker_remove() {
    NAME=$1
    VOL=$2

    docker run --rm -it -v $VOL:/etc/gitlab-runner \
        gitlab/gitlab-runner:latest unregister --all-runners
    docker stop $NAME
    docker rm $NAME
}

delete_runner() {
    id=$1

    # Disable Runner from Projects
    detailed_infos=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/runners/$id?per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    dep_infos=$(echo "$detailed_info" | jq ".projects | [.[] | {id:.id, name:.name}]")

    for dep_info in $(echo "$dep_infos" | jq -c ".[]"); do
        proj_name=$(echo "$dep_info" | jq .name)
        proj_id=$(echo "$dep_info" | jq .id)
        echo "Disabling Project $proj_name from Runner $id"
        echo $(curl --request DELETE -i --silent --insecure \
            "$GITLAB_URL/api/v4/projects/$proj_id/runners/$id" \
            --header "Authorization: Bearer $TOKEN_PERSONAL")
    done

    # Remove Runner
    echo -e "Deleting Runner $id"
    echo $(curl --request DELETE -i --silent --insecure \
        "$GITLAB_URL/api/v4/runners/$id" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
}

echo "Docker Remove..."
docker_remove "gl-runner-$(hostname)" $VOL

# Get runners
echo "GitLab Remove..."
runners_resp=$(curl --request GET --silent --insecure \
    "$GITLAB_URL/api/v4/runners?per_page=100" \
    --header "Authorization: Bearer $TOKEN_PERSONAL")
runners=$(echo "$runners_resp" | jq "[.[] | select(.description | contains(\"$(hostname)\"))]")
runner_ids=$(echo "$runners" | jq ".[] | .id")
for runner_id in $runner_ids; do
    echo $(delete_runner $runner_id)
done

read -n 1 -s -r -p "Press any key to continue"
echo ""
