# hit a github API endpoint to verify that a user is a collaborator in cwpearson/ci-dummy.sh

# The API endpoint is documented here:
# https://docs.github.com/en/rest/collaborators/collaborators?apiVersion=2022-11-28#check-if-a-user-is-a-repository-collaborator
# the Authorization value is a fine-grained personal access token with repository metadata read access
# this will return 204 for a collaborator, or 404 otherwise

# Variables for this script: https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables

REPO_SLUG=cwpearson/ci-dummy

echo GITHUB_EVENT_NAME="$GITHUB_EVENT_NAME"
if [[ -f "$GITHUB_EVENT_PATH" ]]; then
  echo "GITHUB_EVENT_PATH contents:"
  cat "$GITHUB_EVENT_PATH"
fi

# -w tells bash to print the http response code after the response
# -s means silent
response=$(curl \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer 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" \
-H "X-GitHub-Api-Version: 2022-11-28" \
-s \
https://api.github.com/repos/"$REPO_SLUG"/collaborators/"$GITHUB_ACTOR" -w "\n%{http_code}"
)

# since the response is printed after a newline, grab just the code with the last line
code=$(echo "$response" | tail -n1)

# expect the code to be 204 (collaborator), 404 (not).
if [[ "$code" == "204" ]]; then
  echo "$GITHUB_ACTOR" is a collaborator for "$REPO_SLUG"
  exit 0
elif [[ "$code" == "404" ]]; then
  echo "$GITHUB_ACTOR" is NOT a collaborator for "$REPO_SLUG". Job will not be run!
  exit 1
else
  echo Unxpected response from Github when checking if "$GITHUB_ACTOR" is a collaborator for "$REPO_SLUG": "$response"
  exit 1
fi

# if we somehow make it this far, it's an error
exit 1
