<#
redistribute-oct20.ps1

Finds all commits authored on a target date (Oct 20, 2025),
and redistributes those commits' author+committer dates across
the last N non-weekend days (randomized). Writes rewritten
history to a new orphan branch so you can inspect before forcing.

USAGE:
  # dry-run (preview)
  powershell -ExecutionPolicy Bypass -File .\redistribute-oct20.ps1 -DryRun

  # real run
  powershell -ExecutionPolicy Bypass -File .\redistribute-oct20.ps1

#>

param(
    [switch]$DryRun,                        # preview only (no rewriting)
    [string]$YourName = "Corey Crooks",
    [string]$YourEmail = "crookscorey@gmail.com",  # must match GitHub account email
    [datetime]$TargetDate = ([datetime]"2025-10-20"),
    [int]$NumDays = 263                      # how many distinct target dates to use
)

# --------------------------
function Write-ErrAndExit($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

# Safety: ensure we're inside a git repo
if (-not (Test-Path ".git")) {
    Write-ErrAndExit "This script must be run from the root of a git repository (where the .git folder lives)."
}

# 1) Gather commits with author date == TargetDate (local date)
Write-Host "Scanning repo for commits authored on $($TargetDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan
$allShas = git rev-list --reverse HEAD | ForEach-Object { $_.Trim() } 

$targetShas = @()
foreach ($sha in $allShas) {
    # get the author date in ISO-like form (with timezone)
    $raw = git log -1 --pretty=format:%ai $sha 2>$null
    if (-not $raw) { continue }
    try {
        $authorDt = [datetime]::Parse($raw)
    } catch {
        # fallback: skip if parse fails
        continue
    }

    if ($authorDt.Date -eq $TargetDate.Date) {
        $targetShas += $sha
    }
}

$found = $targetShas.Count
Write-Host "Found $found commit(s) on $($TargetDate.ToString('yyyy-MM-dd'))."

if ($found -eq 0) {
    Write-ErrAndExit "No commits found on the target date. Aborting."
}

if ($found -ne $NumDays) {
    Write-Host "Note: requested $NumDays redistribution days, but found $found commits to redistribute." -ForegroundColor Yellow
    Write-Host "The script will generate $found new target dates (one per commit found)." -ForegroundColor Yellow
    $NumDays = $found
}

# 2) Generate N non-weekend dates starting from today and going backwards,
#    skipping weekends. Collect the first $NumDays such dates then shuffle.

Write-Host "Generating $NumDays non-weekend dates (from today backwards)..." -ForegroundColor Cyan
$dates = @()
$cursor = (Get-Date).Date  # start from today (you can change to AddDays(-1) if you prefer exclude today)
while ($dates.Count -lt $NumDays) {
    $cursor = $cursor.AddDays(-1)  # step backwards 1 day each iteration

    # skip weekends
    if ($cursor.DayOfWeek -eq 'Saturday' -or $cursor.DayOfWeek -eq 'Sunday') { continue }

    # use the date (time will be randomized later)
    $dates += $cursor
}

# Randomize the order of dates so assignment is not strictly chronological
$random = New-Object System.Random
$shuffledDates = $dates | Sort-Object { $random.Next() }

# For extra realism, convert dates to random times within workday hours (08:00 - 20:00)
$assignedDateTimes = @()
foreach ($d in $shuffledDates) {
    $hour = Get-Random -Minimum 8 -Maximum 21    # 8..20 hours
    $minute = Get-Random -Minimum 0 -Maximum 59
    $second = Get-Random -Minimum 0 -Maximum 59
    $assignedDateTimes += $d.AddHours($hour).AddMinutes($minute).AddSeconds($second)
}

# Verify 1-to-1 mapping
if ($assignedDateTimes.Count -ne $found) {
    Write-ErrAndExit "Internal error: generated date count does not match number of target commits."
}

# Dry run: list mappings and exit
if ($DryRun) {
    Write-Host "`n=== DRY RUN: Mapping of target commits to new dates ===`n" -ForegroundColor Green
    for ($i = 0; $i -lt $found; $i++) {
        $sha = $targetShas[$i]
        $newDt = $assignedDateTimes[$i].ToString("yyyy-MM-dd HH:mm:ss")
        Write-Host ("{0,3}: {1}  -> {2}" -f ($i+1), $sha, $newDt)
    }
    Write-Host "`nDry run complete. No changes were made. Remove -DryRun to apply changes." -ForegroundColor Cyan
    exit 0
}

# 3) Rebuild history on an orphan branch, replacing dates only for target commits
$newBranch = "redistributed-oct20-" + (Get-Date -Format "yyyyMMddHHmmss")
Write-Host "`nPreparing to write rewritten history onto orphan branch '$newBranch'..." -ForegroundColor Cyan

# Create orphan branch
git checkout --orphan $newBranch 2>$null | Out-Null

# Clear working tree (safe because we'll checkout commit trees)
git reset --hard 2>$null | Out-Null

# We'll iterate through all commits (oldest -> newest). For commits that are in targetShas,
# we'll use an assigned date from $assignedDateTimes (in the same index order). For others
# we'll keep their original author date.
$assignedIndex = 0
$total = $allShas.Count
$counter = 0

foreach ($sha in $allShas) {
    $counter++
    # get the commit message and original author date
    $msg = git log -1 --pretty=%B $sha
    $rawAuthor = git log -1 --pretty=format:%ai $sha
    try { $origAuthorDt = [datetime]::Parse($rawAuthor) } catch { $origAuthorDt = (Get-Date) }

    if ($targetShas -contains $sha) {
        # assign next new datetime
        $newDt = $assignedDateTimes[$assignedIndex]
        $assignedIndex++
        Write-Host ("[{0}/{1}] Rewriting target commit {2} -> {3}" -f $counter, $total, $sha, $newDt.ToString("yyyy-MM-dd HH:mm:ss"))
        $useAuthor = $newDt
    } else {
        # keep original date
        $useAuthor = $origAuthorDt
        Write-Host ("[{0}/{1}] Replaying existing commit {2} -> {3}" -f $counter, $total, $sha, $useAuthor.ToString("yyyy-MM-dd HH:mm:ss"))
    }

    # checkout the commit's tree into working directory
    git checkout $sha -- . 2>$null

    # set author and committer metadata to the chosen date
    $env:GIT_AUTHOR_NAME     = $YourName
    $env:GIT_AUTHOR_EMAIL    = $YourEmail
    $env:GIT_AUTHOR_DATE     = $useAuthor.ToString("yyyy-MM-dd HH:mm:ss")
    $env:GIT_COMMITTER_NAME  = $YourName
    $env:GIT_COMMITTER_EMAIL = $YourEmail
    $env:GIT_COMMITTER_DATE  = $useAuthor.ToString("yyyy-MM-dd HH:mm:ss")

    # create the commit with the original message
    git commit -m "$(echo $msg)" | Out-Null

    # clear index for next checkout
    git rm -r --cached . > $null 2>&1
}

Write-Host "`nDone rewriting history onto branch '$newBranch'." -ForegroundColor Green
Write-Host "Please inspect the branch locally (git log --pretty=fuller) and push it to remote for review:"
Write-Host "  git push origin $newBranch"
Write-Host "When satisfied, you can replace main with:"
Write-Host "  git push --force origin $newBranch:main"
Write-Host "`nNote: GitHub may take some time to reindex contributions for the profile graph." -ForegroundColor Yellow
