Scripts to help with GitLab management.

There's also specific sections for:
- [ci-cd management](ci-cd/)

# Table of Contents

[[_TOC_]]


# Requirements
- a Linux, or a Windows with WSL
- Docker
- jq tool

# Credential Setup
## GitLab Access Token

**Personal Token**

This token is used for accessing the GitLab API.

To generate it:

1. Click on the Avatar at the top-right corner
2. Select "Preferences"
3. Click "Access Tokens" on the left sidebar
4. Add a "Add a personal access token"
5. You may select the checkboxes for all the scopes
6. Submit the form to create the Access Token
7. Jot down the given code somewhere

**Prepare the Credentials file**

Create a file called `credentials.sh`, and populate it as follows:

```sh
#!/usr/bin/env bash
GITLAB_HOSTNAME="gitlab.myexample.com"
TOKEN_PERSONAL="<PERSONAL TOKEN>"
```

Note:
- If your GitLab is at `https://gitlab.mysite.com/`, then `GITLAB_HOSTNAME` is `gitlab.mysite.com`

# Usage Guide
## Set Configurations
1. Edit `include.sh`
2. Set `SELF_SIGNED` field to the appropriate values
3. Open up and edit the `.sh` file you want to call
4. Specify the parameters, usually `REPO_TYPE` and `REPO_ID`
