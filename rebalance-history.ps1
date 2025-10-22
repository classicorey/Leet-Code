# Rebalance Git commit history with realistic distribution
# Run: powershell -ExecutionPolicy Bypass -File rebalance-history.ps1

# ==== SETTINGS (edit these) ====
$YourName  = "Corey Crooks"
$YourEmail = "crookscorey@gmail.com"   # must match GitHub profile email
# =================================

# Date range
$startDate = Get-Date "2022-03-15"
$endDate   = Get-Date "2024-07-29"

# Keep these days as spikes (3 commits each)
$specialDates = @(
    Get-Date "2025-10-20",
    Get-Date "2025-08-31",
    Get-Date "2024-08-06"
)

# Get commits (oldest → newest)
$commits = git rev-list --reverse HEAD
$total = $commits.Count
Write-Host "Found $total commits to redistribute."

# --- Helper functions ---
function Is-Weekend($d) {
    return ($d.DayOfWeek -eq "Saturday" -or $d.DayOfWeek -eq "Sunday")
}

function Get-RandomDate($minDate, $maxDate) {
    $days = ($maxDate - $minDate).Days
    $randomDays = Get-Random -Minimum 0 -Maximum $days
    return $minDate.AddDays($randomDays)
}

# --- Assign dates ---
$dates = @()

# Reserve 3 commits for each special date
foreach ($sd in $specialDates) {
    for ($i = 0; $i -lt 3; $i++) {
        $dates += $sd
    }
}
$remaining = $total - $dates.Count
Write-Host "Reserved $($dates.Count) commits for special dates."
Write-Host "Redistributing remaining $remaining commits..."

$current = $endDate
while ($dates.Count -lt $total) {
    # Step backward randomly 1–3 days
    $step = Get-Random -Minimum 1 -Maximum 4
    $current = $current.AddDays(-$step)

    # Skip weekends 85% of the time
    if (Is-Weekend $current) {
        if ((Get-Random -Minimum 0 -Maximum 10) -ge 2) {
            while (Is-Weekend $current) {
                $current = $current.AddDays(-1)
            }
        }
    }

    if ($current -lt $startDate) { break }

    # Group up to 4 commits on same day
    $group = Get-Random -Minimum 1 -Maximum 5
    for ($g=0; $g -lt $group -and $dates.Count -lt $total; $g++) {
        $dates += $current
    }
}

# Shuffle all except special ones (keeps randomness natural)
$otherDates = $dates | Where-Object { $_ -notin $specialDates }
$shuffled = $otherDates | Sort-Object { Get-Random }
$dates = $shuffled + $specialDates

# Ensure count alignment
$dates = $dates[0..($total-1)]

# Reverse for oldest→newest alignment
$dates = $dates[($dates.Length-1)..0]

Write-Host "Generated $($dates.Length) new commit dates."

# --- Rewrite history ---
$newBranch = "rebased-history"
git checkout --orphan $newBranch

for ($i=0; $i -lt $commits.Length; $i++) {
    $sha = $commits[$i]
    $date = $dates[$i].ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$($i+1)/$total] Rewriting $sha → $date"

    git checkout $sha -- .
    $env:GIT_AUTHOR_NAME     = $YourName
    $env:GIT_AUTHOR_EMAIL    = $YourEmail
    $env:GIT_AUTHOR_DATE     = $date
    $env:GIT_COMMITTER_NAME  = $YourName
    $env:GIT_COMMITTER_EMAIL = $YourEmail
    $env:GIT_COMMITTER_DATE  = $date

    git commit -m "$(git log -1 --pretty=%B $sha)" --quiet
    git rm -r --cached . > $null 2>&1
}

Write-Host "`n✅ Rewriting complete. Now pushing to main..."
git push origin $newBranch:main --force
Write-Host "`nDone! Your GitHub contribution graph will update within minutes."