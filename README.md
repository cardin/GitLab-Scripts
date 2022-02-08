Scripts to help with GitLab CI/CD management.

[[_TOC_]]

# Requirements
- a Linux, or a Windows with WSL
- Docker installed
- Connection to the AI Stack


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

**Group/Project Access Token**

This token is used for assigning a CI/CD Runner to a Group or an individual Project. If you used a Group Access Token, the runner will be available to all Projects in the same Group.

To generate it:

1. Go to a Group/Project, and the left sidebar
2. Go to "Settings > CI/CD"
3. Expand the "Runners" section
4. Under "Set up a ... Runner for a project", jot down the "Registration Token" somwhere

**Prepare the Credentials file**

Create a file called `credentials.sh`, and populate it as follows:

```sh
#!/usr/bin/env bash
TOKEN_PERSONAL="<PERSONAL TOKEN>"
TOKENS_CICD=(
    "<PRJ/GRP NAME> <PRJ/GRP ID> <PRJ/GRP TOKEN>"
    "<PRJ/GRP NAME> <PRJ/GRP ID> <PRJ/GRP TOKEN>"
    )
```

You can insert as many Group/Project tokens as you want


## Self-Signed Certificate
AI Stack is using a self-signed certificate. Run the following, to download the cert that allows the scripts to authenticate properly:
```sh
./certDownload.sh
# will generate a .crt file
```

# Usage Guide
## Adding a Machine to CI/CD Runners
A Runner is a process hosted by a machine, which takes CI/CD jobs to run.

To let a Machine contribute as a Runner, run the following script:
```sh
./runnersAdd.sh
```

To inspect all Runners available to you, run `./runnersInspect.sh`.

To shutdown all Runners this Machine is running, run `./runnersRemove.sh`.

## Cleaning up past CI/CD jobs
To remove past pipeline jobs, run `./remotePipelinesCleanup.sh`.

To remove old and unreachable Runners, run `./remoteRunnersCleanup.sh`.