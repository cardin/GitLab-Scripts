Scripts to help with GitLab CI/CD management.

[[_TOC_]]

# Requirements
- a Linux, or a Windows with WSL
- Docker installed


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
If your GitLab is using a self-signed cert, run the following to download the cert that allows the scripts to authenticate properly:
```sh
./certDownload.sh
# will generate a .crt file
```

# Usage Guide
- Prepend `sudo` if you use `sudo docker ls` instead of `docker ls`.
- Prepend `wsl` (e.g. `wsl sudo ./runnersAdd.sh`) if you're using WSL.

## Set Configurations
1. Edit `include.sh`
2. Set `GITLAB_HOSTNAME` and `SELF_SIGNED` fields to the appropriate values
    - E.g. if your GitLab is at `https://gitlab.mysite.com/`, then your `GITLAB_HOSTNAME` is `gitlab.mysite.com`

## Adding a Machine to CI/CD Runners
A Runner is a process hosted by a machine, which takes CI/CD jobs to run.

To let a Machine contribute as a Runner:
1. Edit `runnersAdd.sh`
2. Scroll to the function definition for `register()`, and look at the `docker run` command:
```sh
docker run --rm -it \
    -v $VOL:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest register \
    --non-interactive \
    --url $GITLAB_URL \
    --registration-token $TOKEN \
    --name "$NAME-$(hostname)" \
    --tag-list "linux, docker, cuda, gpu, sonarqube" \
    --docker-image "alpine:latest" \
    --docker-gpus "all" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-pull-policy="always" \
    --docker-pull-policy="if-not-present" \
    --executor "docker" \
    --run-untagged="true" \
    --locked="false"
```
3. Edit the `docker run` command parameters. You may consider modifying or deleting:
    - `tag-list` to indicate your machine capabilities
    - `docker-gpus` to provide GPU capabilities
    - `run-untagged` to dictate what jobs it should accept
4. When all edits are saved, execute `./runnersAdd.sh`.

To inspect all Runners available to you, run `./runnersInspect.sh`.

To shutdown all Runners this Machine is running, run `./runnersRemove.sh`.

## Cleaning up past CI/CD jobs
To remove past pipeline jobs, run `./remotePipelinesCleanup.sh`.

To remove old and unreachable Runners, run `./remoteRunnersCleanup.sh`.
