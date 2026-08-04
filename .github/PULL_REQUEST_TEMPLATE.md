---
name: Pull request
about: Submit a change to DistroZSH
title: ''
labels: ''
assignees: ''
---

## Summary

<!-- What does this PR do? -->

## Motivation

<!-- Why is this change needed? Reference the issue if any. -->

## Checklist

- [ ] Code is ShellCheck clean (`shellcheck --shell=bash install.sh uninstall.sh scripts/*.sh`)
- [ ] ZSH files pass `zsh -n`
- [ ] `scripts/make-screenshots.sh` output is unchanged (or intentionally regenerated)
- [ ] `README.md` / `docs/` updated where relevant
- [ ] `CHANGELOG.md` updated
- [ ] No new dependencies and no frameworks introduced

## Testing

<!-- How did you verify the change? -->

## Screenshots

<!-- If the prompt changed, add before/after previews from `scripts/preview.sh`. -->
