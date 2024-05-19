# PSRepositoryReleaseManager [![badge-version-github-tag-img][]][badge-version-github-tag-src]

[badge-version-github-tag-img]: https://img.shields.io/github/v/tag/theohbrothers/PSRepositoryReleaseManager?style=flat-square
[badge-version-github-tag-src]: https://github.com/theohbrothers/PSRepositoryReleaseManager/releases

A project for managing repository releases, such as [GitHub releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/about-releases).

## Introduction

This project provides CI templates, scripts, and cmdlets that other projects can utilize for generating release notes and creating releases.

## Setup

`PSRepositoryReleaseManager` can be used as an [independent project](#independent-project), or as [a submodule](#submodule) for generating release notes and creating releases.

### Independent project

To use `PSRepositoryReleaseManager` as an independent project, simply clone a copy of the repository including its submodules to development or CI environment(s) prior to executing [generate and release steps](#usage).

```shell
# Clone the repository with its submodules
git clone https://github.com/theohbrothers/PSRepositoryReleaseManager.git --recurse-submodules
```

### Submodule

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

#### CI files

Decide on which CI provider to use in your main project based on those supported by this project. Setup the CI file(s) for your main project. Then simply reference the relevant CI files of this project from your main project's CI file(s).

Sample CI files can be found [here](docs/samples/ci).

### CI settings

Configure the following CI settings for your main project if `PSRepositoryReleaseManager` is to be used in a CI environment.

#### Secrets

##### GitHub API token

**Note:** This step is only necessary for [creating releases](#releases-1) on CI environments.

Add a secret variable `GITHUB_API_TOKEN` containing your [GitHub API token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token), ensuring it has write permissions to the repository.

## Usage

### Development

#### Generating release notes

The entrypoint script [`Invoke-Generate.ps1`](src/scripts/ci/Invoke-Generate.ps1) is used to generate release notes based off local repositories. To generate one, specify the path to the local repository, the release tag ref, the release notes variant, and the release notes path.

The project also includes [`.vscode/tasks.json`](.vscode/tasks.json) which allows invocation of `Invoke-Generate.ps1` via [*Build Tasks*](https://code.visualstudio.com/docs/editor/tasks) in [VSCode](https://code.visualstudio.com/). Simply execute the relevant build task while entering custom or default values per variable prompt.

##### Variants

The names of all release notes variants that can be generated can be found in the module's [`generate/variants`](src/PSRepositoryReleaseManager/generate/variants) directory and goes by the convention `<VariantName>.ps1`.

##### Valid tags

At present, generation of release notes is only possible for tags of the format `MAJOR.MINOR.PATCH`, prepended with a lowercase `v`:

```shell
# Valid tags
git tag v0.12.1
git tag v1.0.12

# Invalid tags
git tag v1.0.12-alpha
git tag v1.0.12-beta.1
```

#### Creating releases

The entrypoint script [`Invoke-Release.ps1`](src/scripts/ci/Invoke-Release.ps1) can be used to create or simulate the creation of releases for GitHub repositories. Simply specify the relevant values pertaining to the release, and if desired, the path to the file containing the release notes to include with it.

### Continuous Integration (CI)

The project provides a set of [entrypoint scripts](src/scripts/ci) for executing the very same steps for generating release notes and creating releases in CI environments.

#### via Templates

##### Generating release notes

To generate release notes, reference the appropriate `generate.yml` entrypoint CI template provided by this project from your CI file. The **generate** step can also be customized through provided [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.generate.yml#L4-#L7).

Generation of release notes is presently *limited* to the module's [valid tags pattern](#valid-tags).

##### Creating releases

**Note:** Ensure your main project's CI file(s) and/or settings are configured to run CI jobs for tag refs.

To create releases, reference the appropriate `release.yml` entrypoint CI template provided by this project from your CI file. The **release** step can also be customized through provided [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.release.yml#L4-#L21).

Releases supports all tag refs. Tags *need not* follow [Semantic Versioning](https://semver.org/) though the convention is recommended.

#### via Entrypoint script(s)

##### Environment variables

###### Generate and Release

| Name | Example value | Mandatory | Type |
|:-:|:-:|:-:|:-:|
| `PROJECT_DIRECTORY` | `/path/to/my-project` | true | string |
| `RELEASE_TAG_REF` | `vx.x.x` / `branch` / `HEAD` / `remote/branch` / commit-hash | false (Generate), true (Release) | string |

###### Generate

| Name | Example value | Mandatory | Type |
|:-:|:-:|:-:|:-:|
| `RELEASE_NOTES_VARIANT` | `VersionDate-HashSubject-NoMerges` ([List of available variants](src/PSRepositoryReleaseManager/generate/variants)) | false | string |
| `RELEASE_NOTES_PATH` | `/path/to/.release-notes.md` (full) /<br>`.release-notes.md` (relative) | false | string |

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

Simply populate applicable environment variables values prior to executing provided entrypoint script(s) within the CI environment to perform their respective functions.

```shell
# Clone project
git clone https://github.com/theohbrothers/PSRepositoryReleaseManager.git --recurse-submodules ../PSRepositoryReleaseManager

# Process applicable environment variables (e.g.)
export PROJECT_DIRECTORY=$(git rev-parse --show-toplevel)
export RELEASE_NAMESPACE="$GITHUB_REPOSITORY_OWNER"
export RELEASE_REPOSITORY=$(basename "$(git rev-parse --show-toplevel)")

# Generate (Generates release notes)
pwsh -c './../PSRepositoryReleaseManager/src/scripts/ci/Invoke-Generate.ps1'

# Release (Creates GitHub release)
pwsh -c './../PSRepositoryReleaseManager/src/scripts/ci/Invoke-Release.ps1'
```

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
- Ensure your main project's CI file(s) is configured to use the CI templates of `PSRepositoryReleaseManager` and that the ref used matches that of the `PSRepositoryReleaseManager` submodule used in your main project.
