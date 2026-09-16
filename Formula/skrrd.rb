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
#   https://updates.oversky.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/skrrd-<platform>-<arch>. Those objects exist
# from the add phase of the asset-stem rename: the release publishes the same
# bytes under both `oversky-<platform>` and `skrrd-<platform>`, so this formula
# and the legacy `oversky.rb` beside it describe identical binaries with
# identical checksums.
#
# BASE still names updates.oversky.ai deliberately. That host is the one the
# signed manifests resolve through, and the workflow reads it from one place;
# moving it is a separate change with its own preconditions, not a side effect
# of adding a formula.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.46                — numeric version, no leading "v" (e.g. 0.8.7)
#   https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-darwin-arm64       — CloudFront feed URL for skrrd-darwin-arm64
#   c0b1e42337b8386385d510fb4fce8ebcfdedf34cd9227a4079d3de54db89fe21       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-darwin-x64, a83691eea29e1a9528b1678de96c694c978e541d8a1ba1425d3d102683a1de9c
#   https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-linux-x64,  08556832bd4cf0ab3fe0e89654858da125dc84e0b2bf63e541a3f0f03097b8d3
#   https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-linux-arm64, 07c44387b8f6f0bcea09b32d7e488f48ce72ae3fb53bfea9645c58f66288f720
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
  version "0.8.46"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-darwin-arm64"
      sha256 "c0b1e42337b8386385d510fb4fce8ebcfdedf34cd9227a4079d3de54db89fe21"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-darwin-x64"
      sha256 "a83691eea29e1a9528b1678de96c694c978e541d8a1ba1425d3d102683a1de9c"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-linux-arm64"
      sha256 "07c44387b8f6f0bcea09b32d7e488f48ce72ae3fb53bfea9645c58f66288f720"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/skrrd-linux-x64"
      sha256 "08556832bd4cf0ab3fe0e89654858da125dc84e0b2bf63e541a3f0f03097b8d3"
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
