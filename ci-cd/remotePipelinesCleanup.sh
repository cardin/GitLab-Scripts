#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

MAX_FAILED_PIPES=10

get_project_ids_under_group() {
    GRP_ID=$1

    resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/groups/$GRP_ID/projects?include_subgroups=True&per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    project_ids=$(echo "$resp" | jq ".[] | .id")
    echo $project_ids
}
delete_invalid_skipped_canceled() {
    PROJ_ID=$1

    # invalid
    resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines?yaml_errors=true&per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    pipe_ids=$(echo "$resp" | jq -c "[.[] | .id]")
    pipe_id_len=$(echo "$pipe_ids" | jq length)

    if [[ $pipe_id_len -gt 0 ]]; then
        echo "$PROJ_ID: Deleting $pipe_id_len invalid pipelines"
        for pipe_id in $(echo "$pipe_ids" | jq -c ".[]"); do
            echo $(curl --request DELETE --silent --insecure \
                "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines/$pipe_id" \
                --header "Authorization: Bearer $TOKEN_PERSONAL")
        done
    fi

    # canceled
    resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines?status=canceled&per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    pipe_ids=$(echo "$resp" | jq -c "[.[] | .id]")
    pipe_id_len=$(echo "$pipe_ids" | jq length)

    if [[ $pipe_id_len -gt 0 ]]; then
        echo "$PROJ_ID: Deleting $pipe_id_len canceled pipelines"
        for pipe_id in $(echo "$pipe_ids" | jq -c ".[]"); do
            echo $(curl --request DELETE --silent --insecure \
                "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines/$pipe_id" \
                --header "Authorization: Bearer $TOKEN_PERSONAL")
        done
    fi
    
    # skipped
    resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines?status=skipped&per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    pipe_ids=$(echo "$resp" | jq -c "[.[] | .id]")
    pipe_id_len=$(echo "$pipe_ids" | jq length)

    if [[ $pipe_id_len -gt 0 ]]; then
        echo "$PROJ_ID: Deleting $pipe_id_len skipped pipelines"
        for pipe_id in $(echo "$pipe_ids" | jq -c ".[]"); do
            echo $(curl --request DELETE --silent --insecure \
                "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines/$pipe_id" \
                --header "Authorization: Bearer $TOKEN_PERSONAL")
        done
    fi

}
delete_failed() {
    PROJ_ID=$1

    resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines?order_by=updated_at&sort=asc&status=failed&per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    pipe_ids=$(echo "$resp" | jq -c ".[:-$MAX_FAILED_PIPES] | [.[] | .id]")
    pipe_id_len=$(echo "$pipe_ids" | jq length)

    if [[ $pipe_id_len -gt 0 ]]; then
        echo "$PROJ_ID: Deleting $pipe_id_len failed pipelines"
        for pipe_id in $(echo "$pipe_ids" | jq -c ".[]"); do
            echo $(curl --request DELETE --silent --insecure \
                "$GITLAB_URL/api/v4/projects/$PROJ_ID/pipelines/$pipe_id" \
                --header "Authorization: Bearer $TOKEN_PERSONAL")
        done
    fi
}
per_group() {
    GRP_ID=$1
    GRP_NAME=$2

    project_ids="$(get_project_ids_under_group $GRP_ID)"
    echo "========================================"
    echo "Deleting Invalid/Skipped/Canceled Pipelines for Group $GRP_NAME..."
    for project_id in $project_ids; do
        echo "$(delete_invalid_skipped_canceled $project_id)"
        echo "$(delete_failed $project_id)"
    done
}

for list in "${TOKENS_CICD[@]}";
do
    IFS=' ' read -r -a item <<< "$list"
    echo "$(per_group "${item[1]}" "${item[0]}")"
done
