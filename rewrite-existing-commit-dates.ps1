# Adjust existing commit dates only
# Run: powershell -ExecutionPolicy Bypass -File rewrite-existing-commit-dates.ps1

# ==== SETTINGS ====
$YourName  = "Corey Crooks"
$YourEmail = "crookscorey@gmail.com"   # must match GitHub profile email
$StartDate = [datetime]"2024-11-05"
$EndDate   = Get-Date
# ==================

# Collect all commit SHAs (oldest first)
$commits = git rev-list --reverse HEAD
$total = $commits.Count
Write-Host "Found $total commits."

# Helper: is weekend?
function Is-Weekend($date) {
    return ($date.DayOfWeek -eq "Saturday" -or $date.DayOfWeek -eq "Sunday")
}

# Generate randomized commit dates
$daysRange = ($EndDate - $StartDate).Days
$dates = @()
$currentDate = $EndDate

for ($i = 0; $i -lt $total; $i++) {
    # Step back 1–3 days, skip most weekends
    $step = Get-Random -Minimum 1 -Maximum 4
    $currentDate = $currentDate.AddDays(-$step)

    # Occasionally skip weekends (80% of the time)
    if (Is-Weekend $currentDate -and (Get-Random -Minimum 0 -Maximum 10) -ge 2) {
        while (Is-Weekend $currentDate) {
            $currentDate = $currentDate.AddDays(-1)
        }
    }

    # Randomize time of day (workday hours)
    $hour = Get-Random -Minimum 8 -Maximum 22
    $minute = Get-Random -Minimum 0 -Maximum 59
    $dates += $currentDate.Date.AddHours($hour).AddMinutes($minute)
}

$dates = $dates[($dates.Length-1)..0]
Write-Host "Generated $($dates.Length) new timestamps. Rewriting commits..."

# --- Rewrite commits ---
$newBranch = "date-rewrite"
git checkout --orphan $newBranch

for ($j = 0; $j -lt $commits.Length; $j++) {
    $sha = $commits[$j]
    $date = $dates[$j].ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "Rewriting commit $($j+1)/$total ($sha) → $date"

    git checkout $sha -- .

    $env:GIT_AUTHOR_NAME     = $YourName
    $env:GIT_AUTHOR_EMAIL    = $YourEmail
    $env:GIT_AUTHOR_DATE     = $date
    $env:GIT_COMMITTER_NAME  = $YourName
    $env:GIT_COMMITTER_EMAIL = $YourEmail
    $env:GIT_COMMITTER_DATE  = $date

    $msg = git log -1 --pretty=%B $sha
    git commit -m "$msg" | Out-Null
}

Write-Host "All commits rewritten onto branch '$newBranch'."
Write-Host "Next: force push with:"
Write-Host "    git push --force origin $newBranch:main"
