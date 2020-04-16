#!/usr/bin/env bash

echo "Start..."
echo "Workflow: $GITHUB_WORKFLOW"
echo "Action: $GITHUB_ACTION"
echo "Actor: $GITHUB_ACTOR"
echo "Repository: $GITHUB_REPOSITORY"
echo "Event-name: $GITHUB_EVENT_NAME"
echo "Event-path: $GITHUB_EVENT_PATH"
echo "Workspace: $GITHUB_WORKSPACE"
echo "SHA: $GITHUB_SHA"
echo "REF: $GITHUB_REF"
echo "HEAD-REF: $GITHUB_HEAD_REF"
echo "BASE-REF: $GITHUB_BASE_REF"
pwd

RESULT=0

# Check the input parameter
echo
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo -e "\e[0;34mToken is empty. Review PR without comments.\e[0m"
else
    echo -e "\e[0;34mReview PR with comments.\e[0m"
fi

# Get commit list using Github API
echo
echo -e "\e[0;34mGet the list of commits included in the PR($GITHUB_REF).\e[0m"
PR=${GITHUB_REF#"refs/pull/"}
PRNUM=${PR%"/merge"}
URL=https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${PRNUM}/head
echo " - API endpoint: $URL"

list=$(curl $URL -X GET -s | jq '.[].sha' -r)
len=$(echo "$list" | wc -l)
echo " - heads $len: $list"

# Run review.sh on the PR's head
echo
echo -e "\e[0;34mStart review for head.\e[0m"

i=1
for sha1 in $list; do
    echo "-------------------------------------------------------------"
    echo -e "[$i/$len] Check head - \e[1;34m$sha1\e[0m"
    echo "-------------------------------------------------------------"
    /review.sh ${sha1} || RESULT=1;
    echo
    ((i++))
done

echo -e "\e[1;34mDone\e[0m"

exit $RESULT