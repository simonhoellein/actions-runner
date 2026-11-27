# base
FROM ubuntu:22.04

# set the github runner version
ARG RUNNER_VERSION="2.338.2"

ARG DEBIAN_FRONTEND=noninteractive

# set automatically by buildx (amd64, arm64, arm)
ARG TARGETARCH

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner
# map the docker target architecture to the runner release naming
RUN case "${TARGETARCH}" in \
        amd64) RUNNER_ARCH="x64" ;; \
        arm64) RUNNER_ARCH="arm64" ;; \
        arm) RUNNER_ARCH="arm" ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -fsSL -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner.tar.gz \
    && rm actions-runner.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
