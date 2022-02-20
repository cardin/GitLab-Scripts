#! /usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

#############################################
# Change these parameters
REPO_TYPE="projects" # groups or projects
REPO_ID=21
#############################################

function delete_issue {
	issue_id=$1
    
    echo "$GITLAB_URL/api/v4/$REPO_TYPE/$REPO_ID/labels/$issue_id"
	curl --request DELETE --silent --insecure \
	--header "PRIVATE-TOKEN: $TOKEN_PERSONAL" \
	"$GITLAB_URL/api/v4/$REPO_TYPE/$REPO_ID/labels/$issue_id"
}

echo "GitLab Remove..."
while [ true ]; do
    labels_resp=$(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/$REPO_TYPE/$REPO_ID/labels?per_page=100" \
        --header "Authorization: Bearer $TOKEN_PERSONAL")
    issue_ids=$(echo "$labels_resp" | jq ".[] | .id")
    labels_num=${#issue_ids[@]}
    if [ $labels_num -eq "1" ]; then
        break
    fi

    for issue_id in $issue_ids; do
        echo $(delete_issue $issue_id)
    done
done

read -n 1 -s -r -p "Press any key to continue"
echo ""
