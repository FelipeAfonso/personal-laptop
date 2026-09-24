# This machine: yuggoth (Felipe's MacBook)

You are running on **yuggoth**, Felipe's MacBook Air (macOS): a real display,
browsers, audio, but on battery, often asleep, and only intermittently on the
tailnet. Anything that must survive the lid closing belongs on rlyeh.

## Environment

- Homebrew macOS with tracked config: this machine's state lives in
  `~/code/personal/personal-laptop` (public GitHub repo). Sync is copy-based:
  edit the repo, `./export_current` applies it to the machine;
  `./import_current` pulls live state (plus a Brewfile dump) back into the
  repo to be committed. Install software with brew normally; the next import
  records it.
- These very instructions are generated: `export_current` concatenates
  `agents/*.md` from that repo into `~/.claude/CLAUDE.md`,
  `~/.codex/AGENTS.md`, and `~/.config/opencode/AGENTS.md`. To change them,
  edit the repo files and re-export; edits to the generated files are lost on
  the next export. Shared sources live in
  personal-server's `home/felipe/agents/`. Use that repo's
  `scripts/sync-agent-prompts.py` to check or update this repo's copies.
  Use `./export_current --agents-only` to apply agent changes without
  exporting unrelated laptop settings.
- sudo asks for Felipe's password. Don't build automation that assumes
  unattended root; surface the sudo step so he can run or approve it.
- Secrets: `secrets-pull` decrypts the private sops/age secrets repo into
  `~/.config/zsh/.secrets.env` (0600, gitignored), which zsh exports. The
  `claude`, `codex`, `opencode`, and `gh` CLIs are already authenticated.
- No tiling WM, no theming pipeline, stock colors. Karabiner does the
  keyboard remaps.

## Network: the tailnet and the fleet

Everything rides Tailscale. The tailnet is `bass-pirarucu.ts.net` with
MagicDNS on, so every machine resolves by bare hostname (`ssh rlyeh` works,
no `~/.ssh/config` needed).

| host           | what it is                                | tailscale IP   | OS    |
| -------------- | ----------------------------------------- | -------------- | ----- |
| `yuggoth`      | this laptop: Felipe's MacBook Air         | 100.120.128.70 | macOS |
| `miskatonic`   | Felipe's desktop and main seat            | 100.91.60.55   | linux |
| `rlyeh`        | always-on headless agent server (NixOS)   | 100.91.212.25  | linux |
| `necronomicon` | Felipe's iPhone (SSHes in via Termius)    | 100.114.0.102  | iOS   |

Full name for any of them is `<host>.bass-pirarucu.ts.net`.

Dev servers: Felipe also opens them from the phone or the desktop, so prefer
binding `0.0.0.0` and handing over the tailnet URL
(`http://yuggoth.bass-pirarucu.ts.net:<port>`). Never
enable `tailscale funnel`, and never run `tailscale up/down/logout` or change
ACLs unless Felipe asks for exactly that.

## Operating the fleet

- rlyeh is the workhorse: anything long-running, scheduled, or always-on
  (watchers, servers, bots, overnight jobs) belongs there, not on this
  laptop. `ssh rlyeh`, start it detached (`tmux new -d -s <name>` or
  `systemd-run --user --unit <name>`), and report the unit or session name
  and how to stop it.
- rlyeh is pure-flake NixOS, defined by the personal-server repo
  (`~/code/personal/personal-server` on rlyeh). Never change rlyeh
  imperatively: edit the flake, push, then
  `ssh rlyeh 'sudo nixos-rebuild switch --flake ~/code/personal/personal-server#rlyeh'`
  (rlyeh has passwordless sudo). That repo takes no PRs: push a branch, then
  ask Felipe before merging to main.
- rlyeh's `t3code.service` (port 3773) is its #1 service: never kill it,
  bind its port, or touch its unit or `~/.t3` over there.
- miskatonic (config repo: personal-desktop) is Felipe's main seat. On any
  machine that isn't this one, look freely (compare configs, check whether
  something runs) but don't edit, install, or restart anything unless the
  task calls for it, and say what you touched if you do.

## Unslop enforcement hooks

Two hooks in `~/.claude/settings.json` back the global unslop rule. A
UserPromptSubmit hook injects the rule into context every turn, and a Stop
gate (`~/.claude/hooks/unslop-stop-gate.py`) blocks ending a turn with a
substantial reply until the unslop skill was invoked via the Skill tool. If
your reply gets bounced with an unslop message, invoke the skill and
rewrite; don't try to work around the hook. The scripts are repo-managed
(`agents/hooks/`, installed by `export_current`); the hooks block in
settings.json is set by hand because Claude Code writes to that file at
runtime.
