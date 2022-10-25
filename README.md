# PSRepositoryReleaseManager [![badge-version-github-tag-img][]][badge-version-github-tag-src]

[badge-version-github-tag-img]: https://img.shields.io/github/v/tag/theohbrothers/PSRepositoryReleaseManager?style=flat-square
[badge-version-github-tag-src]: https://github.com/theohbrothers/PSRepositoryReleaseManager/releases

A project for managing repository releases, such as [GitHub releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/about-releases).

## Introduction

This project provides CI templates and scripts that other projects can utilize for managing releases.

### Main project structure

`PSRepositoryReleaseManager` requires main projects to adopt the following directory structure:

```shell
/build/                                         # Directory containing build files
/build/PSRepositoryReleaseManager/              # The root directory of PSRepositoryReleaseManager as a submodule
```

## Configuration

### Main project

Configure the following components on your main project.

#### Submodule

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

Configure the following CI settings for your project.

#### Secrets

##### GitHub API token

**Note:** This step is only necessary for [creating releases](#releases-1) on CI environments.

Add a secret variable `GITHUB_API_TOKEN` containing your [GitHub API token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token), ensuring it has write permissions to the repository.

## Usage

### Development

#### Generating release notes

The entrypoint script [`Invoke-Generate.ps1`](src/scripts/dev/Invoke-Generate.ps1) is used to generate release notes based off local repositories. To generate one, specify the path to the local repository and the variant of release notes to generate.

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

#### Releases

The entrypoint script [`Invoke-Release.ps1`](src/scripts/dev/Invoke-Release.ps1) can be used to create or simulate the creation of releases for GitHub repositories. Fill in all relevant values pertaining to the release, and if desired, the path to the file containing the release notes to include with it.

### Continuous Integration

The included CI files use a very similar set of [entrypoint scripts](src/scripts/ci) to the development versions to run the very same steps of generating release notes and creating releases.

#### Generating release notes

To generate release notes, reference the appropriate `generate.yml` entrypoint CI template provided by this project from your CI file. The **generate** step can also be customized through provided [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.generate.yml#L4-#L7).

Generation of release notes are limited to the module's [valid tags](#valid-tags) [pattern](src/PSRepositoryReleaseManager/Private/Get-RepositoryReleasePrevious.ps1#L17).

#### Releases

**Note:** Ensure your main project's CI file(s) and/or settings are configured to run CI jobs for tag refs.

To create releases, reference the appropriate `release.yml` entrypoint CI template provided by this project from your CI file. The **release** step can also be customized through provided [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.release.yml#L4-#L20).

Releases supports all tag refs. Tags *need not* follow [Semantic Versioning](https://semver.org/) though the convention is recommended.

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
