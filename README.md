# homebrew-tap

Homebrew tap for **skrr** — run AI agents directly on your machine.

## Install

```bash
brew tap skrr-ai/tap
brew install skrrd
skrrd setup
```

`skrrd setup` handles browser login, OS service install (launchd on macOS,
systemd on Linux), and auto-start on login.

## Upgrade

```bash
brew upgrade skrrd
```

## What's in a name

`skrrd` is the local **runtime** — the daemon that executes agent work on your
machine. The `skrr` **CLI** is a separate artifact on a separate channel:

```bash
npm i -g @skrr-ai/cli    # the skrr command
```

The CLI finds the runtime by binary name, so both can be installed
independently and either one can be upgraded without the other.

The tap is `skrr-ai/tap` rather than `skrr-ai/skrr` because Homebrew renders a
tap coordinate as `<owner>/<repo minus "homebrew-">/<formula>` — this way one
tap holds every formula, and you add it once.

## How this tap is maintained

`Formula/skrrd.rb` is **auto-generated** — never hand-edit it. On every
`daemon-v*` tag in the product repo, the `Daemon Release` workflow compiles the
signed binaries, publishes them to the public update feed, renders the formula
from `.github/brew/skrrd.rb.tmpl` with the exact per-asset sha256, and commits
the result here. That keeps the formula byte-for-byte in sync with the
published artifacts.

Formula URLs point at the public CloudFront feed rather than at GitHub Release
assets, because the product repository is private and its release assets are
not readable anonymously.

## Issues

Report problems against the product repository, not this tap — the formula
here is generated output, so a bug in it is a bug in the template or the
release workflow.
