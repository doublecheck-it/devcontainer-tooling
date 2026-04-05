# DevContainer Tooling

DevContainer tooling module for the DCIT tooling framework. Provides Docker-based development container setup.

## Structure

```
devcontainer-tooling/
├── devcontainer/
│   ├── devc.Dockerfile              # Development container Dockerfile
│   ├── devc.docker-compose.yaml     # Docker Compose configuration
│   ├── devcontainer.json.template   # VS Code devcontainer template
│   └── install-toolings.sh          # Tooling installation orchestrator
├── make.mk                          # Makefile with devc.* tasks and setup
└── README.md                        # This file
```

## Usage

### Installation

1. Add this module to your project's `tooling/` directory:
   ```bash
   cd your-project/tooling
   git clone <repo-url> devcontainer-tooling
   # or add as git submodule
   ```

2. Run the setup task to create the devcontainer.json:
   ```bash
   make devcontainer.setup
   ```

This will:
- Create `.devcontainer/` directory in your project root
- Copy the `devcontainer.json.template` to `.devcontainer/devcontainer.json`
- Allow you to customize it for your project

### Available Make Tasks

Once the tooling is added to your project, all devcontainer tasks are automatically available:

**Setup:**
- `make devcontainer.setup` - Setup devcontainer.json from template (one-time setup)

**Container Operations:**
- `make devc.up` - Start the devcontainer
- `make devc.down` - Stop the devcontainer
- `make devc.restart` - Restart the devcontainer (uses cached image)
- `make devc.rebuild` - Rebuild and restart (forces full rebuild, no cache)

**Interaction:**
- `make devc.shell` - Open a shell in the devcontainer
- `make devc.exec CMD="..."` - Execute a command in the devcontainer
- `make devc.logs` - Show devcontainer logs
- `make devc.ps` - Show status of devcontainers

**Maintenance:**
- `make devc.clean` - Clean up containers, networks, and volumes
- `make devc.install-toolings` - Reinstall tooling extensions

All these tasks are provided by the `make.mk` file in this tooling module.

## How It Works

### Docker Configuration

The `devc.Dockerfile` provides a base Ubuntu 24.04 image with essential development tools:
- Core utilities (bash, curl, wget, git)
- Build tools (make, build-essential)
- Text processing (ripgrep, fd, jq)
- Editors (vim, nano)

### Tooling Installation

The `install-toolings.sh` script automatically discovers and executes installation scripts from other tooling modules during the Docker image build. Each tooling can provide a `devcontainer/install.sh` script to install its dependencies.

### Docker Compose

The `devc.docker-compose.yaml` configures:
- Build context pointing to project root
- Dockerfile location in this tooling module
- Volume mounting for the workspace
- Environment variable loading from `.tooling.env`

### VS Code Integration

The `devcontainer.json.template` provides configuration for VS Code's Dev Containers extension, referencing the Docker Compose file in this module.

## Integration with repo-base

When used with `repo-base`, this tooling module provides all devcontainer functionality through its `make.mk` file, which is automatically discovered and loaded by the tooling framework.

The `make.mk` includes:
- Setup task: `devcontainer.setup`
- All devcontainer orchestration tasks: `devc.*`

No additional configuration is needed in `repo-base` - just add this module to the `tooling/` directory.

## Customization

After running `devcontainer.setup`, you can customize `.devcontainer/devcontainer.json` for your project:
- Change the container name
- Add VS Code extensions
- Configure environment variables
- Add custom initialization commands

The template serves as a starting point that references the centralized Docker configuration from this tooling module.
