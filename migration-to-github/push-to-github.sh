#!/bin/bash
set -e
# set -x  # debug

repo=$1
base_url="https://git-codecommit.eu-west-1.amazonaws.com/v1/repos"
export ORG="bst-ai"
log_file="log_file.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting $repo" | tee -a "$log_file"

# retry commands with backoff
retry_command() {
  local cmd="$1"
  local max_attempts=5
  local attempt=1
  local delay=30  # avoid rate limit

  while [ $attempt -le $max_attempts ]; do
    if eval "$cmd" > /dev/null 2>&1; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - $cmd succeeded" | tee -a "$log_file"
      return 0
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Attempt $attempt/$max_attempts failed: $cmd" | tee -a "$log_file"
      if [ $attempt -eq $max_attempts ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Final failure: $cmd" | tee -a "$log_file"
        return 1
      fi
      sleep $((delay * attempt))  # backoff multiplied by the attempt: 30s, 60s, 90s, etc.
      ((attempt++))
    fi
  done
}

# if repo already exists on GitHub
check_repo_exists() {
  # GitHub API to check if the repo exists (HTTP 200 = exists, 404 = not found)
  if gh api -H "Accept: application/vnd.github+json" "repos/$ORG/$repo" >/dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Repo $repo already exists on GitHub, skipping" | tee -a "$log_file"
    exit 0
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Repo $repo does not exist on GitHub, proceeding" | tee -a "$log_file"
  fi
}

# Clean up
cleanup() {
  rm -rf "${repo}.git"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleaned up ${repo}.git" | tee -a "$log_file"
}
trap cleanup EXIT

# Main migration logic
check_repo_exists

echo "$(date '+%Y-%m-%d %H:%M:%S') - Cloning $repo from CodeCommit" | tee -a "$log_file"
retry_command "git clone --quiet --mirror ${base_url}/${repo}" || {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to clone $repo" | tee -a "$log_file"
  exit 1
}

cd "${repo}.git" || {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to enter ${repo}.git" | tee -a "$log_file"
  exit 1
}

default_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
export GITHUB_URL="https://github.com/${ORG}/${repo}.git"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Creating GitHub repo $repo" | tee -a "$log_file"
retry_command "gh repo create ${ORG}/${repo} --private" || {
  # Double-check if it exists after failure (race condition or rate limit)
  if gh api -H "Accept: application/vnd.github+json" "repos/$ORG/$repo" >/dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Repo $repo exists after creation attempt, proceeding" | tee -a "$log_file"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to create GitHub repo $repo" | tee -a "$log_file"
    exit 1
  fi
}

echo "$(date '+%Y-%m-%d %H:%M:%S') - Pushing $repo to GitHub" | tee -a "$log_file"
git remote remove origin > /dev/null 2>&1
git remote add origin "$GITHUB_URL"
retry_command "git push --mirror" || {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to push $repo" | tee -a "$log_file"
  exit 1
}

echo "$(date '+%Y-%m-%d %H:%M:%S') - Setting default branch to $default_branch" | tee -a "$log_file"
retry_command "gh api --silent -X PATCH -H 'Accept: application/vnd.github+json' /repos/${ORG}/${repo} -f default_branch=${default_branch}" || {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to set default branch for $repo" | tee -a "$log_file"
  exit 1
}

echo "$(date '+%Y-%m-%d %H:%M:%S') - Done with $repo" | tee -a "$log_file"