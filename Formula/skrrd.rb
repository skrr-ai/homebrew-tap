# Homebrew formula template for the skrr daemon.
#
# This file is a TEMPLATE. The release workflow (.github/workflows/
# daemon-release.yml, bump-formula job) renders it with the tag's version
# + each asset's sha256 and commits the result to the tap repo at
#   github.com/skrr-ai/homebrew-tap:Formula/skrrd.rb
#
# WHY THE FORMULA IS `skrrd` AND NOT `skrr`
# -----------------------------------------
# The naming map's row 202 said `skrr.rb`, and that would install a binary the
# formula is not named after. This tap ships ONE thing: the local runtime,
# whose binary is `skrrd` (row 102). The CLI called `skrr` is a different
# artifact on a different channel — `npm i -g @skrr-ai/cli` — and the CLI FINDS
# this daemon by binary name (cli/src/lib/exec-oversky.ts, RUNTIME_BINARY_NAMES).
# Naming the formula `skrr` would mean `brew install skrr-ai/tap/skrr` leaves no
# `skrr` command on the machine, while a `skrr` from npm is a different program.
# One name, one thing.
#
# WHY THE TAP REPO IS `homebrew-tap` AND NOT `homebrew-skrr`
# ----------------------------------------------------------
# Homebrew renders the coordinate as <owner>/<repo minus "homebrew-">/<formula>,
# so `homebrew-skrr` under the skrr-ai org would read
# `brew install skrr-ai/skrr/skrr`. The bare `skrr` org name is not available on
# GitHub (held by an unrelated account since 2012), so that stutter would be
# permanent rather than transitional. `homebrew-tap` gives
# `brew install skrr-ai/tap/skrrd`, and holds every future formula in ONE tap
# the user adds once.
#
# The rendered per-arch url/sha256 values point at the PUBLIC CloudFront feed,
# NOT at github.com — the GitHub repo is private, so its Release assets 404 for
# public users. The bump-formula job sets BASE to
#   https://updates.skrr.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/skrrd-<platform>-<arch> — the stem the signed
# manifest names. The release publishes the same bytes under both
# `skrrd-<platform>` and the `oversky-<platform>` compat copy, so this formula
# and the legacy `oversky.rb` beside it describe identical binaries with
# identical checksums.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.90                — numeric version, no leading "v" (e.g. 0.8.7)
#   https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-darwin-arm64       — CloudFront feed URL for skrrd-darwin-arm64
#   3e294bd1080d372a509b71629272e93295b52fa3fd6b57ccfbb5b10b1bda0e4b       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-darwin-x64, 20b19117b77863a33aeaf6ee0a541bf8b69d27acc0d217a0f553c5f79dcea3dc
#   https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-linux-x64,  877315fd8dd16d5d730a901f2daccda0f124a97c27a925dbe7fa4ec95bff4acc
#   https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-linux-arm64, 6e32a175b0b6edcb25fe71cd703212c17911d709fc8b2ac6b27b129b6c52cc4c
#
# Install path for users:
#   brew tap skrr-ai/tap
#   brew install skrrd
#   skrrd setup
#
# Upgrade path:
#   brew upgrade skrrd
#
# `skrrd setup` combines login + OS service install into one step (see
# daemon/src/index.ts). Users should never have to edit config files manually.

class Skrrd < Formula
  desc "Local AI agent runtime for skrr"
  homepage "https://github.com/dush1023/OverSky"
  license "UNLICENSED"
  version "0.8.90"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-darwin-arm64"
      sha256 "3e294bd1080d372a509b71629272e93295b52fa3fd6b57ccfbb5b10b1bda0e4b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-darwin-x64"
      sha256 "20b19117b77863a33aeaf6ee0a541bf8b69d27acc0d217a0f553c5f79dcea3dc"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-linux-arm64"
      sha256 "6e32a175b0b6edcb25fe71cd703212c17911d709fc8b2ac6b27b129b6c52cc4c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/skrrd-linux-x64"
      sha256 "877315fd8dd16d5d730a901f2daccda0f124a97c27a925dbe7fa4ec95bff4acc"
    end
  end

  def install
    # Bun-compiled binaries ship as a single file named by platform + arch.
    # Normalize to "skrrd" at install time so the tap's entry point is stable
    # regardless of the user's platform.
    binaries = Dir["skrrd-*"]
    odie "no skrrd-* binary in release asset" if binaries.empty?
    odie "multiple skrrd-* binaries in release asset: #{binaries}" if binaries.size > 1
    bin.install binaries.first => "skrrd"
  end

  test do
    # Smoke test — verifies the binary loads and the embedded version matches
    # the formula version. If this ever drifts, the release workflow is broken.
    assert_match version.to_s, shell_output("#{bin}/skrrd --version")
  end
end
