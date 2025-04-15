#!/bin/bashsh

# Check if repository URL is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <git-repository-url>"
    exit 1
fi

REPO_NAME=$1
REPO_URL=https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/${REPO_NAME}

git clone --depth=1 --bare --no-single-branch "$REPO_URL" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to clone repository"
    exit 1
fi

cd ${REPO_NAME}.git

# Get the latest commit date from all branches
LATEST_COMMIT_DATE=$(git log --all --pretty=format:"%cd" --date=iso | head -n 1)

N_DAY_AGO=$(date -v -10d +"%Y-%m-%d %H:%M:%S %z")
cd ..
rm -rf ${REPO_NAME}.git

# compare LATEST_COMMIT_DATE with N_DAY_AGO
if [[ "$LATEST_COMMIT_DATE" > "$N_DAY_AGO" ]]; then
    echo "Recent changes found (within last 10 days)"
    exit 0
else
    echo "No recent changes (older than 10 days)"
    exit 1
fi
