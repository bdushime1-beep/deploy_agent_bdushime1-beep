



\

#!/bin/bash


echo "============================================="
echo "  Student Attendance Tracker — Project Setup"
echo "============================================="
echo ""
echo "Enter a project identifier (e.g. your name or batch ID):"
read -r PROJECT_INPUT

PROJECT_DIR="attendance_tracker_${PROJECT_INPUT}"

cleanup_on_interrupt() {
    echo ""
    echo "[!] Interrupt detected! Bundling current state into an archive..."

    tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR" 2>/dev/null

    if [ -f "${PROJECT_DIR}_archive.tar.gz" ]; then
        echo "[✓] Archive saved as: ${PROJECT_DIR}_archive.tar.gz"
    fi

    rm -rf "$PROJECT_DIR"
    echo "[✓] Incomplete directory '${PROJECT_DIR}/' removed."
    echo "    Re-run the script whenever you are ready."
    exit 1
}

trap cleanup_on_interrupt SIGINT
echo ""
echo "[*] Creating project structure under '${PROJECT_DIR}/'..."

mkdir -p "${PROJECT_DIR}/Helpers"
mkdir -p "${PROJECT_DIR}/reports"

echo "[✓] Directories created."

cat > "${PROJECT_DIR}/attendance_checker.py" << 'PYTHON'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYTHON

echo "[✓] attendance_checker.py written."

cat > "${PROJECT_DIR}/Helpers/assets.csv" << 'CSV'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSV

echo "[✓] Helpers/assets.csv written."

cat > "${PROJECT_DIR}/Helpers/config.json" << 'JSON'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSON

echo "[✓] Helpers/config.json written."

cat > "${PROJECT_DIR}/reports/reports.log" << 'LOG'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
LOG

echo "[✓] reports/reports.log written."

echo ""
echo "---------------------------------------------"
echo " Attendance Threshold Configuration"
echo "---------------------------------------------"
echo "Current defaults: Warning 75% | Failure 50% | Sessions 15"
echo ""
echo "Do you want to update these thresholds? (yes/no):"
read -r UPDATE_CONFIG

if [[ "$UPDATE_CONFIG" == "yes" || "$UPDATE_CONFIG" == "y" ]]; then

    echo "Enter new WARNING threshold % (default 75):"
    read -r NEW_WARNING

    echo "Enter new FAILURE threshold % (default 50):"
    read -r NEW_FAILURE

    echo "Enter total number of sessions (default 15):"
    read -r NEW_SESSIONS

    sed -i "s/\"warning\": [0-9]*/\"warning\": ${NEW_WARNING}/" \
        "${PROJECT_DIR}/Helpers/config.json"

    sed -i "s/\"failure\": [0-9]*/\"failure\": ${NEW_FAILURE}/" \
        "${PROJECT_DIR}/Helpers/config.json"

    sed -i "s/\"total_sessions\": [0-9]*/\"total_sessions\": ${NEW_SESSIONS}/" \
        "${PROJECT_DIR}/Helpers/config.json"

    echo "[✓] config.json updated — Warning: ${NEW_WARNING}% | Failure: ${NEW_FAILURE}% | Sessions: ${NEW_SESSIONS}"
else
    echo "[*] Keeping defaults (Warning: 75% | Failure: 50% | Sessions: 15)."
fi

echo ""
echo "Set run_mode — type 'live' or 'dry_run' (default: live):"
read -r NEW_RUN_MODE

if [[ "$NEW_RUN_MODE" == "dry_run" ]]; then
    sed -i "s/\"run_mode\": \"live\"/\"run_mode\": \"dry_run\"/" \
        "${PROJECT_DIR}/Helpers/config.json"
    echo "[✓] run_mode set to: dry_run"
else
    echo "[*] run_mode stays: live"
fi

echo ""
echo "---------------------------------------------"
echo " Environment Health Check"
echo "---------------------------------------------"

if python3 --version &>/dev/null; then
    PYTHON_VER=$(python3 --version)
    echo "[✓] Python3 found: ${PYTHON_VER}"
else
    echo "[!] WARNING: python3 is NOT installed."
    echo "    Install: sudo apt install python3    (Linux)"
    echo "    Install: brew install python3        (macOS)"
fi

echo ""
echo "[*] Verifying directory structure..."

REQUIRED_FILES=(
    "${PROJECT_DIR}/attendance_checker.py"
    "${PROJECT_DIR}/Helpers/assets.csv"
    "${PROJECT_DIR}/Helpers/config.json"
    "${PROJECT_DIR}/reports/reports.log"
)

ALL_OK=true
for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "    [✓] $FILE"
    else
        echo "    [✗] MISSING: $FILE"
        ALL_OK=false
    fi
done

echo ""
echo "============================================="
if [ "$ALL_OK" = true ]; then
    echo "  Setup Complete!"
    echo ""
    echo "  Project folder : ${PROJECT_DIR}/"
    echo "  Run the app    : cd ${PROJECT_DIR} && python3 attendance_checker.py"
    echo "  Test the trap  : press Ctrl+C while this script runs"
else
    echo "  Setup finished with missing files. Check warnings above."
fi
echo "============================================="
