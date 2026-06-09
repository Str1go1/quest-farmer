#!/bin/bash

DESKTOP="$HOME/Desktop"
VERSION="2.1.0"

show_help() {
    echo "Quest Farmer v$VERSION - Universally spoof any Windows process for Discord Quests"
    echo ""
    echo "Usage: quest-farmer [\"Folder/Executable.exe\"] [\"Folder/Exec1.exe,Exec2.exe\"]"
    echo "       quest-farmer [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help menu"
    echo "  --update      Fetch the latest active quests list from GitHub"
    echo "  --auto        Automatically farm all quests downloaded from the cloud list"
    echo ""
    echo "Examples:"
    echo "  Manual input:  quest-farmer \"Once Human/ONCE_HUMAN.exe\""
    echo "  Cloud sync:    quest-farmer --update"
    echo "  Auto farm:     quest-farmer --auto"
    echo ""
}

CONFIG_DIR="$HOME/.config/quest-farmer"
QUEST_FILE="$CONFIG_DIR/quests.txt"
REPO_URL="https://raw.githubusercontent.com/Str1go1/quest-farmer/main/quests.txt"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
    
elif [[ "$1" == "--update" ]]; then
    echo "Fetching latest active quests from GitHub..."
    mkdir -p "$CONFIG_DIR"
    
    if curl -sL "$REPO_URL" -o "$QUEST_FILE"; then
        echo "Successfully synced the latest quests!"
        echo "Run 'quest-farmer --auto' to farm them all."
    else
        echo "Error: Failed to reach GitHub. Check your internet connection."
    fi
    exit 0

elif [[ "$1" == "--auto" ]]; then
    if [[ ! -f "$QUEST_FILE" ]]; then
        echo "Error: No quest list found locally."
        echo "Please run 'quest-farmer --update' first."
        exit 1
    fi
    
    echo "Loading quests from cloud sync..."
    declare -a fetched_args
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "$line" && "$line" != \#* ]]; then
            fetched_args+=("$line")
        fi
    done < "$QUEST_FILE"
    
    set -- "${fetched_args[@]}"

elif [[ -z "$1" ]]; then
    echo "Error: No quest paths provided."
    show_help
    exit 1
fi

declare -a PIDS=()
declare -a FILES_TO_CLEAN=()
declare -a DIRS_TO_CLEAN=()

echo "Initializing..."

TOTAL_GAMES=0
for arg in "$@"; do
    exec_part="${arg##*/}"
    IFS=',' read -ra EXECS <<< "$exec_part"
    TOTAL_GAMES=$((TOTAL_GAMES + ${#EXECS[@]}))
done

BASE_MINS=15
EXTRA_MINS_PER_GAME=8
TOTAL_MINS=$(( BASE_MINS + (TOTAL_GAMES * EXTRA_MINS_PER_GAME) ))
TOTAL_SECS=$(( TOTAL_MINS * 60 ))

echo "Detected $TOTAL_GAMES game(s). Setting dynamic timer to $TOTAL_MINS minutes ($TOTAL_SECS seconds)..."

for arg in "$@"; do
    if [[ "$arg" == *"/"* ]]; then
        dir_part="${arg%/*}"
        exec_part="${arg##*/}"
        
        target_dir="$DESKTOP/$dir_part"
        mkdir -p "$target_dir"
        
        top_dir="${dir_part%%/*}"
        DIRS_TO_CLEAN+=("$DESKTOP/$top_dir")
    else
        target_dir="$DESKTOP"
        exec_part="$arg"
    fi

    IFS=',' read -ra EXECS <<< "$exec_part"
    
    for exe in "${EXECS[@]}"; do
        exe=$(echo "$exe" | xsetW 2>/dev/null || echo "$exe" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        target_file="$target_dir/$exe"
        
        cp /bin/sleep "$target_file"
        
        "$target_file" $TOTAL_SECS &
        PIDS+=($!)
        FILES_TO_CLEAN+=("$target_file")
        
        echo " -> Spoofing: $dir_part -> $exe"
    done
done

echo "--------------------------------------------------------"
echo "All custom dummy processes are running in the background."
echo "CRITICAL: Ensure you clicked 'Accept Quest' in Discord!"
echo "Waiting ~$TOTAL_MINS minutes for completion... Do not close terminal."
echo "--------------------------------------------------------"

cleanup_on_interrupt() {
    echo -e "\n\n[!] Interrupted! Terminating background processes and cleaning up..."
    for pid in "${PIDS[@]}"; do
        kill "$pid" 2>/dev/null
    done
}
trap cleanup_on_interrupt SIGINT

wait "${PIDS[@]}" 2>/dev/null

echo "Cleaning up environment safely..."

for file in "${FILES_TO_CLEAN[@]}"; do
    rm -f "$file" 2>/dev/null
done

for dir in "${DIRS_TO_CLEAN[@]}"; do
    if [ "$dir" != "$DESKTOP" ]; then
        rm -rf "$dir" 2>/dev/null
    fi
done

echo "Desktop restored to normal."
