#!/bin/bash

#  Rice script
#  Author  :  aquapaka
#  Url     :  https://github.com/aquapaka/dotfiles
#  About   :  This file will configure and launch the rice.
#

avaiableThemes=("aqua" "wasabi" "shuri")

usage() {
  printf "
Rice Script for apply a rice theme

Usage:
`basename $0`\t[aqua]  \t A playful, mysterious girl with eyes like shimmering aqua, her movements graceful and quick, full of curiosity and charm
\t[wasabi] \t Mysterious and alluring, with eyes like deep ocean blue and an aura of fire, she exudes both danger and enchantment
\t[shuri] \t A gentle presence in shades of purple, like twilight’s soft embrace—quietly comforting, effortlessly lovely
"
}

# Set zebar config
set_zebar_theme() {
  echo "Applying zebar theme..."
  # Replace ~/.glzr/zebar/dotifle-bar folder with the one in the rice
  rm -rf ~/.glzr/zebar/dotfile-bar
  cp -r ./rices/$theme/dotfile-bar ~/.glzr/zebar/dotfile-bar
  # Restart Zebar
  echo "Restarting Zebar..."
  taskkill -IM zebar.exe -F > /dev/null 2>&1
  start zebar > /dev/null 2>&1 &
  echo "✅ Zebar theme applied!"
}

# Set glazewm config
set_glazewm_config() {
  echo "Applying GlazeWM border color..."
  SETTING_FILE_PATH=$USERPROFILE\\.glzr\\glazewm\\config.yaml
  RICE_SETTING_FILE_PATH=./rices/$theme/settings.json
  yq ".window_effects.focused_window.border.color = \"$(jq -r '.glazewmConfig.focusedWindowsColor' $RICE_SETTING_FILE_PATH)\" | .window_effects.other_windows.border.color = \"$(jq -r '.glazewmConfig.otherWindowsColor' $RICE_SETTING_FILE_PATH)\"" $SETTING_FILE_PATH > tmp.yaml && mv tmp.yaml $SETTING_FILE_PATH
  echo "Reload GlazeWM configs..."
  glazewm command wm-reload-config > /dev/null
  echo "✅ GlazeWM theme applied!"
}

# Set VSCode theme
set_vscode_theme() {
  echo "Applying VSCode theme..."
  echo "$(jq -s '.[0] * .[1]' ~/AppData/Roaming/Code/User/settings.json ./rices/$theme/vscode-theme-settings.json)" > tmp.json && mv tmp.json ~/AppData/Roaming/Code/User/settings.json
  echo "✅ VSCode theme applied!"
}

# Set windows terminal theme
set_windows_terminal_theme() {
  echo "Applying windows terminal theme..."
  SETTING_FILE_PATH=$USERPROFILE\\AppData\\Local\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState\\settings.json
  RICE_SETTING_FILE_PATH=./rices/$theme/settings.json
  jq ".profiles.defaults.colorScheme = input.windowsTerminalTheme" $SETTING_FILE_PATH $RICE_SETTING_FILE_PATH > tmp.json && mv tmp.json $SETTING_FILE_PATH
  jq ".profiles.defaults.font += input.windowsTerminalFont" $SETTING_FILE_PATH $RICE_SETTING_FILE_PATH > tmp.json && mv tmp.json $SETTING_FILE_PATH
  echo "✅ Windows terminal theme applied!"
}

# Change windows light/dark mode
change_windows_lightdark_mode() {
  echo "Changing windows color scheme..."
  WINDOWS_THEME=$(jq -r '.windowsTheme' ./rices/$theme/settings.json)
  if [ $WINDOWS_THEME == dark ]
    then powershell "New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name SystemUsesLightTheme -Value '0' -Type Dword -Force | Out-Null";
         powershell "New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name AppsUseLightTheme -Value '0' -Type Dword -Force | Out-Null"
  elif [ $WINDOWS_THEME == light ]
    then powershell "New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name SystemUsesLightTheme -Value '1' -Type Dword -Force | Out-Null";
         powershell "New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name AppsUseLightTheme -Value '1' -Type Dword -Force | Out-Null"
  else
    echo "Error: windows-theme must be light or dark"
    return 1
  fi
  echo "Restart explorer... (⚠️Noticed bug: Taskbar might take sometime to show up)"
  powershell "taskkill /F /IM explorer.exe | Out-Null; start explorer"
  echo "✅ Windows color scheme changed!"
}

# Set desktop wallpaper
set_desktop_wallpaper() {
  echo "Changing desktop wallpaper..."
  powershell ./wackground.ps1 ./rices/$theme/wallpapers --set-random
  echo "✅ Desktop wallpaper changed!"
}

# Goes to this script location first
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

for theme in "${avaiableThemes[@]}"; do
  if [[ "$1" == "$theme" ]]; then
    echo "⭐ Applying $theme theme ⭐"
    echo " "

    # # Apply configs
    set_desktop_wallpaper
    set_windows_terminal_theme
    set_zebar_theme
    set_vscode_theme
    set_glazewm_config
    # change_windows_lightdark_mode # Disabled, currently too buggy

    echo " "
    echo "⭐ Theme changing completed! ⭐"

    exit 0
  fi
done

usage
