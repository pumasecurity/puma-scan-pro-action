# Puma Scan Pro GitHub Action

![](docs/images/Puma-Scan_Pro_Logo_HORIZ.png)

> [GitHub Action](https://github.com/features/actions) for [Puma Scan Professional](https://github.com/pumasecurity/puma-scan-pro-action)

[![GitHub Release][release-img]][release]
[![GitHub Marketplace][marketplace-img]][marketplace]
[![License][license-img]][license]

## Table of Contents

* [Usage](#usage)
  * [Scan CI Pipeline](#scan-ci-pipeline)
* [Customizing](#customizing)
  * [Input Parameters](#input-parameters)

## Usage

### Scan CI Pipeline

The following example shows how to run the Puma Scan GitHub Action when pull requests are opened in a repository.

```yaml
name: scan

on:
  pull_request:

permissions:
  id-token: write # write jwt token
  actions: read # read gh actions
  contents: read # read access to the repo

jobs:
  scan:
    name: scan
    runs-on: ubuntu-latest
    steps:
      - name: checkout code
        uses: actions/checkout@v4
      - name: run puma scan
        uses: pumasecurity/puma-scan-pro-action@v1
        env:
          PUMA_LICENSE: ${{ secrets.PUMA_LICENSE }}
        with:
          project-path: "./Web/Web.csproj"
          output-formats: "json,html,sarif,msbuild"
          output-path: "./results/puma-scan"
          settings-paths: "./.pumafile"
```

## Customizing

Puma Scan customizations are done using a *.pumafile* stored in the local repository. For more details on how to create a *.pumafile* please refer to the [Puma Scan User Guide](https://pumascan.com/configuration/#settings-local).

### Inputs Parameters

Following input parameters can be used to pass arguments to the *pumascan* command line interface in the `step.with` keys:

| Name               | Required    | Description                        |  
|--------------------|-------------|------------------------------------|
| `version`          | false | The version of PumaScan Professional to use. Default is the latest version on Linux x64 processors. |
| `project-path`     | true  | Common delimited list of solutions or projects to analyze [Web.csproj,Api.csproj,Data.csproj] |
| `output-formats`   | true  | Comma delimited list of output formats [json,html,msbuild,vso,trx,csv,sarif,sonarcloud] |
| `output-file`      | true  | Output directory and file name for the generated scan results [./results/pumascan]. The file extension will automatically be added for each selected format. |
| `settings-paths`    | false | Comma delimited list of settings file paths. The default is the *.pumafile* in the current working directory. |
| `verbose`          | false | Enable verbose output. The default is false. |
| `threshold-high`   | false | Threshold for the number of high risk findings that cause the scan to return a failing exit code. Default is an empty string (disabled). |
| `threshold-medium` | false | Threshold for the number of medium risk findings that cause the scan to return a failing exit code. Default is an empty string (disabled). |
| `threshold-low`    | false | Threshold for the number of low risk findings that cause the scan to return a failing exit code. Default is an empty string (disabled). |

### Environment Variables

The Puma Scan Professional GitHub Action requires the following environment variables to be set

| Name               | Required    | Description                        |
|--------------------|-------------|------------------------------------|
| `PUMA_LICENSE`     | true  | The license key for Puma Scan Professional. Copy the Cloud CI license from your [https://portal.pumascan.com](https://portal.pumascan.com) account and store the value in a repository secret. |
| `PUMA_AUTH_TOKEN` | false | To activate the repository, the GitHub Action will request an OIDC token from the GitHub API. The GitHub action needs the `id-token: write` permission to request the token. As long as the permission is set correctly, the action will automatically request the token and set the `PUMA_AUTH_TOKEN` environment variable. |
