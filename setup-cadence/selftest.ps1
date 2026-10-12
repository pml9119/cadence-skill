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

# ticket 05: rework journey. ready(-12) -> building(-10) -> verifying(-8) -> building(-5, rework!) -> done(-2).
# Cycle time should start from last building (-5) to done (-2) = 3 days, not 10 days.
NewTicket 'backlog/tasks/05-rework.md' '05: Rework' 'ready'
Commit 'add 05' $now.AddDays(-12)
SetStatus 'backlog/tasks/05-rework.md' 'building'
Commit '05 to building' $now.AddDays(-10)
SetStatus 'backlog/tasks/05-rework.md' 'verifying'
Commit '05 to verifying' $now.AddDays(-8)
SetStatus 'backlog/tasks/05-rework.md' 'building'
Commit '05 rejected back to building' $now.AddDays(-5)
SetStatus 'backlog/tasks/05-rework.md' 'done'
Commit '05 finally done' $now.AddDays(-2)

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
Write-Output "rework     : total=$($j.rework.totalReworks) tickets=$($j.rework.reworkTickets) rate=$($j.rework.rate)"
Write-Output "backlog wk : $($j.backlog.Count) rows   cfd: $($j.cfd.Count) rows"

# ---------- assertions: the gate. Any mismatch fails the run. ----------
$fail = New-Object System.Collections.ArrayList

function Check([string]$what, $actual, $expected) {
  if ("$actual" -ne "$expected") {
    [void]$fail.Add("$what  expected=$expected  actual=$actual")
  }
}

# day values can drift by a rounding step if the clock ticks between
# Commit() and the node run, so compare them with a tolerance of 1 hour.
function CheckDays([string]$what, $actual, $expected) {
  if ($null -eq $actual -or [math]::Abs([double]$actual - [double]$expected) -gt 0.05) {
    [void]$fail.Add("$what  expected=$expected  actual=$actual")
  }
}

Write-Output ''
Write-Output '===== assertions ====='

Check   'tickets'              $j.tickets                 5
Check   'counts.fog'           $j.counts.fog              1
Check   'counts.verifying'     $j.counts.verifying        1
Check   'counts.done'          $j.counts.done             2
Check   'counts.other'         $j.counts.other            1
Check   'verifying.count'      $j.verifying.count         1
Check   'verifying.overAlert'  $j.verifying.overAlert     'True'
CheckDays 'verifying.oldestDays'  $j.verifying.oldestDays  6
CheckDays 'cycleTime.max'         $j.cycleTimeDays.max     5
Check   'rework.totalReworks'  $j.rework.totalReworks     1
Check   'rework.reworkTickets' $j.rework.reworkTickets    1

# The rework ticket must NOT count as a 10-day cycle: its clock restarts at the
# last `building` (-5), so the two done tickets are 5 days and 3 days -> median 3.
CheckDays 'cycleTime.median (rework clock restart)' $j.cycleTimeDays.median 3
Check   'cfd rows'             $j.cfd.Count               30

if ($fail.Count -eq 0) {
  Write-Output 'PASS  all 13 assertions matched'
} else {
  Write-Output "FAIL  $($fail.Count) assertion(s) failed:"
  foreach ($f in $fail) { Write-Output "  - $f" }
  Set-Location $startDir
  exit 1
}

Set-Location $startDir
