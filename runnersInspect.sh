#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

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

while [ true ]; do
    read -p "Key in an ID number. (Leave empty to exit): " selected_id
    echo ""

    if [[ -z $selected_id ]]; then
        exit
    fi

    echo $(curl --request GET --silent --insecure \
        "$GITLAB_URL/api/v4/runners/$selected_id" \
        --header "Authorization: Bearer $TOKEN_PERSONAL") | jq .
done
