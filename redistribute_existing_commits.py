import subprocess
import random
from datetime import datetime, timedelta

# === CONFIG ===
total_commits = 262
start_date = datetime(2024, 8, 2)
end_date = datetime(2025, 10, 20)
max_commits_per_day = 3
prob_weekend = 0.08
prob_friday = 0.15

# === 1. Get commit SHAs (most recent first) ===
result = subprocess.run(
    ["git", "rev-list", "--max-count", str(total_commits), "HEAD"],
    capture_output=True, text=True
)
commits = result.stdout.strip().split("\n")[::-1]  # oldest first

if len(commits) < total_commits:
    print(f"⚠️ Found only {len(commits)} commits, expected {total_commits}. Adjust the script.")
    total_commits = len(commits)

# === 2. Build realistic date distribution ===
date_range = (end_date - start_date).days
dates = []

for i in range(date_range + 1):
    day = start_date + timedelta(days=i)
    weekday = day.weekday()  # Mon=0, Sun=6

    if weekday < 5 or \
       (weekday == 4 and random.random() < prob_friday) or \
       (weekday > 4 and random.random() < prob_weekend):
        dates.append(day)

random.shuffle(dates)

commit_days = []
remaining = total_commits

for day in dates:
    if remaining <= 0:
        break

    commits_today = 1
    if random.random() < 0.25:
        commits_today = random.randint(1, max_commits_per_day)
    commits_today = min(commits_today, remaining)

    if day.date() == end_date.date():
        commits_today = random.randint(1, 2)

    commit_days.extend([day] * commits_today)
    remaining -= commits_today

commit_days.sort()

if len(commit_days) < total_commits:
    # Fill any missing with most recent day
    while len(commit_days) < total_commits:
        commit_days.append(end_date)

# === 3. Rewrite commit dates ===
for sha, commit_day in zip(commits, commit_days):
    hour = random.randint(8, 19)
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    full_time = commit_day.replace(hour=hour, minute=minute, second=second)
    git_date = full_time.strftime("%Y-%m-%dT%H:%M:%S")

    env = {
        "GIT_COMMITTER_DATE": git_date,
        "GIT_AUTHOR_DATE": git_date
    }

    subprocess.run(
        ["git", "filter-branch", "--env-filter",
         f'if [ $GIT_COMMIT = {sha} ]; then export GIT_AUTHOR_DATE="{git_date}"; export GIT_COMMITTER_DATE="{git_date}"; fi',
         "--", "HEAD"],
        env=env
    )

print(f"✅ Rewrote {total_commits} commit dates from {start_date.date()} → {end_date.date()}")
print("💡 Review changes, then push with:")
print("   git push origin main --force")