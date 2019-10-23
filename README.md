# PSRepositoryReleaseManager [![badge-version-github-tag-img][]][badge-version-github-tag-src]

[badge-version-github-tag-img]: https://img.shields.io/github/v/tag/theohbrothers/PSRepositoryReleaseManager?style=flat-square
[badge-version-github-tag-src]: https://github.com/theohbrothers/PSRepositoryReleaseManager/releases

A project for managing repository releases, such as [GitHub releases](https://help.github.com/en/articles/about-releases).

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
git submodule add 'https://github.com/theohbrothers/PSRepositoryReleaseManager.git' build/PSRepositoryReleaseManager

# Commit the submodule
git commit -m 'Add submodule PSRepositoryReleaseManager'
```

#### CI files

Decide on which CI provider to use in your main project based on those supported by this project. Setup the CI file(s) for your main project. Then simply reference the relevant CI files of this project from your main project's CI file(s).

Sample CI files can be found [here](docs/samples/ci).

### CI settings

Configure the following CI settings for your project.

#### Secrets

##### GitHub API token

Add a secret variable `GITHUB_API_TOKEN` containing your [GitHub API token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line), ensuring it has write permissions to the repository.

## Usage

### Development

#### Generating release notes

The entrypoint script [`Invoke-Generate.ps1`](src/scripts/dev/Invoke-Generate.ps1) is used to generate release notes based off local repositories. To generate one, specify the path to the local repository and the variant of release notes to generate.

##### Variants

The names of all release notes variants can be found in the module's [`generate/variants`](src/PSRepositoryReleaseManager/generate/variants) directory and goes by the convention `GenerateVariant-<VariantName>.ps1`.

#### Releases

The entrypoint script [`Invoke-Release.ps1`](src/scripts/dev/Invoke-Release.ps1) can be used to create or simulate the creation of releases for GitHub repositories. Simply fill in all relevant values pertaining to the release, and if desired, the path to the file containing the release notes to include with it.

### Continuous Integration

The included CI files use a very similar set of [entrypoint scripts](src/scripts/ci) to the development versions to run the very same steps of generating release notes and creating releases.

#### Generating release notes

Parameters are provided for [customizing](docs/samples/ci/azure-pipelines/generate) the **generate** step.

#### Releases

**Note:** Ensure your main project's CI file(s) and/or settings are configured to run CI jobs for tag refs.

Parameters are provided for [customizing](docs/samples/ci/azure-pipelines/release) the **release** step.

Releases will be created for tag refs. Tags must follow [Semantic Versioning](https://semver.org/) and be prepended with a lowercase `v`:

```shell
# Tag the commit to release
git tag v1.0.12

# Push the tag
git push remotename v1.0.12
```

### Managing the submodule

#### Retrieving updates

To update the submodule:

```shell
git submodule update --remote build/PSRepositoryReleaseManager
```

#### Using a specific tag / commit

To use a specific tag or commit of the submodule:

```shell
# Change to the submodule's root directory
cd build/PSRepositoryReleaseManager

# To use a specific tag
git checkout v1.0.1
# Or, to use a specific commit
git checkout 0123456789abcdef0123456789abcdef01234567

# Return to the main project's root directory
cd -
# Commit the submodule
git commit -m 'Update submodule PSRepositoryReleaseManager'
```

#### Tracking a specific branch

To track a specific branch for  `git submodule update`, add the `branch` key-value pair under the submodule's entry in `.gitmodules` like so:

```shell
[submodule "build/PSRepositoryReleaseManager"]
	path = build/PSRepositoryReleaseManager
	url = https://github.com/theohbrothers/PSRepositoryReleaseManager.git
	branch = trackedbranch
```

## Best practices

- Use only tag refs of `PSRepositoryReleaseManager` in your main project.
- Ensure your main project's CI file(s) is configured to use the CI templates of `PSRepositoryReleaseManager` and that the commit used matches that of `PSRepositoryReleaseManager` used in your main project.
