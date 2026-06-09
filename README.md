# 🚜 Discord Quest Farmer

A lightweight, dynamic command-line utility designed for **Linux** to automate Discord Quest progress by safely spoofing game processes. 

*Note: This tool is currently built specifically for Linux environments (utilizing Bash and native Linux coreutils like `sleep`). Windows support may be explored in the future!*

## ✨ Features

* **Universal Spoofing:** Can mimic any folder structure and `.exe` name Discord is looking for. No hardcoded game lists required.
* **Concurrent Farming:** Farm 5+ quests at the exact same time in the background.
* **Dynamic Timing Engine:** Automatically calculates the required runtime (15 minutes base + 8 minutes per extra game) to bypass Discord's background telemetry throttling.
* **Cloud Sync:** Update your active quest list directly from a GitHub repository using a single command.
* **Safe & Clean:** Uses the native, harmless Linux `/bin/sleep` command. Automatically cleans up all dummy files and folders the second the timer finishes. 100% safe from game-bound malware.

## 🚀 Installation

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/YOUR_USERNAME/discord-quest-farmer/main/quest-farmer
   ```
2. Make it executable:
   ```bash
   chmod +x quest-farmer
   ```
3. Move it to your local binaries folder so you can run it from anywhere:
   ```bash
   mkdir -p ~/.local/bin
   mv quest-farmer ~/.local/bin/
   ```
*(Note: You may need to restart your terminal or run `source ~/.bashrc` if `~/.local/bin` is not already in your PATH).*

## 🎮 Usage

### 1. The Auto-Farmer (Recommended)
Sync the latest active quests from the cloud and farm them all simultaneously.
```bash
# Fetch the latest quests.txt from GitHub
quest-farmer --update

# Run all fetched quests in the background
quest-farmer --auto
```

### 2. Manual Input
You can manually pass exact file paths as arguments.
```bash
# Single game
quest-farmer "Once Human/ONCE_HUMAN.exe"

# Multiple separate games
quest-farmer "Game/Endfield.exe" "EA SPORTS FC 26/FC26.exe"

# Multiple executables in one folder (comma-separated)
quest-farmer "WoT HEAT/HEAT.exe,WorldOfTanks.exe"
```

## ⚙️ Configuration (`quests.txt`)

If you are hosting your own list on GitHub, the script looks for a raw `quests.txt` file. The format is exactly one game path per line. 

Example `quests.txt`:
```text
Duet Night Abyss/EM-Win64-Shipping.exe
Win64/HTGame.exe,Win64r/HTGame.exe
RobloxPlayerBeta.exe
Game/Endfield.exe
EscapeTheBackrooms/Binaries/Win64/Backrooms-Win64-Shipping.exe
EA SPORTS FC 26/FC26.exe
```

*To change the URL the script pulls from, simply edit the `REPO_URL` variable at the top of the `quest-farmer` script.*

## ⚠️ Disclaimer
This script is a third-party tool created for Linux users who cannot natively run Discord's game detection system. It does not interact with the Discord API or client memory. It simply creates harmless dummy processes. Use at your own discretion.
