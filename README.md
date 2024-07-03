# Git Repository Template

[Template] is a _[Git repository template]_ for bootstrapping your repositories.

[![Quality Checks](https://github.com/DynamicYield/template/actions/workflows/quality-checks.yml/badge.svg)](https://github.com/DynamicYield/template/actions/workflows/quality-checks.yml) [![Release](https://github.com/DynamicYield/template/actions/workflows/release.yml/badge.svg)](https://github.com/DynamicYield/template/actions/workflows/release.yml)

## Prerequisites

To work with this repository please [bootstrap your Mac]

## Quick Start

1. [Create a new repository based on this template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
2. Execute [`./bootstrap.sh`](./bootstrap.sh) in your new repository and follow the on-screen instructions. For details, use `./bootstrap.sh --help`.

This automates pre-commit hooks, file modifications, opens a draft pull request, and cleans up.

## Bundled Support

- [Code Owners] — Automatically requested for review when someone opens a pull request that modifies code that they own as defined in [`.github/CODEOWNERS`](.github/CODEOWNERS)

  - The first thing you should do, is **set a [team](https://github.com/DynamicYield/template/blob/master/.github/CODEOWNERS) as a code owner for the `.github/settings.yml`**.

- [gitignore] — Specifies intentionally untracked files to ignore defined in [`.gitignore`](.gitignore) based on [gitignore project]
- [ProBot Settings] — Synchronize repository settings defined in [`.github/settings.yml`](.github/settings.yml) to GitHub, enabling Pull Requests for repository settings

  When adding/removing/modifying jobs within workflows, you might need to tweak the _required status checks_ in this file; the required status checks must pass before you can merge your branch into the protected branch.

  ⚠️ Following [a bug in Settings application](https://github.com/repository-settings/app/issues/625) the [Branch protection rules](.github/settings.yml#L133-L178) are not being applied; Until a bug fix, you will have to [manage them manually](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/managing-a-branch-protection-rule)

- [Stale] — Warns and then closes issues, PRs and branches that have had no activity for a specified amount of time as defined in [`.github/workflows/stale.yml`](.github/workflows/stale.yml)
- [DependaBot] — Alerts on security vulnerabilities within the repository's dependencies, and updates the dependencies automatically as defined in [`.github/dependabot.yml`](.github/dependabot.yml)
- [RenovateBot] — Universal dependency update tool as defined in [`.github/renovate.json`](.github/renovate.json) ([RennovateBot dashboard])
- [Conventional Commits] — An easy set of rules for creating an explicit commit history; which makes it easier to write automated tools on top of. Such as generating a [changelog]
- [Semantic Release] — Automated release workflow including: determining the next [semantic version] number, generating the [release notes] and [changelog], [tagging], and more... as defined in [`.releaserc.js`](./.releaserc.js)
- [Pre-commit] — Managing and maintaining multi-language pre-commit hooks as defined in [`.pre-commit-config.yaml`](.pre-commit-config.yaml)
- [Community Health Files] — A set of predefined files that provide guidance and templates for maintaining a healthy and collaborative project

---

## Automation Features

We **strongly recommend** enabling the following features manually

### Automatically approve and merge DependaBot and RenovateBot pull requests

If you are [continuous testing], you probably want to merge the following pull request in orders:

#### First pull request

1. Add desired workflows to the list of required status checks defined in [`.github/settings.yml`](.github/settings.yml) (see an [example](https://github.com/DynamicYield/semantic-release/blob/2a260ab0eacaafd72d64f4271d4d216f721c1fda/.github/settings.yml#L153-L159))
2. If [Code Owners] is non empty, grant `devops-bots` push permissions as defined in [`.github/settings.yml`](.github/settings.yml) (see an [example](https://github.com/DynamicYield/semantic-release/blob/1b7dc998723bd2b4324685e13d86aeb94167eb97/.github/settings.yml#L126-L127))
3. Verify that `enforce_admin` is set to null (empty value) as defined in [`.github/settings.yml`](.github/settings.yml) (see an [example](https://github.com/DynamicYield/semantic-release/blob/2a260ab0eacaafd72d64f4271d4d216f721c1fda/.github/settings.yml#L163))

#### Second pull request

1. If [Code Owners] is non empty, grant `@DynamicYield/devops-bots` permissions on required paths as defined in [`.github/CODEOWNERS`](.github/CODEOWNERS) (see an [example](https://github.com/DynamicYield/semantic-release/blob/2a260ab0eacaafd72d64f4271d4d216f721c1fda/.github/CODEOWNERS#L53))
2. Set [`AUTOBOTS_TRANSFORM`](.github/workflows/quality-checks.yml) [repository secret] and [DependaBot secret] to `true`

   ```shell
   gh secret set AUTOBOTS_TRANSFORM --body "true"
   gh secret set AUTOBOTS_TRANSFORM --app dependabot --body "true"
   ```

   Or set `auto-approve-and-merge` to `true` as defined in [`.github/workflows/quality-checks.yml`](.github/workflows/quality-checks.yml)

### Code review assignment

[Code review assignments clearly indicate which members of a team are expected to submit a review for a pull request][managing-code-review-assignment-for-your-team].

### Scheduled reminders

Receive Slack reminders when your [team has pull requests waiting for review][creating-a-scheduled-reminder-for-a-team] or for [your user with real-time alerts][managing-your-scheduled-reminders].

## Syncing with the Template repository

Keep your repository up-to-date with the template git repository, execute the following from within your repository's root directory

```shell
git clone git@github.com:DynamicYield/template.git ../template
git checkout -b template-sync
rsync -ax --exclude .git --exclude README.md --exclude CHANGELOG.md --exclude bootstrap.sh ../template/ .
```

Then cherry-pick the changes you want to merge.

---

## Contributing

Interested in contributing? Review our [contributing guidelines](.github/contributing.md).

---

## Modify this README to suit the project

[template]: https://github.com/DynamicYield/template
[git repository template]: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template
[code owners]: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners#about-code-owners
[gitignore]: https://git-scm.com/docs/gitignore
[gitignore project]: https://github.com/github/gitignore
[probot settings]: https://github.com/probot/settings
[dependabot]: https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates
[renovatebot]: https://github.com/renovatebot/renovate
[rennovatebot dashboard]: https://developer.mend.io/github/DynamicYield/
[conventional commits]: https://www.conventionalcommits.org/en/v1.0.0/
[semantic release]: https://github.com/semantic-release/semantic-release
[semantic version]: https://semver.org/
[release notes]: https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
[changelog]: https://keepachangelog.com/
[tagging]: https://git-scm.com/book/en/v2/Git-Basics-Tagging
[pre-commit]: https://pre-commit.com/
[managing-code-review-assignment-for-your-team]: https://docs.github.com/en/organizations/organizing-members-into-teams/managing-code-review-assignment-for-your-team
[creating-a-scheduled-reminder-for-a-team]: https://docs.github.com/en/organizations/organizing-members-into-teams/managing-scheduled-reminders-for-your-team#creating-a-scheduled-reminder-for-a-team
[managing-your-scheduled-reminders]: https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/managing-your-membership-in-organizations/managing-your-scheduled-reminders
[bootstrap your mac]: https://github.com/DynamicYield/dev-envs#getting-started
[repository secret]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[continuous testing]: https://en.wikipedia.org/wiki/Continuous_testing
[dependabot secret]: https://docs.github.com/en/code-security/dependabot/working-with-dependabot/managing-encrypted-secrets-for-dependabot#adding-a-repository-secret-for-dependabot
[community health files]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file
