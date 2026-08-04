# Contributing to DistroZSH

First off, thank you for considering contributing to DistroZSH. This project
stays small, fast, and framework-free by design — please keep that philosophy
in mind.

## Code of Conduct

This project and everyone participating in it is governed by the
[Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to
uphold this code.

## How to contribute

### Reporting bugs

Open an issue using the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).
Include:

- Your distribution and version (paste `cat /etc/os-release`).
- Your zsh version (`zsh --version`).
- The DistroZSH version.
- The exact steps to reproduce and the observed vs. expected behaviour.
- Any relevant error output.

### Requesting features

Open an issue using the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).
Prefer issues over "drive-by" PRs for large changes so the design can be
discussed first.

### Adding a distribution theme

1. Add the distribution to the registry in both `zsh/11-detect.zsh` and
   `scripts/distro-detect.sh` (label, theme, package manager).
2. Create `themes/<id>.zsh` from `themes/_template.zsh`.
3. Regenerate screenshots with `./scripts/make-screenshots.sh`.
4. Update the supported-distributions table in `README.md`.
5. Add a `CHANGELOG.md` entry.

### Adding a layout

1. Create `layouts/<name>.zsh` defining the `_distrozsh_prompt` function.
2. Only structure goes in layouts — colors come from the active theme.
3. Regenerate screenshots and update `docs/LAYOUTS.md` and `config.zsh`.

### Code style

- ShellCheck clean (`shellcheck --shell=bash` for `.sh`, `zsh -n` for `.zsh`).
- Consistent formatting (two-space indent in bash, four-space in zsh modules).
- One concern per module; keep functions small and documented.
- No new dependencies. Everything must work with native ZSH.
- No frameworks. Only `zsh-autosuggestions` and `zsh-syntax-highlighting` are
  allowed as plugins, and only when sourced from the distribution package.
- Update `CHANGELOG.md` with every user-visible change.

## Development workflow

```sh
git clone https://github.com/your-name/DistroZSH.git
cd DistroZSH

# preview a single prompt
./scripts/preview.sh fedora kali

# regenerate the screenshot matrix
./scripts/make-screenshots.sh

# validate
bash -n install.sh uninstall.sh scripts/*.sh
zsh -n init.zsh zsh/*.zsh themes/*.zsh layouts/*.zsh
shellcheck --shell=bash install.sh uninstall.sh scripts/*.sh
```

Test the installer in a sandbox without touching your real configuration:

```sh
mkdir -p /tmp/dzsh-home
HOME=/tmp/dzsh-home ./install.sh --no-shell
HOME=/tmp/dzsh-home zsh -ic 'echo $DISTROZSH_VERSION'
HOME=/tmp/dzsh-home ./uninstall.sh
```

## Pull requests

1. Create a branch: `git checkout -b feat/my-feature`.
2. Make your changes and validate them (see above).
3. Open a PR using the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).
4. Keep PRs focused. Reference the issue you are addressing.

## Getting help

Open a discussion or issue; maintainers and contributors will respond as soon
as possible.
