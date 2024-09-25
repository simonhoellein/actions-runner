# Github Actions Runner

Following arguments need to be parsed to the container:

- `REPO` for the Repository e.g. `simonhoellein/actions-runner`
- `ACCESS_TOKEN` for a Personal Access Token with access to `repo`, `workflow`, and `admin:org` scopes

Images: [simonhoellein/actions-runner](https://hub.docker.com/r/simonhoellein/actions-runner)

Deploy this with Docker Compose:

```yaml
services:
  actions-runner-ci:
    image: simonhoellein/actions-runner:latest
    restart: always
    environment:
      - REPO=[user/repository]
      - ACCESS_TOKEN=[Github Access Token]
    deploy:
      mode: replicated
      replicas: 2
      resources:
        limits:
          cpus: '0.35'
          memory: 300M
        reservations:
          cpus: '0.25'
          memory: 128M
```
