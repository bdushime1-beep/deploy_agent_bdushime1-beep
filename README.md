# Attendance Tracker Project Setup

This repository contains `setup_project.sh`, which bootstraps the Student Attendance Tracker project automatically.

## What is included

- `setup_project.sh` - master shell script for project creation
- `attendance_tracker_{input}/` - generated project workspace
- `attendance_tracker_{input}/attendance_checker.py` - main application logic
- `attendance_tracker_{input}/Helpers/assets.csv` - sample attendance data
- `attendance_tracker_{input}/Helpers/config.json` - threshold and settings file
- `attendance_tracker_{input}/reports/reports.log` - example report log

## How to run

1. Open a terminal in this folder.
2. Give the script execute permission if needed:
   - `chmod +x setup_project.sh`
3. Run the script:
   - `./setup_project.sh`
4. Follow the prompts:
   - Enter your project identifier
   - Choose whether to update thresholds
   - Enter new warning/failure percentages if requested
   - Optionally set run_mode to `live` or `dry_run`

## How the archive feature works

- The script traps `Ctrl+C` (SIGINT) while it is running.
- If you interrupt the script, it will:
  - create an archive file named `attendance_tracker_{input}_archive.tar.gz`
  - remove the incomplete `attendance_tracker_{input}/` directory
- This keeps the workspace clean when setup is cancelled early.

## Notes

- The script also checks whether `python3` is installed by running `python3 --version`.
- If `python3` is missing, it prints a warning but still completes the directory and file setup.

## Video link

https://youtu.be/j63kB3F1d9c