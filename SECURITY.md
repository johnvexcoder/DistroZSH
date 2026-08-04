# Security Policy

## Supported versions

Only the latest release of DistroZSH receives security fixes.

| Version | Supported |
| --- | --- |
| 2.0.0 (latest) | ✅ |
| < 2.0.0 (v1 "fedora-zsh") | ❌ |

## Reporting a vulnerability

Security issues should be reported privately, **not** through public issues.
Please open a private advisory via GitHub's "Security" tab
([Report a vulnerability](https://github.com/your-name/DistroZSH/security/advisories/new))
or contact the maintainers by email.

You can expect an acknowledgement within 48 hours and a detailed response
within one week. If the issue is confirmed, a security release will be
coordinated and a public advisory published after the fix ships.

Please include:

- The affected DistroZSH version.
- Your distribution, zsh version, and how DistroZSH was installed.
- A minimal reproduction, if possible.
- A suggested fix, if you have one.

## Security design notes

- The installer runs `sudo` only for native package management; configuration
  is installed into your home directory and never needs root.
- `install.sh` and `uninstall.sh` are reviewed with ShellCheck in CI.
- User configuration (`config.zsh`) is sourced from your own home directory
  only — treat it as trusted code.
- The engine never downloads or executes code from the network; plugins come
  exclusively from your distribution's package manager.
- Themes and layouts are plain ZSH files sourced at load time — review any
  third-party theme before installing it, exactly as you would any shell script.
