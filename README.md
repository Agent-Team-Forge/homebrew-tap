# Agent Team Homebrew tap

Install the native Agent Team CLI on Apple Silicon macOS 15+ or Linux, including
Windows through WSL2:

```text
brew install agent-team-forge/tap/agent-team
agent-team version
agent-team init my-team
```

Requires [Homebrew](https://brew.sh). Intel Macs are not supported. Linux packages
support x64 (Ubuntu 22.04+) and ARM64 (Ubuntu 24.04+). On Windows, run these commands
inside WSL2, not PowerShell. Keep team files in the Linux home directory, not
`/mnt/c`, to preserve private file permissions.

Before creating a team, install/start Docker with Compose, configure your personal
Zulip credentials at `~/.zuliprc`, and edit `my-team/agent-team.json` with your
repository/settings. On Windows, enable Docker Desktop's WSL integration. Then:

```text
agent-team create my-team
```

This provisions Zulip and creates stopped containers; starting them is separate.
No separate .NET runtime installation is needed. The Mac CLI is ad-hoc signed;
this formula installation does not require Apple notarization or manual security
overrides. Direct browser downloads have different Gatekeeper behavior.

```text
brew update
brew upgrade agent-team
brew uninstall agent-team
```

These commands affect the CLI only, not team data or containers. Existing team
deployments remain tied to their original release version.

[Public releases](https://github.com/stick109/agent-team-releases/releases)
also provide the native Windows x64 executable, the Unix archives, release image
manifest, and SHA-256 checksums. The source repository is private.

## Maintainers

For each new published release, copy its checksum-verified `agent-team.rb` asset
to `Formula/agent-team.rb`, then commit and push. CI checks installation from the
public release URLs on native Apple Silicon, Linux x64, and Linux ARM64 runners.
It tests initialization and private file permissions, reinstall, and uninstall.
It does not provision live Zulip resources or a Docker Desktop deployment.
