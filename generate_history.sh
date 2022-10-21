#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
START_DATE="2022-10-20"
END_DATE="2022-12-20"
MIN_COMMITS=2
MAX_COMMITS=3
MIN_DAYS_PER_WEEK=2
MAX_DAYS_PER_WEEK=3

# Commit messages pool
MESSAGES=(
  "Initial setup"
  "Fix bug in logic"
  "Refactor code structure"
  "Add new feature"
  "Improve performance"
  "Update documentation"
  "Minor cleanup"
  "Add tests"
  "Improve UI/UX"
  "Remove unused code"
)

# Convert dates to seconds since epoch
start_sec=$(date -d "$START_DATE" +%s)
end_sec=$(date -d "$END_DATE" +%s)
one_day=$((24*60*60))

# Store generated dates
DATES=()

cur_sec=$start_sec
while [ "$cur_sec" -le "$end_sec" ]; do
    # Collect all weekdays of this week
    week_days=()
    for i in {0..6}; do
        d_sec=$((cur_sec + i*one_day))
        if [ "$d_sec" -gt "$end_sec" ]; then
            break
        fi
        day_of_week=$(date -d "@$d_sec" +%u)
        if [ "$day_of_week" -lt 6 ]; then
            week_days+=($d_sec)
        fi
    done

    # Randomly pick 3–4 days this week
    n_days=$((RANDOM % (MAX_DAYS_PER_WEEK - MIN_DAYS_PER_WEEK + 1) + MIN_DAYS_PER_WEEK))
    selected_days=($(shuf -e "${week_days[@]}" -n $n_days))

    # Generate 4–5 commits per selected day
    for day_sec in "${selected_days[@]}"; do
        n_commits=$((RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS))
        for ((i=0; i<n_commits; i++)); do
            hour=$((RANDOM % 10 + 9))       # 9-18
            min=$((RANDOM % 60))
            sec=$((RANDOM % 60))
            date_str=$(date -d "@$day_sec" +%Y-%m-%d)
            full_date="${date_str}T$(printf "%02d:%02d:%02d" $hour $min $sec)"
            DATES+=("$full_date")
        done
    done

    # Move to next week
    cur_sec=$((cur_sec + 7*one_day))
done

echo "Generated ${#DATES[@]} commit timestamps..."

# Ensure a file exists to modify each commit
if [ ! -f history.log ]; then
  echo "History start" > history.log
  git add -f history.log
fi

# Loop over dates and commit
for d in "${DATES[@]}"; do
    msg="${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}"
    echo "$d - $msg" >> history.log

    git add -f history.log
    GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git commit -m "$msg" >/dev/null
    echo "Committed: $d | $msg"
done

echo "✅ Done! Created ${#DATES[@]} commits."