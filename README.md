# PSRepositoryReleaseManager [![badge-version-github-tag-img][]][badge-version-github-tag-src]

[badge-version-github-tag-img]: https://img.shields.io/github/v/tag/theohbrothers/PSRepositoryReleaseManager?style=flat-square
[badge-version-github-tag-src]: https://github.com/theohbrothers/PSRepositoryReleaseManager/releases

A project for generating release notes and creating releases, such as [GitHub releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).

## Introduction

This project provides entrypoint scripts, CI templates, and PowerShell cmdlets that other projects can utilize for generating release notes and creating releases.

## Setup

`PSRepositoryReleaseManager` can be used as an [independent project](#independent-project), or as a [submodule](#submodule) for generating release notes and creating releases.

### Independent project

To use `PSRepositoryReleaseManager` as an independent project, simply perform a clone of the repository including its submodules to development or CI environment(s) prior to executing provided [entrypoint script(s)](#usage) to perform their respective functions.

```shell
# Clone PSRepositoryReleaseManager with its submodules
git clone https://github.com/theohbrothers/PSRepositoryReleaseManager.git --recurse-submodules
```

### Submodule

`PSRepositoryReleaseManager` can be used as submodule together with provided [CI remote template(s)](#ci-remote-templates).

#### Main project structure

To use `PSRepositoryReleaseManager` as a submodule, main projects are to adopt the following directory structure:

```shell
/build/                                 # Directory containing build files
/build/PSRepositoryReleaseManager/      # The root directory of PSRepositoryReleaseManager as a submodule
```

#### Adding the submodule

Add `PSRepositoryReleaseManager` as a submodule under the directory `build` in your main project:

```shell
# Add the submodule
git submodule add https://github.com/theohbrothers/PSRepositoryReleaseManager.git build/PSRepositoryReleaseManager

# Checkout submodules recursively
git submodule update --init --recursive build/PSRepositoryReleaseManager

# Checkout ref to use
git --git-dir build/PSRepositoryReleaseManager/.git checkout vx.x.x

# Commit the submodule
git commit -am 'Add submodule PSRepositoryReleaseManager vx.x.x'
```

#### CI remote templates

Decide on which CI provider to use in your main project based on those supported by this project. Then setup the CI file(s) for your main project, referencing relevant CI remote template(s) of this project from your main project's CI file(s).

Sample CI files can be found [here](docs/samples/ci).

### CI settings

 Configure the following CI settings for your main project if `PSRepositoryReleaseManager` is to be used in a CI environment, whether it be as an independent project or a submodule.

#### Secrets

##### GitHub API token

**Note:** This step is only necessary for [creating releases](#creating-releases-1) on CI environments.

Add a secret variable `GITHUB_API_TOKEN` containing your [GitHub API token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens), ensuring it has write permissions to the repository.

In the case where GitHub Actions is used for releases, the job token [`GITHUB_TOKEN`](docs/samples/ci/github/generic/github-workflows.linux-container.yml#L67) may be used for creating releases should it have write permissions to the repository.

## Usage

The project provides a set of [entrypoint scripts](src/scripts/ci) for generating release notes and creating releases for other projects, designed to be used identically in both [development](#development) and [CI environments](#continuous-integration-ci).

### Development

#### Generating release notes

The entrypoint script [`Invoke-Generate.ps1`](src/scripts/ci/Invoke-Generate.ps1) is used to generate release notes for any local git repository. To do so, simply define applicable [environment variables](#environment-variables) before executing the entrypoint script.

The project includes [`.vscode/tasks.json`](.vscode/tasks.json) which allows execution of `Invoke-Generate.ps1` via [*Build Tasks*](https://code.visualstudio.com/docs/editor/tasks) in [VSCode](https://code.visualstudio.com/). Simply execute the relevant build task while entering custom or default values per variable prompt.

##### Variants

The names of all available release notes variants that can be chosen from can be found in the module's [`generate/variants`](src/PSRepositoryReleaseManager/generate/variants) directory, and goes by the convention `<VariantName>.ps1`.

##### Valid tags

At present, generating of release notes is only possible for tags following the format `MAJOR.MINOR.PATCH`, prepended with a lowercase `v`:

```shell
# Valid tags
git tag v0.12.1
git tag v1.0.12

# Invalid tags
git tag v1.0.12-alpha
git tag v1.0.12-beta.1
```

#### Creating releases

The entrypoint script [`Invoke-Release.ps1`](src/scripts/ci/Invoke-Release.ps1) can be used to create releases for GitHub repositories. To do so, simply define applicable [environment variables](#environment-variables) before executing the entrypoint script.

The project includes [`.vscode/tasks.json`](.vscode/tasks.json) which allows execution of `Invoke-Release.ps1` via [*Build Tasks*](https://code.visualstudio.com/docs/editor/tasks) in [VSCode](https://code.visualstudio.com/). Simply execute the relevant build task while entering custom or default values per variable prompt. Note that due to the inability to enter multiline strings in build tasks, the options `RELEASE_NOTES_CONTENT` and `RELEASE_ASSETS` are presently unavailable and limited in usability respectively.

### Continuous Integration (CI)

#### via Entrypoint script(s)

The following are environment variables supported by the provided [entrypoint scripts](src/scripts/ci) for generating release notes and creating releases.

##### Environment variables

###### Generate and Release

| Name | Example value | Mandatory | Type |
|:-:|:-:|:-:|:-:|
| `PROJECT_DIRECTORY` | `/path/to/my-project` | true | string |
| `RELEASE_TAG_REF` | `vx.x.x` / `branch` / `HEAD` / `remote/branch` / commit-hash | false (Generate), true (Release) | string |

###### Generate

| Name | Example value | Mandatory | Type |
|:-:|:-:|:-:|:-:|
| `RELEASE_NOTES_VARIANT` | `VersionDate-HashSubjectAuthor-NoMerges-Categorized` ([List of available variants](src/PSRepositoryReleaseManager/generate/variants)) | false | string |
| `RELEASE_NOTES_PATH` | `.release-notes.md` (relative) /<br>`/path/to/.release-notes.md` (full) | false | string |

###### Release

| Name | Example value | Mandatory | Type |
|:-:|-|:-:|:-:|
| `RELEASE_NAMESPACE` | `mygithubnamespace` | true | string |
| `RELEASE_REPOSITORY` | `my-project` | true | string |
| `GITHUB_API_TOKEN` | `xxx` | true | string |
| `RELEASE_NAME` | `My release name` | false | string |
| `RELEASE_NOTES_CONTENT` | `My`<br><br>`multi-line`<br>`release`<br>`notes` | false | string ([multiline](https://en.wikipedia.org/wiki/Here_document)) |
| `RELEASE_DRAFT` | `true` / `false` | false | string |
| `RELEASE_PRERELEASE` | `true` / `false` | false | string |
| `RELEASE_ASSETS` | `path/to/asset1.tar.gz`<br>`path/to/asset2.gz`<br>`path/to/asset3.zip`<br>`path/to/assets/*.gz`<br>`path/to/assets/*.zip` | false | string ([multiline](https://en.wikipedia.org/wiki/Here_document)) |

##### Commands

To generate release notes and create releases, simply clone a specified *version* of the project, and define applicable [environment variables](#environment-variables) before executing the project's provided entrypoint script(s) within the CI environment.

```shell
# Clone PSRepositoryReleaseManager
git clone https://github.com/theohbrothers/PSRepositoryReleaseManager.git --recurse-submodules --branch 'vx.x.x' # Specify tag ref to checkout to

# Process applicable environment variables
export PROJECT_DIRECTORY=$( git rev-parse --show-toplevel )
export RELEASE_TAG_REF=$( echo "$GITHUB_REF" | sed -rn 's/^refs\/tags\/(.*)/\1/p' )
export RELEASE_NAMESPACE="$GITHUB_REPOSITORY_OWNER"
export RELEASE_REPOSITORY=$( basename "$( git rev-parse --show-toplevel )" )

# Generate (Generates release notes)
pwsh -c './PSRepositoryReleaseManager/src/scripts/ci/Invoke-Generate.ps1'

# Release (Creates GitHub release)
pwsh -c './PSRepositoryReleaseManager/src/scripts/ci/Invoke-Release.ps1'
```

**Note:** Ensure the environment variable [`GITHUB_API_TOKEN`](#github-api-token) is defined prior to creating releases.

Sample CI files demonstrating use of this approach can be found [here](docs/samples/ci/github/generic).

#### via Submodule and CI templates

##### Generating release notes

To generate release notes, reference the appropriate [`generate.yml`](templates/azure-pipelines/entrypoint) entrypoint CI remote template provided by this project from your main project's CI file. The `generate.yml` templates also support the following [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.generate-params.yml#L4-#L7) for customizing the generation of release notes.

Generation of release notes is presently *limited* to the module's [valid tags pattern](#valid-tags).

##### Creating releases

**Note:** Ensure your main project's CI file(s) and/or settings are configured to run CI jobs for tag refs, and that the environment variable [`GITHUB_API_TOKEN`](#github-api-token) is defined prior to creating releases.

To create releases, reference the appropriate [`release.yml`](templates/azure-pipelines/entrypoint) entrypoint CI remote template provided by this project from your main project's CI file. The `release.yml` templates also support the following [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.release-params.yml#L4-#L21) for customizing the creation of releases.

Releases supports all tag refs. Tags *need not* follow [Semantic Versioning](https://semver.org/) though the convention is recommended.

## Maintenance

### Managing the submodule

#### Retrieving updates

To update the submodule:

```shell
git submodule update --remote --recursive build/PSRepositoryReleaseManager
```

#### Using a specific tag

To use a specific tag of the submodule:

```shell
# Checkout ref to use
git --git-dir build/PSRepositoryReleaseManager/.git checkout vx.x.x

# Bump PSRepositoryReleaseManager to the same ref in CI file
vi azure-pipelines.yml

# Commit the submodule and CI file
git commit -am 'Bump PSRepositoryReleaseManager to vx.x.x'
```

## Best practices

- Use only tag refs of `PSRepositoryReleaseManager` in your main project.
- If using the project [via Submodule and CI templates](#via-submodule-and-ci-templates), ensure your main project's CI file(s) is configured to use a [tag ref](docs/samples/ci/azure-pipelines/generic/azure-pipelines.linux-container.yml#L19) of `PSRepositoryReleaseManager` for its CI remote templates, and that the ref matches that of the `PSRepositoryReleaseManager` submodule used in your main project.
