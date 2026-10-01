# cadence-selftest.ps1 -- verify flow-metrics.mjs parsing and stats on a temp git repo.
# NOTE: comments are ASCII-only on purpose. Windows PowerShell 5.1 reads a UTF-8
# file without BOM as ANSI/GBK, and non-ASCII comment bytes can swallow the next line.
$ErrorActionPreference = 'Stop'
$repo = Join-Path $env:TEMP 'cadence-selftest'
# This script cd's into a temp repo, so it must put the caller back afterwards.
# Without this, a caller's next command silently runs in the temp directory.
$startDir = (Get-Location).Path
if (Test-Path $repo) { Remove-Item $repo -Recurse -Force }
New-Item -ItemType Directory -Path $repo | Out-Null
Set-Location $repo
git init -q | Out-Null
git config user.email t@example.com
git config user.name Tester
# Kill the LF/CRLF warning at its source. PS 5.1 turns native stderr into a
# terminating error under $ErrorActionPreference='Stop', so one cosmetic git
# warning would abort the whole test.
git config core.autocrlf false

function Commit([string]$msg, [datetime]$when) {
  $env:GIT_AUTHOR_DATE = $when.ToString('yyyy-MM-ddTHH:mm:sszzz')
  $env:GIT_COMMITTER_DATE = $env:GIT_AUTHOR_DATE
  git add -A 2>&1 | Out-Null
  git commit -q -m $msg 2>&1 | Out-Null
}
function SetStatus([string]$path, [string]$value) {
  $raw = Get-Content $path -Raw
  $raw = $raw -replace '(?m)^\*\*Status:\*\*.*$', "**Status:** $value"
  Set-Content -Path $path -Value $raw -NoNewline
}
function NewTicket([string]$path, [string]$name, [string]$value) {
  Set-Content -Path $path -Value "# $name`n`n**Status:** $value`n" -NoNewline
}

$now = Get-Date
New-Item -ItemType Directory -Path 'backlog/tasks' -Force | Out-Null

# ticket 01: full journey. ready -> done should be 5 days.
NewTicket 'backlog/tasks/01-alpha.md' '01: Alpha' 'ready'
Commit 'add 01' $now.AddDays(-20)
SetStatus 'backlog/tasks/01-alpha.md' 'building'
Commit '01 to building' $now.AddDays(-18)
SetStatus 'backlog/tasks/01-alpha.md' 'verifying'
Commit '01 to verifying' $now.AddDays(-17)
SetStatus 'backlog/tasks/01-alpha.md' 'done'
Commit '01 to done' $now.AddDays(-15)

# ticket 02: stuck in verifying for 6 days. should trip the alert.
NewTicket 'backlog/tasks/02-beta.md' '02: Beta' 'ready'
Commit 'add 02' $now.AddDays(-10)
SetStatus 'backlog/tasks/02-beta.md' 'building'
Commit '02 to building' $now.AddDays(-8)
SetStatus 'backlog/tasks/02-beta.md' 'verifying'
Commit '02 to verifying' $now.AddDays(-6)

# ticket 03: parked in fog.
NewTicket 'backlog/tasks/03-gamma.md' '03: Gamma' 'fog'
Commit 'add 03' $now.AddDays(-5)

# ticket 04: unrecognised status. must land in `other`, not be dropped.
NewTicket 'backlog/tasks/04-delta.md' '04: Delta' 'weird-status'
Commit 'add 04' $now.AddDays(-3)

$tool = Join-Path $PSScriptRoot 'flow-metrics.mjs'

Write-Output '===== text report ====='
node $tool

Write-Output ''
Write-Output '===== json fields ====='
node $tool --json > "$repo\out.json"
$j = Get-Content "$repo\out.json" -Raw | ConvertFrom-Json
Write-Output "tracker    : $($j.tracker)"
Write-Output "tickets    : $($j.tickets)"
Write-Output "counts     : fog=$($j.counts.fog) discovery=$($j.counts.discovery) ready=$($j.counts.ready) building=$($j.counts.building) verifying=$($j.counts.verifying) done=$($j.counts.done) other=$($j.counts.other)"
Write-Output "verifying  : count=$($j.verifying.count) oldestDays=$($j.verifying.oldestDays) overAlert=$($j.verifying.overAlert)"
Write-Output "oldest file: $($j.verifying.oldest)"
Write-Output "cycleTime  : n=$($j.cycleTimeDays.n) median=$($j.cycleTimeDays.median) max=$($j.cycleTimeDays.max)"
Write-Output "backlog wk : $($j.backlog.Count) rows   cfd: $($j.cfd.Count) rows"

Set-Location $startDir
