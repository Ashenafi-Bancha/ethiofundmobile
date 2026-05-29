#!/usr/bin/env bash
# Removes generated/build artifacts from git index while keeping local files
set -euo pipefail
items=(build .dart_tool .flutter-plugins-dependencies .metadata)
for item in "${items[@]}"; do
  if [ -e "$item" ]; then
    git rm -r --cached "$item" 2>/dev/null || true
  fi
done

git add .gitignore
if ! git diff --cached --quiet; then
  git commit -m "chore: untrack generated files"
  echo "Committed changes. Run: git push"
else
  echo "No changes to commit. .gitignore already up-to-date or nothing to untrack."
fi
