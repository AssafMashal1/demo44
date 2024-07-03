#!/usr/bin/env bash

set -Eeuo pipefail

TEAMS=''
DRY_RUN=false
REPO="$(git config --get remote.origin.url | sed -E 's/(.*\/)(.*)(\.git$)/\2/')"
SETTINGS_FILE=.github/settings.yml

function usages() {
  cat <<EOM
$(basename "$0") OPTIONS

OPTIONS:
  [-t|--teams <'name name'>]   repository teams (space delimited)
                               example: 'ninjas magicians'
                               default: ${TEAMS:-null}
  [--dry-run]                  no git push
                               default: $DRY_RUN
  [-h|--help]                  shows this help message
EOM
}

function parse_args() {
  # parse arguments
  # https://stackoverflow.com/a/33826763
  while [ $# -gt 0 ]; do
    case $1 in
    -t | --teams)
      TEAMS="$2"
      shift
      ;;
    --dry-run)
      DRY_RUN="$2"
      shift
      ;;
    -h | --help)
      usages
      true
      ;;
    *)
      usages
      false
      ;;
    esac
    shift
  done
}

function bailout() {
  # bailout on the template repository
  if [ "${REPO:-}" = "template" ]; then
    echo "$(basename "$0") should not be execute on DynamicYield/template"
    false
  fi
  true
}

function install_precommit_hooks() {
  pre-commit install --overwrite
}

function enable_automerge() {
  # enable auto-approval and auto-merge
  gh secret set AUTOBOTS_TRANSFORM --body "true"
  gh secret set AUTOBOTS_TRANSFORM --app dependabot --body "true"
}

function init_changelog() {
  cat <<EOM >CHANGELOG.md
<!-- markdownlint-disable MD001 MD004 MD012 MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
EOM
}

function init_readme() {
  echo "# $REPO" >README.md
}

function manage_teams() {
  TEAM_LIST="$(grep -E "^# @DynamicYield/" .github/CODEOWNERS | sed -E 's/(^# @DynamicYield\/)(.*)/\2/' | sort)"

  while true; do
    if [ -z "${TEAMS:-}" ]; then
      TEAMS="$(echo "$TEAM_LIST" | gum choose --header "Select your teams with a spacebar" --ordered --no-limit | tr '\n' ' ' | sed 's/ $//')"
    else
      break
    fi
  done
  for TEAM in $TEAMS; do
    if ! echo "$TEAM_LIST" | grep -q "$TEAM"; then
      echo "$TEAM team is invalid"
      false
    fi
  done

  # set repository permissions
  if ! grep -qE "^teams:$" $SETTINGS_FILE; then
    echo -e "\nteams:" >>$SETTINGS_FILE
  fi

  for TEAM in $TEAMS; do
    local CONTENT
    local CONTENT_PATTERN

    CONTENT=$(
      cat <<EOM
  - name: $TEAM
    permission: push
EOM
    )
    CONTENT_PATTERN=$(echo "$CONTENT" | tr -d '\n')
    if ! cat $SETTINGS_FILE | tr -d '\n' | grep -q -F "$CONTENT_PATTERN"; then
      echo "$CONTENT" >>$SETTINGS_FILE
    fi
  done

  # set code ownership
  TEAMS=$(echo "$TEAMS" | sed -r 's/[A-Za-z0-9-]+/@DynamicYield\/&/g')
  # shellcheck disable=SC2063
  if ! grep -q "* $TEAMS" .github/CODEOWNERS; then
    echo "* $TEAMS" >>.github/CODEOWNERS
  fi

  true
}

function enable_autolinks() {
  local AUTOLINKS
  local EXISTS

  AUTOLINKS=$(
    gh api '/repos/{owner}/{repo}/autolinks' \
      -X GET \
      -H "Accept: application/vnd.github+json"
  )
  for PREFIX in DY MCD; do
    EXISTS=$(
      echo "$AUTOLINKS" |
        jq -r --arg PREFIX "${PREFIX}-" \
          '.[] | select(.key_prefix==$PREFIX) | .key_prefix'
    )
    if [ -n "${EXISTS:-}" ]; then
      continue
    fi
    gh api '/repos/{owner}/{repo}/autolinks' \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -F is_alphanumeric=false \
      -f key_prefix="${PREFIX}-" \
      -f url_template="https://dynamicyield.atlassian.net/browse/${PREFIX}-<num>"
  done
}

function create_prs() {
  # settings pr
  git checkout master
  git checkout -b settings
  git add .github/settings.yml "$0"
  git commit -m "ci(settings): add teams" -q
  if [ "$DRY_RUN" = "false" ]; then
    git push origin "$(git branch --show-current)" -q --no-progress
    gh pr create \
      --draft \
      --base master \
      --body "# Settings / Merge this first" \
      --title "ci(settings): add teams" \
      --fill
  fi

  # codeowners pr
  git checkout master
  git checkout -b codeowners
  git add .github/CODEOWNERS
  git commit -m "ci(codeowners): add owners" -q
  if [ "$DRY_RUN" = "false" ]; then
    git push origin "$(git branch --show-current)" -q --no-progress
    gh pr create \
      --draft \
      --base master \
      --body "# Code Owners / Merge this second" \
      --title "ci(codeowners): add owners" \
      --fill
  fi

  # first release pr
  git checkout master
  git checkout -b release
  git add README.md CHANGELOG.md
  git commit -m "docs: initial commit"
  git commit --allow-empty -m "feat!: initial release"
  if [ "$DRY_RUN" = "false" ]; then
    git push origin "$(git branch --show-current)" -q --no-progress
    gh pr create \
      --draft \
      --base master \
      --body "# Initial Release / Merge this third" \
      --title "feat!: initial release" \
      --fill
  fi

  gh pr list
}

function main() {
  parse_args "$@"
  bailout
  install_precommit_hooks
  enable_automerge
  manage_teams
  init_changelog
  init_readme
  enable_autolinks
  rm -f "$0" # delete yourself
  create_prs
}

main "$@"
