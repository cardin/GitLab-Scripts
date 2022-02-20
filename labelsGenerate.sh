#! /usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/include.sh

################################################
# Change these parameters
REPO_TYPE="groups" # groups or projects
REPO_ID=13
################################################

# Colors
RED="#FC6868"
ORANGE="#FFC791"
LAVENDER="#F4E5F9"
GRAY="#F1F1F1"

BLUE="#92D2F0"
GRASS="#B8E881"
SKY="#E4F1F2"

function createLabel {
	name=$1
	color=$2
	description=$3
	priority=$4

	curl --data "name=$name&color=$color&description=$description&priority=$priority" \
	--header "PRIVATE-TOKEN: $TOKEN_PERSONAL" \
	--insecure \
	"$GITLAB_URL/api/v4/$REPO_TYPE/$REPO_ID/labels"
}

# Label Classifiers are alphabetical
# so the most important classifiers appear earlier
createLabel "Impt: 1" $RED "High Visibility and Urgent" 1
createLabel "Impt: 2" $ORANGE "Moderate Visibility and Urgent" 2
createLabel "Impt: 3" $LAVENDER "Low Visiblility but Impactful" 3
createLabel "Impt: 4" $GRAY "Good-to-Have" 4

createLabel "Epic" $GRASS "Grouping of Issues, e.g. User Stories" "null"

createLabel "Issue: Bug" $RED "Unintended behavior" "null"
createLabel "Issue: Dep" $BLUE "Dependencies for software, runtimes, modules, etc." "null"
createLabel "Issue: Feature" $GRASS "Addition of something that didn't exist" "null"
createLabel "Issue: Maintenance" $BLUE "QoL changes, e.g. refactoring, documenting, testing" "null"
createLabel "Issue: Question" $BLUE "Questions or Discussions" "null"

createLabel "Status: Blocked" $LAVENDER "" "null"
createLabel "Status: Duplicate" $LAVENDER "" "null"
createLabel "Status: Unreproducible" $LAVENDER "" "null"
createLabel "Status: WontFix" $LAVENDER "" "null"

createLabel "Whr: Env" $SKY "E.g. HW, OS, Env Vars" "null"
createLabel "Whr: Frontend" $SKY "E.g. Client-Facing" "null"
createLabel "Whr: Backend" $SKY "E.g. Pipeline, Services, Code, Algorithms" "null"
createLabel "Whr: Data" $SKY "E.g. Database, Data Source" "null"
createLabel "Whr: DevOps" $SKY "E.g. Build, Test, Deploy, Monitoring" "null"
