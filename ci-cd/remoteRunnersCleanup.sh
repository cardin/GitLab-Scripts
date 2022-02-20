#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

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

# Get runners
runners_resp=$(curl --request GET --silent --insecure \
    "$GITLAB_URL/api/v4/runners?per_page=100" \
    --header "Authorization: Bearer $TOKEN_PERSONAL")

runners_num=$(echo "$runners_resp" | jq length)
if [[ $runners_num -gt 0 ]]; then
    echo "All Runners"
    echo "$(echo "$runners_resp" | jq .[] )"
    echo "======================"
else
    echo "There are no runners"
    exit
fi

# Delete offline runners
runners_offline=$(echo "$runners_resp" | jq "[.[] | select(.status==\"offline\")]")
runners_num=$(echo "$runners_offline" | jq length)
if [[ $runners_num -gt 0 ]]; then
    echo "Offline Runners"
    echo "$(echo "$runners_offline" | jq .[] )"
    read -n 1 -s -r -p "Press any key to continue"
    echo ""
    echo "======================"

    runner_ids_offline=$(echo "$runners_offline" | jq ".[] | .id")
    for runner_id_offline in $runner_ids_offline; do
        echo $(delete_runner $runner_id_offline)
    done
else
    echo "There were no offline runners"
fi

# Delete unconnected runners
unconnected_runners=$(echo "$runners_resp" | jq "[.[] | select(.status==\"not_connected\",.online==\"null\")]")
unconnected_runners_num=$(echo "$runners_offline" | jq length)
if [[ $runners_num -gt 0 ]]; then
    echo "Deleting $unconnected_runners_num Unconnected Runners"
    unconnected_runner_ids=$(echo "$unconnected_runners" | jq ".[] | .id")
    for unconnected_runner_id in $unconnected_runner_ids; do
        echo $(delete_runner $unconnected_runner_id)
    done
else
    echo "There were no unconnected runners"
fi

read -n 1 -s -r -p "Press any key to continue"
echo ""
