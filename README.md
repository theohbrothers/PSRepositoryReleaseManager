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

At present, generation of release notes is only possible for tags of the format [`MAJOR.MINOR.PATCH`](src/PSRepositoryReleaseManager/Private/Get-RepositoryReleasePrevious.ps1#L17), prepended with a lowercase `v`:

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

To create releases, reference the appropriate `release.yml` entrypoint CI template provided by this project from your CI file. The **release** step can also be customized through provided [parameters](docs/samples/ci/azure-pipelines/custom/azure-pipelines.release.yml#L4-#L20).

Releases supports all tag refs. Tags *need not* follow [Semantic Versioning](https://semver.org/) though the convention is recommended.

#### via Entrypoint scripts

##### Parameters

```powershell
# Entrypoint scripts
Invoke-Generate.ps1 [[-ProjectDirectory] <string>] [-ReleaseTagRef] <string> [[-ReleaseNotesVariant] <string>] [[-ReleaseNotesPath] <string>] [<CommonParameters>]
Invoke-Release.ps1 -Namespace <string> -Repository <string> -ApiKey <string> [-ProjectDirectory <string>] [-TagName <string>] [-Name <string>] [-ReleaseNotesPath <string>] [-Draft <bool>] [-Prerelease <bool>] [-Asset <string>] [<CommonParameters>]
Invoke-Release.ps1 -Namespace <string> -Repository <string> -ApiKey <string> [-ProjectDirectory <string>] [-TagName <string>] [-Name <string>] [-ReleaseNotesContent <string>] [-Draft <bool>] [-Prerelease <bool>] [-Asset <string>] [<CommonParameters>]

# Cmdlets
Generate-ReleaseNotes [-Path] <string> [-TagName] <string> [-Variant] {Changes-HashSubject-Merges | Changes-HashSubject-NoMerges | Changes-HashSubject | VersionDate-HashSubject-Merges | VersionDate-HashSubject-NoMerges | VersionDate-HashSubject | VersionDate-Subject-Merges | VersionDate-Subject-NoMerges | VersionDate-Subject} [-ReleaseNotesPath] <string> [<CommonParameters>]
Create-GitHubRelease -Namespace <string> -Repository <string> -ApiKey <string> [-TagName <string>] [-TargetCommitish <string>] [-Name <string>] [-ReleaseNotesPath <string>] [-Draft <bool>] [-Prerelease <bool>] [<CommonParameters>]
Create-GitHubRelease -Namespace <string> -Repository <string> -ApiKey <string> [-TagName <string>] [-TargetCommitish <string>] [-Name <string>] [-ReleaseNotesContent <string>] [-Draft <bool>] [-Prerelease <bool>] [<CommonParameters>]
Upload-GitHubReleaseAsset [-UploadUrl] <string> [-Asset] <string[]> [-ApiKey] <string> [<CommonParameters>]
```

##### Commands

Simply define necessary environment variables and/or parameter values prior to executing the provided entrypoint script(s) within your CI environment to perform their respective functions.

```powershell
# CI global variables
$env:GITHUB_API_TOKEN = 'xxx' # required for Release
$env:RELEASE_TAG_REF = 'vx.x.x' # required for Generate and Release

# Generate and Release variables
#$env:PROJECT_DIRECTORY = "$(git rev-parse --show-toplevel)" # optional
#$env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.md" # optional

# Generate (Generates release notes)
#$env:RELEASE_NOTES_VARIANT='VersionDate-HashSubject-NoMerges' # optional
$private:generateArgs = @{
    ReleaseTagRef = $env:RELEASE_TAG_REF
}
if ($env:PROJECT_DIRECTORY) { $private:generateArgs['ProjectDirectory'] = $env:PROJECT_DIRECTORY }
if ($env:RELEASE_NOTES_VARIANT) { $private:generateArgs['ReleaseNotesVariant'] = $env:RELEASE_NOTES_VARIANT }
if ($env:RELEASE_NOTES_PATH) { $private:generateArgs['ReleaseNotesPath'] = $env:RELEASE_NOTES_PATH }
./path/to/PSRepositoryReleaseManager/src/scripts/ci/Invoke-Generate.ps1 @private:generateArgs

# Release (Creates GitHub release)
$env:RELEASE_NAMESPACE = 'mygithubnamespace' # required
$env:RELEASE_REPOSITORY = 'my-project' # required
#$env:RELEASE_NAME = 'My release name' # optional
#$env:RELEASE_NOTES_CONTENT = Get-Content $env:RELEASE_NOTES_PATH -Raw # optional
#$env:RELEASE_DRAFT = 'false' # optional
#$env:RELEASE_PRERELEASE = 'false' # optional
#$env:RELEASE_ASSETS = @('path/to/asset1.tar.gz', 'path/to/asset2.gz', 'path/to/asset3.zip', 'path/to/assets/*.gz', 'path/to/assets/*.zip') # optional
$private:releaseArgs = @{
    Namespace = $env:RELEASE_NAMESPACE
    Repository = $env:RELEASE_REPOSITORY
    ApiKey = $env:GITHUB_API_TOKEN
}
if ($env:PROJECT_DIRECTORY) { $private:generateArgs['ProjectDirectory'] = $env:PROJECT_DIRECTORY }
if ($env:RELEASE_TAG_REF) { $private:releaseArgs['TagName'] = $env:RELEASE_TAG_REF }
if ($env:RELEASE_NAME) { $private:releaseArgs['Name'] = $env:RELEASE_NAME }
if ($env:RELEASE_NOTES_PATH) { $private:releaseArgs['ReleaseNotesPath'] = $env:RELEASE_NOTES_PATH }
elseif ($env:RELEASE_NOTES_CONTENT) { $private:releaseArgs['ReleaseNotesContent'] = $env:RELEASE_NOTES_CONTENT }
if ($env:RELEASE_DRAFT) { $private:releaseArgs['Draft'] = [System.Convert]::ToBoolean($env:RELEASE_DRAFT) }
if ($env:RELEASE_PRERELEASE) { $private:releaseArgs['Prerelease'] = [System.Convert]::ToBoolean($env:RELEASE_PRERELEASE) }
if ($env:RELEASE_ASSETS) { $private:releaseArgs['Asset'] = $env:RELEASE_ASSETS }
./path/to/PSRepositoryReleaseManager/src/scripts/ci/Invoke-Release.ps1 @private:releaseArgs
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
