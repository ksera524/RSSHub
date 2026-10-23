#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/sync-upstream.sh [--no-push]
pushChanges=true
case "${1:-}" in
    '') ;;
    --no-push) pushChanges=false ;;
    -h|--help)
        echo "Usage: $0 [--no-push]"
        echo "Merge upstream/master into master and push to origin (unless --no-push)."
        exit 0
        ;;
    *) echo "Usage: $0 [--no-push]" >&2; exit 1 ;;
esac
if (( $# > 1 )); then
    echo "Usage: $0 [--no-push]" >&2
    exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Commit or stash your changes (including untracked files) before syncing." >&2
    exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
    git remote add upstream https://github.com/DIYgod/RSSHub.git
fi

git fetch upstream
git switch master
if ! git merge --no-edit upstream/master; then
    echo "Merge failed. Check git status; resolve conflicts, git add and git commit." >&2
    echo "To cancel an in-progress merge, run: git merge --abort" >&2
    echo "After resolving the merge, rerun this script to finish syncing." >&2
    exit 1
fi

if [[ "$pushChanges" == true ]]; then
    git push origin master
fi
