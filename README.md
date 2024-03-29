# Github Upload

This action assists you in uploading your asset(s) to your project release page. You are free to choose between using [static configuration](#static-configuration) (with support for variables) and [scripted configuration](#scripted-configuration) depending on what you need for your project.

Want to upload from your own build server? [Yes, it is supported.](#usage-outside-github)


## Static configuration

When you know up front exactly the files to be uploaded may static configuration be the best choice for your project.


### Single file

When uploading a single file using parameter `file` may you specify all aspects supported by Github. Parameters `name`, `label` and `type` is a [reflection of the Github API](https://developer.github.com/v3/repos/releases/#upload-a-release-asset).

Available parameters:

* `file` - The file to be uploaded. (Mandatory)
* `name` - Filename when uploaded. Default to the filename of `file`.
* `label` - Label replacing filename on release page. Not set unless provided.
* `type` - Content type of your file. Default is to detect using [file](https://github.com/file/file).

Simple example where the file is uploaded without extra information:

```yaml
- uses: klakegg/github-upload@v0.9.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    file: dist/project.zip
```

Example where extra information is provided, and where the uploaded filename contains the tag of the build:

```yaml
- uses: klakegg/github-upload@v0.9.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    file: dist/project.zip
    name: project-${TAG}.zip
    label: Complete project package
    type: application/zip
```


### Multiple files

Parameter `files` is used to upload multiple files at once. This implementation passes the parameter to [ls](https://www.gnu.org/software/coreutils/ls) for discovery of files.

Parameter `type` may be used to pass on content type, however other parameters are not supported. Scipted configuration may be an option if you find this too limiting.

Example of uploading zip files made available in a defined folder:

```yaml
- uses: klakegg/github-upload@v0.9.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    files: dist/*.zip
    type: application/zip
```


## Scripted configuration

Scripted configuration may be used when static configuration does not fit your project.

This is an ption where you are free to make whatever logic you want for your upload, and simply call the [`upload`](#command-upload) to perform upload as part of the logic.

Script for handling may be provided inline as part of the workflow definition using the `script` parameter, or you may point to a script file using the `script_path` parameter.

Example where the script is part of the step definition:

```yaml
- uses: klakegg/github-upload@v0.9.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    script: |
      upload \
        -f dist/project.zip \
        -n project-${TAG}.zip
```

Example where script is provided as a file in the repository:

```yaml
- uses: klakegg/github-upload@v0.9.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    script_path: .github/uploads.sh
```


## Command: upload

The `upload` command may be used in the script to trigger upload of an asset.

Example of use:

```shell
upload \
  -f "target/distribution.zip" \
  -n "distribution-${TAG}.zip" \
  -l "Distribution (zip)" \
  -t "application/zip"
```

Arguments:

* `-f` - The file to be uploaded. (Mandatory)
* `-n` - Filename when uploaded. Default to the filename of `file`.
* `-l` - Label replacing filename on release page. Not set unless provided.
* `-t` - Content type of your file. Default is to detect using [file](https://github.com/file/file).


## Variables

The following extra variables are made available during execution:

* `TAG` - Git tag extracted from the provided `GITHUB_REF`, e.g. `v1.0`.
* `UPLOAD_URL` - URL used to upload assets.


## Usage outside Github

This project may be used also outside Github Actions to perform upload of assets to Github by using the [Docker image](https://hub.docker.com/r/klakegg/github-upload) used by the action.

The following environment variables need to be provided to make this happen:

* `GITHUB_REPOSITORY` - Repository where the project may be found, e.g. `klakegg/github-upload`.
* `GITHUB_TOKEN` - Token provided by Github to get access.
* `GITHUB_ACTOR` - The owner of `GITHUB_TOKEN`, e.g. `klakegg.`
* `GITHUB_REF` or `TAG` - Tag reference when using `GITHUB_REF`, e.g. `refs/tags/v0.9.1` or simply the tag when using `TAG`, e.g. `v0.9.1`.

All parameters and logic are the same as described above, except they have to be passed as environment variables prefixed with `INPUT_` and as uppercase. E.g. parameter `file` becomes environment variable `INPUT_FILE`.
