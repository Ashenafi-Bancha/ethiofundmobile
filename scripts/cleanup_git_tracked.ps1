<#
Removes common generated/build artifacts from the git index while keeping them locally.
Usage (PowerShell):
  .\scripts\cleanup_git_tracked.ps1
#>

$items = @('build', '.dart_tool', '.flutter-plugins-dependencies', '.metadata')
foreach ($item in $items) {
  if (Test-Path $item) {
    git rm -r --cached $item 2>$null
  }
}

git add .gitignore
if (-not (git diff --cached --quiet)) {
  git commit -m "chore: untrack generated files" -q
  Write-Host "Committed changes. Please push to remote: git push"
} else {
  Write-Host "No changes to commit. .gitignore already up-to-date or nothing to untrack."
}
