
#!/bin/bash

###########################
# NuggetPurge v1.0 🚮
# Clean Mac for testing NuggetForge again
###########################

PURPLE="\033[1;35m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

clear
echo -e "${PURPLE}=====================================${RESET}"
echo -e "${PURPLE}         NuggetPurge v1.0            ${RESET}"
echo -e "${PURPLE}=====================================${RESET}"

# Virtual Env
echo -e "${YELLOW}Removing virtual environment...${RESET}"
rm -rf ~/Downloads/nuggetforge_env

# Homebrew uninstall
echo -e "${YELLOW}Uninstalling Python 3.12...${RESET}"
brew uninstall python@3.12 &> /dev/null

echo -e "${YELLOW}Uninstalling ffmpeg...${RESET}"
brew uninstall ffmpeg &> /dev/null

# Build cleanup
echo -e "${YELLOW}Cleaning build folders...${RESET}"
rm -rf ~/Downloads/Nugget-main/dist
rm -rf ~/Downloads/Nugget-main/build
rm -f  ~/Downloads/Nugget-main/NuggetApp.spec

# PyInstaller cache
echo -e "${YELLOW}Cleaning PyInstaller cache...${RESET}"
rm -rf ~/.cache/pyinstaller

echo -e "${GREEN}✅ All cleaned. System is ready for fresh NuggetForge test.${RESET}"
