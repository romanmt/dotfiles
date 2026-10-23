# Dotfiles

My macOS development environment, managed with [chezmoi](https://chezmoi.io/).

- **Repo:** `github.com/romanmt/dotfiles` (**public**)
- **Local source:** `~/Workspace/dotfiles` (set by `sourceDir` in `.chezmoi.toml.tmpl`)
- **Target:** `$HOME`

This README is for me and for AI agents. Agents: read [Rules for AI agents](#rules-for-ai-agents) before changing anything.

---

## What it sets up

| Area | What | Where it is defined |
|---|---|---|
| Package manager | Homebrew | `run_once_01_setup_homebrew.sh` |
| Language versions | asdf, with versions pinned in `~/.tool-versions` (chezmoi, ruby, nodejs, java, python) | `run_once_02_setup_asdf.sh`, `dot_tool-versions` |
| Terminal | iTerm2 | `run_once_03_setup_iterm.sh` |
| Shell | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting | `run_once_04_setup_ohmyzsh.sh`, `dot_zshrc` |
| Prompt | Powerlevel10k | `run_once_07_setup_fonts.sh`, `dot_p10k.zsh` |
| Fonts | MesloLGS Nerd Font, VictorMono Nerd Font | `run_once_07_setup_fonts.sh` |
| Directory listings | colorls, with `ls`, `lc`, `la`, `ll` and `tree` aliases | `run_once_06_setup_colorls.sh`, `dot_zshrc`, `dot_config/colorls/` |
| Secrets tooling | Keeper Commander (password manager CLI), OpenBao `bao` (work secrets CLI) | `run_once_08_setup_secrets_tools.sh` |
| chezmoi itself | Config: source dir, VS Code as editor, diff and merge tool | `.chezmoi.toml.tmpl` |

### Files that are not managed

| File | Purpose |
|---|---|
| `~/.zshrc.local` | Machine-specific and **work-only** shell settings (BAO_ADDR, CA bundle paths). Sourced at the end of `~/.zshrc`. Never committed, because this repo is public. |
| `~/Workspace/.tool-versions` | Workspace-level pins (erlang, elixir, newer nodejs). |

---

## Install on a new Mac

1. Install Homebrew and chezmoi. The Homebrew installer prompts interactively, so run it yourself:

   ```zsh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   ```zsh
   eval "$(/opt/homebrew/bin/brew shellenv)" && brew install chezmoi
   ```

2. Clone into the expected location and apply. `chezmoi init` renders `.chezmoi.toml.tmpl` into `~/.config/chezmoi/chezmoi.toml`, and `--apply` writes the dotfiles and runs every `run_once_*` script in order.

   ```zsh
   git clone https://github.com/romanmt/dotfiles.git ~/Workspace/dotfiles && chezmoi init --source ~/Workspace/dotfiles --apply
   ```

3. Create `~/.zshrc.local` with any work settings (copy it from the old machine; it is not in git).

4. Open a new terminal, and set iTerm2's font to `MesloLGS NF`.

5. Log in to the CLIs as needed: `keeper shell` for the password manager, and `bao login` for work.

---

## Day-to-day use

| Task | Command |
|---|---|
| See what is out of sync | `chezmoi status` |
| Preview changes in the terminal | `chezmoi diff --use-builtin-diff` (plain `chezmoi diff` opens VS Code) |
| Apply everything | `chezmoi apply` |
| Apply one file | `chezmoi apply ~/.zshrc` |
| Edit a managed file | `chezmoi edit ~/.zshrc`, then `chezmoi apply` |
| Pull a change you made in `$HOME` back into the repo | `chezmoi re-add ~/.p10k.zsh` |
| Start managing a new file | `chezmoi add ~/.config/foo/config` |
| Commit and push | `cd ~/Workspace/dotfiles && git add -A && git commit && git push` |
| Pull from another machine | `chezmoi update` |
| Re-run every setup script | `chezmoi state delete-bucket --bucket=scriptState && chezmoi apply` |

`run_once_*` scripts run again automatically whenever their **contents** change, so editing a script is enough to get it run on the next apply.

---

## Rules for AI agents

These rules apply to any agent (Claude Code or another) that changes this repo or the setup it manages. My global `~/.claude/CLAUDE.md` rules also apply; where the two differ, the stricter one wins.

### How the repo works

- **This repo is the source of truth.** A file in `$HOME` is generated from its source here: `~/.zshrc` comes from `dot_zshrc`, `~/.config/x` from `dot_config/x`, and a `private_` prefix makes the target readable only by me.
- **Change the source, not the target.** Edit the file in `~/Workspace/dotfiles`, then apply it. If you have to change a file in `$HOME` directly, bring it back with `chezmoi re-add <path>` in the same session.
- **Setup scripts install things. They never edit managed files.** A `run_once_*` script must not append to `~/.zshrc` (or any other managed file), and must not call `chezmoi add`. Shell config goes in `dot_zshrc`. Breaking this rule is what duplicated the colorls and asdf blocks before.
- **Scripts are self-contained and idempotent.** chezmoi runs each one on its own, so define any helper inside the script that uses it. Check before installing, and exit non-zero with a clear message on failure.
- **Scripts run in filename order.** Use the next free two-digit prefix (`run_once_09_...`) and put dependencies first. Homebrew (01) comes before anything that uses `brew`, asdf (02) before anything that needs ruby or node, and Oh My Zsh (04) before the plugins or themes that rely on it.
- **Versions live only in `dot_tool-versions`.** Do not hard-code versions in scripts. `run_once_02` installs whatever that file pins.
- **Repo-only files go in `.chezmoiignore`.** This README, `CLAUDE.md` and `docs/` are listed there so they are never copied into `$HOME`. Add any new repo-only file to it.

### Shell startup must stay silent

Powerlevel10k's instant prompt prints a large warning if anything writes to the terminal during startup. In `dot_zshrc`:

- Nothing may `echo` or print. Commands that might fail must send their errors to `/dev/null`.
- Guard optional tools: `[[ -f file ]] && source file`, `command -v tool &> /dev/null`.
- Keep startup fast. Avoid running `$(slow-command)` on every shell when a file can be sourced instead.

### Public repo: secrets and work details

- **No secrets, ever.** No tokens, passwords or keys in any file, not even in examples or comments. Keeper is my personal password manager and OpenBao is the work secrets manager, and **neither is wired into chezmoi templates**. Do not add `keeper`, `bao` or `vault` template functions.
- **No work-internal details.** Internal hostnames (`*.kwi.com`), internal paths, IPs and work env vars go in `~/.zshrc.local`, not in this repo.
- **`~/.ssh` is not managed.** Never add SSH keys or `~/.ssh/config` here. If a shared SSH config is ever wanted, keep work hosts in an unmanaged file pulled in with `Include ~/.ssh/config.local`.

### Making a change

1. Read the files you are about to change and run `chezmoi status`. A file marked `MM` has drifted, meaning the live copy differs from the source. **Treat the live copy as newer** and bring it back with `chezmoi re-add` before editing, or you will undo my changes.
2. Make the edit in the repo.
3. Validate without asking (these are read-only):
   - `zsh -n dot_zshrc` and `zsh -n run_once_*.sh`
   - `chezmoi execute-template < .chezmoi.toml.tmpl` after editing that template
   - `chezmoi diff --use-builtin-diff <target>`
   - A startup test that leaves `~/.zshrc` alone: copy `dot_zshrc` to `<scratch>/.zshrc`, then run `ZDOTDIR=<scratch> zsh -i -c exit` and check that it prints nothing.
4. **Ask before** running `chezmoi apply`, deleting tracked files, or changing anything outside the repo (`$HOME`, `/Applications`, `/opt/homebrew`). Show the exact command.
5. Update this README when you add, remove or rename a component, a script or a rule.
6. Commit only when I ask, with a message that describes the change. Push only when I ask.

### Style

- No em dashes or en dashes in anything I read: commit messages, comments, docs.
- No `#` comments inside shell commands handed to me to paste (zsh does not treat them as comments). Comments inside script files are fine.
- Match the existing script style: `#!/bin/zsh`, an inline `check_command_installed`, and emoji status lines.

---

## Troubleshooting

**"Insecure completion-dependent directories" on every new terminal.** compaudit rejects completion files that are not owned by you or root. For OrbStack (installed by the laptop's previous owner):

```zsh
sudo chown -R "$USER":staff /Applications/OrbStack.app
```

To find other offenders, run `compaudit`.

**Powerlevel10k "console output during zsh initialization" warning.** Something in `~/.zshrc` or `~/.zshrc.local` printed during startup. The warning lists the output at the bottom. Fix the source as described in [Shell startup must stay silent](#shell-startup-must-stay-silent).

**chezmoi uses the wrong source directory.** `chezmoi source-path` should print `~/Workspace/dotfiles`. If it does not, `sourceDir` in `~/.config/chezmoi/chezmoi.toml` is missing or sits under a `[section]` header (TOML top-level keys must come before the first section). Regenerate it with `chezmoi init`.

**"config file template has changed".** Run `chezmoi init` to regenerate `~/.config/chezmoi/chezmoi.toml` from `.chezmoi.toml.tmpl`.

**A setup script did not run.** Run `chezmoi apply --dry-run --verbose` to see what would run. To force all of them, use `chezmoi state delete-bucket --bucket=scriptState`.
