#!/usr/bin/env bash
# Update sources.json to the latest (or given) stablyai/orca desktop release.
# Requires: gh (or curl), jq, nix.
set -euo pipefail

cd "$(dirname "$0")"

repo="stablyai/orca"
tag="${1:-}"
if [ -z "$tag" ]; then
  tag="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)"
fi

case "$tag" in
  v[0-9]*) ;;
  *) echo "refusing non-desktop tag: $tag" >&2; exit 1 ;;
esac

version="${tag#v}"
current="$(jq -r .version sources.json)"
if [ "$version" = "$current" ]; then
  echo "already at $version"
  exit 0
fi

declare -A files=(
  [x86_64-linux]="orca-linux.AppImage"
  [aarch64-linux]="orca-linux-arm64.AppImage"
)

assets='{}'
for system in "${!files[@]}"; do
  url="https://github.com/$repo/releases/download/$tag/${files[$system]}"
  hash="$(nix store prefetch-file --json "$url" | jq -r .hash)"
  assets="$(jq --arg s "$system" --arg u "$url" --arg h "$hash" \
    '. + {($s): {url: $u, hash: $h}}' <<<"$assets")"
done

jq -n --arg v "$version" --argjson a "$assets" '{version: $v, assets: $a}' > sources.json.tmp
mv sources.json.tmp sources.json
echo "updated $current -> $version"
