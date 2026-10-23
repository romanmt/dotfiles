# CLAUDE.md

Personal macOS dotfiles managed with chezmoi. Source: `~/Workspace/dotfiles`, target: `$HOME`.

**Before changing anything, read the "Rules for AI agents" section of [README.md](README.md). Those rules are binding.**

The short version:

- Edit the source here, never the target in `$HOME`. If a target was changed, `chezmoi re-add` it first (status `MM` means the live copy is newer).
- `run_once_*` scripts install tools. They never edit `~/.zshrc` or other managed files.
- Shell startup must print nothing (Powerlevel10k instant prompt).
- This repo is **public**: no secrets and no work-internal hostnames. Those go in `~/.zshrc.local`.
- Validate freely (`zsh -n`, `chezmoi diff --use-builtin-diff`, `chezmoi status`). Ask before `chezmoi apply`, before deletions, and before any change outside the repo.
- Keep README.md current when components change.
