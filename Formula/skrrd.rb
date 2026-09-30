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
#   0.8.82                — numeric version, no leading "v" (e.g. 0.8.7)
#   https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-darwin-arm64       — CloudFront feed URL for skrrd-darwin-arm64
#   6dc213ee669c9bf4da4a08f0067928a19f7637f794b39d1bf7bb8aaf0b7a6a68       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-darwin-x64, 9956cd3ec045085162acbcbe37629e63ddf63eba43f0070cbb237bf9a130568b
#   https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-linux-x64,  ffb62c2438ebd59c53eb752b82344eade11bb2a40c3d7cce87cb4baaea397e0f
#   https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-linux-arm64, 9dfef79dffedf14cde5742f2128eaede5ee4110ded0765f9b81011d6fcbfb819
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
  version "0.8.82"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-darwin-arm64"
      sha256 "6dc213ee669c9bf4da4a08f0067928a19f7637f794b39d1bf7bb8aaf0b7a6a68"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-darwin-x64"
      sha256 "9956cd3ec045085162acbcbe37629e63ddf63eba43f0070cbb237bf9a130568b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-linux-arm64"
      sha256 "9dfef79dffedf14cde5742f2128eaede5ee4110ded0765f9b81011d6fcbfb819"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/skrrd-linux-x64"
      sha256 "ffb62c2438ebd59c53eb752b82344eade11bb2a40c3d7cce87cb4baaea397e0f"
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
