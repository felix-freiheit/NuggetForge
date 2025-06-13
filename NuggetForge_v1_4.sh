
#!/bin/bash

# NuggetForge v1.4: Final Clean Edition (Intel macOS)

#####################
# STYLE DEFINITIONS #
#####################
PURPLE="\033[1;35m"
BLACK="\033[30m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

# Header Banner
clear
echo -e "${PURPLE}=====================================${RESET}"
echo -e "${PURPLE}          NuggetForge v1.4          ${RESET}"
echo -e "${PURPLE}  Fully Automated MacOS Builder     ${RESET}"
echo -e "${PURPLE}=====================================${RESET}"

# Progress bar function (accurate)
progress_bar() {
  local progress=$1
  local total=$2
  local done=$((progress*40/total))
  local left=$((40-done))
  printf "["
  for ((i=0;i<done;i++)); do printf "${GREEN}━${RESET}"; done
  for ((i=0;i<left;i++)); do printf "${RED}━${RESET}"; done
  printf "] [$((progress*100/total))%%]\r"
}

# Homebrew

echo -e "${YELLOW}Checking Homebrew...${RESET}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null
    echo -e "${GREEN}Homebrew installed.${RESET}"
else
    echo -e "${GREEN}Homebrew already installed.${RESET}"
fi

# Python 3.12 check

echo -e "${YELLOW}Checking Python...${RESET}"
PYTHON_PATH="/usr/local/opt/python@3.12/bin/python3.12"
if [ ! -f "$PYTHON_PATH" ]; then
    echo -e "${YELLOW}Installing Python 3.12...${RESET}"
    brew install python@3.12 &> /dev/null
    echo -e "${GREEN}Python successfully installed with version $($PYTHON_PATH --version | awk '{print $2}')${RESET}"
else
    echo -e "${GREEN}Python successfully installed with version $($PYTHON_PATH --version | awk '{print $2}')${RESET}"
fi

# Virtual Environment

echo -e "${YELLOW}Creating virtual environment...${RESET}"
$PYTHON_PATH -m venv nuggetforge_env
if [ ! -d "nuggetforge_env" ]; then
  echo -e "${RED}❌ Failed to create virtual environment.${RESET}"
  exit 1
fi
source nuggetforge_env/bin/activate

# Pip Upgrade

echo -e "${YELLOW}Checking pip inside virtual environment...${RESET}"
pip install --upgrade pip &> /dev/null
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Pip Requirement satisfied.${RESET}"
else
  echo -e "${RED}❌ Failed to upgrade pip.${RESET}"
  deactivate
  exit 1
fi

# Dependency Install

echo -e "${YELLOW}Installing dependencies...${RESET}"
TOTAL_STEPS=6
STEP=0
for dep in pyside6 pymobiledevice3 pyinstaller opencv-python ffmpeg-python; do
  pip install $dep &> /dev/null
  ((STEP++))
  progress_bar $STEP $TOTAL_STEPS
  sleep 0.1
done
brew install ffmpeg &> /dev/null
progress_bar $TOTAL_STEPS $TOTAL_STEPS

echo -e "\n${GREEN}Dependencies installed.${RESET}"

# Project locate

echo -e "${YELLOW}Searching for project files...${RESET}"
SEARCH_DIR=$(find . -type f -name "main_app.py" -exec dirname {} \; | head -n 1)
if [ -z "$SEARCH_DIR" ]; then
    echo -e "${RED}Error: main_app.py not found.${RESET}"
    deactivate
    exit 1
fi

echo -e "${GREEN}Project found: $SEARCH_DIR${RESET}"
cd "$SEARCH_DIR"

# Cleanup

echo -e "${YELLOW}Cleaning old builds...${RESET}"
rm -rf build dist NuggetApp.spec

# Build

echo -e "${YELLOW}Building NuggetApp...${RESET}"
pyinstaller --clean --onedir --windowed --name NuggetApp main_app.py > buildlog.txt 2>&1 &
PID=$!
TOTAL_BUILD=40
PROGRESS=0
while kill -0 $PID 2>/dev/null; do
  ((PROGRESS++))
  if [ $PROGRESS -gt $TOTAL_BUILD ]; then PROGRESS=$TOTAL_BUILD; fi
  progress_bar $PROGRESS $TOTAL_BUILD
  sleep 0.15
done
wait $PID
progress_bar $TOTAL_BUILD $TOTAL_BUILD

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✅ Build completed successfully!${RESET}"
  echo -e "${YELLOW}Output: downloads/Nugget-main/dist/NuggetApp.app${RESET}"
else
  echo -e "${RED}❌ Build failed. See buildlog.txt for details.${RESET}"
  deactivate
  exit 1
fi

deactivate

# Footer

echo -e "${PURPLE}=====================================${RESET}"
echo -e "${PURPLE}         NuggetForge v1.4 Done       ${RESET}"
echo -e "${PURPLE}=====================================${RESET}"
echo -e "${PURPLE}            ~Felix Freiheit           ${RESET}"
