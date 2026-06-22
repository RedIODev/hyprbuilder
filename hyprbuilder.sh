#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White


mkdir ./hyprland-rebuild
cd ./hyprland-rebuild

repos="hyprutils hyprwayland-scanner hyprlang aquamarine hyprgraphics hyprcursor hyprtoolkit hyprland-guiutils hyprland-qt-support hyprwire"

if [[ $* = "gui-workaround"]]
	workaround="-I/usr/include/pango-1.0 -I/usr/include/glib-2.0/ -I/usr/lib/x86_64-linux-gnu/glib-2.0/include/ -I/usr/include/harfbuzz/"
else
	workaround=""
fi

if [[ $* = "skip-download" ]]; then

else #skip-download

echo -e "[${Cyan}info${Color_Off}] Downloading repos."

if git clone --recursive https://github.com/hyprwm/Hyprland; then
	echo -e "[${Green}Success${Color_Off}] Cloned Hyprland"
else 
	echo -e "[${Red}Failed${Color_Off}] Failed to clone Hyprland"
	exit 1
fi

for repo in $repos; do
	if git clone https://github.com/hyprwm/$repo; then
		echo -e "[${Green}Success${Color_Off}] Cloned ${repo}."
	else 
		echo -e "[${Red}Failed${Color_Off}] Failed to clone ${repo}."
		exit 1
	fi
done
echo -e "[${Cyan}info${Color_Off}] Done downloading repos."

fi #skip-download

echo -e "[${Cyan}info${Color_Off}] Installing dependencies."
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

for repo in $repos; do
	cd ./$repo/
	echo -e "[${Cyan}info${Color_Off}] Creating build files for ${repo}."
	if cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_CXX_FLAGS=$workaround -S . -B ./build; then
		echo -e "[${Green}Success${Color_Off}] Created build files for ${repo}."
	else
		echo -e "[${Red}Failed${Color_Off}] Failed to create build files for ${repo}."
		exit 1
	fi
	echo -e "[${Cyan}info${Color_Off}] Building ${repo}."
	if cmake --build ./build/ --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`; then
		echo -e "[${Green}Success${Color_Off}] Built ${repo}."
	else
		echo -e "[${Red}Failed${Color_Off}] Failed to build ${repo}."
		exit 1
	fi
	echo -e "[${Cyan}info${Color_Off}] Installing ${repo}."
	if sudo cmake --install build; then
		echo -e "[${Green}Success${Color_Off}] Installed ${repo}."
	else
		echo -e "[${Red}Failed${Color_Off}] Failed to install ${repo}."
		exit 1
	fi
	cd ..
done

echo -e "[${Cyan}info${Color_Off}] Done installing dependencies."
echo -e "[${Cyan}info${Color_Off}] Installing Hyprland."
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

cd Hyprland
if make all; then
	echo -e "[${Green}Success${Color_Off}] Built Hyprland."
else
	echo -e "[${Red}Failed${Color_Off}] Failed to build Hyprland."
	exit 1
fi

if sudo make install; then
	echo -e "[${Green}Success${Color_Off}] Installed Hyprland."
else
	echo -e "[${Red}Failed${Color_Off}] Failed to install Hyprland."
	exit 1
fi

echo -e "[${Cyan}info${Color_Off}] Removing files."
cd ../..
rm -rf ./hyprland-rebuild
echo -e "[${Cyan}info${Color_Off}] Successfully installed Hyprland. Reboot now."
exit 0
