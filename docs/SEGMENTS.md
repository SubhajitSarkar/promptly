# Prompt Segments

## What is a segment?

A segment is a small block of information displayed in your terminal prompt. Each segment is independent - it only appears when relevant, and you choose which ones to include during install.

For example:

- The **Node** segment shows your Node.js version, but only when you are inside a project that has a `package.json` or `.nvmrc`
- The **Git** segment shows your branch and status, but only inside a git repository
- The **Execution Time** segment shows how long the last command took, but only if it ran for more than 3 seconds

This keeps your prompt clean and fast - you only see information that is relevant to what you are doing right now.

## Choosing segments during install

When you run `./install.sh` (or `.\install.ps1` on Windows), you will see an interactive checklist before anything is installed:

```
  Select prompt segments (↑↓ move, Space toggle, Enter confirm)
  ────────────────────────────────────────────────
  ▶ [✔] Node / NVM        Node.js version in JS/TS projects
    [✔] Python / Virtualenv  Python version and active venv
    [✔] Go               Go version in projects with go.mod
    [✔] Rust             Rust version in projects with Cargo.toml
    [✔] Execution Time   How long the last command took (>3s)
    [✔] Clock            Current time on the right side
    [ ] Battery          Battery level (useful on laptops)
    [ ] Kubectl          Current Kubernetes context and namespace
  ────────────────────────────────────────────────
```

Use arrow keys to move, **Space** to toggle, **Enter** to confirm. Only the segments you select will be included in your prompt config.

## Available segments

### Languages

| Segment | Key | Shows when | On by default |
|---|---|---|---|
| Node / NVM | `node` | Inside a JS/TS project | ✔ |
| Python / Virtualenv | `python` | Python version active or venv activated | ✔ |
| Go | `go` | Inside a Go project (`go.mod`) | ✔ |
| Rust | `rust` | Inside a Rust project (`Cargo.toml`) | ✔ |
| Ruby | `ruby` | Inside a project with `Gemfile` or `.ruby-version` | ✗ |
| Java | `java` | Inside a project with `pom.xml` or `build.gradle` | ✗ |
| PHP | `php` | Inside a project with `composer.json` | ✗ |
| .NET | `dotnet` | Inside a project with `*.csproj` or `*.sln` | ✗ |
| Swift | `swift` | Inside a project with `Package.swift` | ✗ |

### Cloud & DevOps

| Segment | Key | Shows when | On by default |
|---|---|---|---|
| AWS | `aws` | `AWS_PROFILE` is set or aws/terraform commands run | ✗ |
| Azure | `azure` | `az` or terraform commands run | ✗ |
| GCP | `gcp` | `gcloud` or terraform commands run | ✗ |
| Docker | `docker` | Non-default Docker context is active | ✗ |
| Terraform | `terraform` | Inside a dir with `.tf` files | ✗ |
| Kubectl | `kubectl` | When running kubectl/helm/k9s etc. | ✗ |

### System

| Segment | Key | Shows when | On by default |
|---|---|---|---|
| Execution Time | `execution_time` | Command took > 3 seconds | ✔ |
| Clock | `time` | Always (right side) | ✔ |
| Battery | `battery` | Battery below 30% or charging | ✗ |
| Disk Usage | `disk_usage` | Always, warns above 90% | ✗ |
| RAM | `ram` | Always | ✗ |
| CPU Load | `load` | Always | ✗ |
| VPN | `vpn` | When a VPN connection is active | ✗ |

## Re-running the picker

To change your segments after install, just re-run the install script. It will back up your existing config and let you pick again:

```bash
# macOS / Linux / WSL
./install.sh

# Windows
.\install.ps1
```

Or run `p10k configure` on macOS/Linux/WSL for the full interactive Powerlevel10k wizard.

## Adding a custom segment (macOS / Linux / WSL)

Each segment is a standalone `.zsh` file in `config/segments/zsh/p10k/`. To add a new one:

**1. Create the segment file**

```bash
# config/segments/zsh/p10k/my_segment.zsh
# segment: my_segment
# description: What this segment shows
# elements: my_element_name
typeset -g POWERLEVEL9K_MY_ELEMENT_FOREGROUND=208
typeset -g POWERLEVEL9K_MY_ELEMENT_VISUAL_IDENTIFIER_EXPANSION='🔧'
```

**2. Register it in `lib/picker.sh`**

Add a line to `_SEGMENT_DEFS`:

```bash
"my_segment|My Segment|What it shows in the prompt|off"
```

**3. Map its element name in `lib/p10k.sh`**

Add to `_SEGMENT_ELEMENTS`:

```bash
[my_segment]="my_element_name"
```

**4. Re-run the installer** - your new segment will appear in the picker.

## Adding a custom segment (Windows)

**1. Create the segment file**

```json
// config/segments/ps/omp/my_segment.json
{
  "type": "my_type",
  "style": "plain",
  "foreground": "#FAB387",
  "template": "{{ .Value }} "
}
```

**2. Register it in `lib-ps/Picker.ps1`**

Add to `$script:SegmentDefs`:

```powershell
@{ Key="my_segment"; Label="My Segment"; Desc="What it shows"; Default=$false }
```

That's it - the installer will pick up the file automatically by matching the key to `config/segments/ps/omp/<key>.json`.
